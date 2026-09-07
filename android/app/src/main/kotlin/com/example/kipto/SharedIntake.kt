package com.example.kipto

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.util.UUID
import java.util.concurrent.Executors

/** Durable staging only. Domain validation and database writes belong to Dart. */
class SharedIntake(private val context: Context, private val channel: MethodChannel) {
    companion object { private val worker = Executors.newSingleThreadExecutor() }
    private var attached = true
    fun detach() { attached = false }
    private val main = Handler(Looper.getMainLooper())
    private val preferences = context.getSharedPreferences("kipto_capture", Context.MODE_PRIVATE)
    private val incoming = File(context.filesDir, "kipto_incoming").apply { mkdirs() }

    fun localScope(): String = synchronized(preferences) {
        preferences.getString("localScope", null) ?: ("local:" + UUID.randomUUID()).also {
            preferences.edit().putString("localScope", it).commit()
        }
    }

    fun handle(method: String, arguments: Any?, result: MethodChannel.Result) {
        when (method) {
            "localScope" -> result.success(localScope())
            "setScope" -> {
                val scope = arguments as? String
                if (scope.isNullOrBlank() || scope.length > 128) result.error("invalid", "Invalid capture scope", null)
                else { preferences.edit().putString("scope", scope).commit(); result.success(null) }
            }
            "incomingDirectory" -> result.success(incoming.absolutePath)
            else -> result.notImplemented()
        }
    }

    @Suppress("DEPRECATION")
    fun receive(intent: Intent?, delivery: String) {
        if (intent == null || intent.action !in listOf(Intent.ACTION_SEND, Intent.ACTION_SEND_MULTIPLE)) return
        val scope = preferences.getString("scope", null) ?: localScope()
        val uris = if (intent.action == Intent.ACTION_SEND_MULTIPLE) {
            intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)?.toList().orEmpty()
        } else listOfNotNull(intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM))
        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        worker.execute {
            val folder = File(incoming, delivery).apply { mkdirs() }
            val ready = File(folder, "manifest.json")
            if (ready.exists()) return@execute
            try {
                if (uris.size > 5 || (text?.length ?: 0) > 60000 || (uris.isEmpty() && text.isNullOrBlank())) throw IllegalArgumentException()
                val attachments = JSONArray()
                for ((index, uri) in uris.withIndex()) {
                    if (uri.scheme != "content") throw IllegalArgumentException()
                    val type = context.contentResolver.getType(uri).orEmpty()
                    if (type !in setOf("image/jpeg", "image/png", "image/webp", "image/heic", "image/heif", "application/pdf")) throw IllegalArgumentException()
                    val sourceId = UUID.nameUUIDFromBytes("$delivery:$index".toByteArray(Charsets.UTF_8)).toString()
                    val name = context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst()) cursor.getString(0) else null
                    } ?: sourceId
                    val partial = File(folder, "$sourceId.part")
                    var total = 0L
                    context.contentResolver.openInputStream(uri)?.use { input ->
                        FileOutputStream(partial).use { output ->
                            val buffer = ByteArray(64 * 1024)
                            while (true) {
                                val count = input.read(buffer)
                                if (count < 0) break
                                total += count
                                if (total > 20L * 1024 * 1024) throw IllegalArgumentException()
                                output.write(buffer, 0, count)
                            }
                            output.fd.sync()
                        }
                    } ?: throw IllegalArgumentException()
                    if (total == 0L) throw IllegalArgumentException()
                    val file = File(folder, sourceId)
                    if (!partial.renameTo(file)) throw IllegalStateException()
                    attachments.put(JSONObject().put("sourceId", sourceId).put("relativePath", "$delivery/$sourceId").put("mimeType", type).put("originalName", name.take(512)).put("byteSize", total))
                }
                val manifest = JSONObject().put("manifestVersion", 1).put("captureId", delivery).put("accountScopeId", scope).put("createdAt", java.time.Instant.now().toString()).put("origin", "androidShare").put("state", "ready").put("attachments", attachments).put("contextText", text ?: JSONObject.NULL)
                val partial = File(folder, "manifest.part")
                FileOutputStream(partial).use { output -> output.write(manifest.toString().toByteArray(Charsets.UTF_8)); output.fd.sync() }
                if (!partial.renameTo(ready)) throw IllegalStateException()
                main.post { if (attached) channel.invokeMethod("intakeChanged", null) }
            } catch (_: Exception) {
                // No URI, document text or provider details in logs or error messages.
                File(folder, "failed").writeText("capture_failed")
                main.post { if (attached) channel.invokeMethod("intakeChanged", null) }
            }
        }
    }
}
