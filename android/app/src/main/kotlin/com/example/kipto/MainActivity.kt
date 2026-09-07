package com.example.kipto

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Bundle
import java.util.UUID
import android.provider.CalendarContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sharedIntake: SharedIntake? = null
    private var delivery = UUID.randomUUID().toString()
    override fun onCreate(savedInstanceState: Bundle?) {
        delivery = savedInstanceState?.getString("kipto.delivery") ?: UUID.randomUUID().toString()
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT >= 33) setRecentsScreenshotEnabled(false)
    }
    override fun onSaveInstanceState(outState: Bundle) {
        outState.putString("kipto.delivery", delivery)
        super.onSaveInstanceState(outState)
    }
    override fun onDestroy() {
        sharedIntake?.detach()
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent !== getIntent()) delivery = UUID.randomUUID().toString()
        setIntent(intent)
        sharedIntake?.receive(intent, delivery)
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val captureChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.kipto/capture")
        sharedIntake = SharedIntake(applicationContext, captureChannel)
        captureChannel.setMethodCallHandler { call, result ->
            if (call.method == "returnToSource") { result.success(null); finish() }
            else sharedIntake!!.handle(call.method, call.arguments, result)
        }
        sharedIntake!!.receive(intent, delivery)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app.kipto/calendar",
        ).setMethodCallHandler { call, result ->
            if (call.method != "presentCalendarEventDraft") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val title = call.argument<String>("title")?.trim().orEmpty()
            val start = call.argument<Number>("startAtMilliseconds")?.toLong()
            val end = call.argument<Number>("endAtMilliseconds")?.toLong()
            if (title.isEmpty() || start == null || end == null || end <= start) {
                result.error("invalidData", "Invalid calendar event draft", null)
                return@setMethodCallHandler
            }
            val intent = Intent(Intent.ACTION_INSERT).apply {
                data = CalendarContract.Events.CONTENT_URI
                putExtra(CalendarContract.Events.TITLE, title)
                putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start)
                putExtra(CalendarContract.EXTRA_EVENT_END_TIME, end)
                putExtra(
                    CalendarContract.Events.ALL_DAY,
                    call.argument<Boolean>("allDay") == true,
                )
                call.argument<String>("location")?.takeIf { it.isNotBlank() }?.let {
                    putExtra(CalendarContract.Events.EVENT_LOCATION, it)
                }
                call.argument<String>("timeZone")?.let {
                    putExtra(CalendarContract.Events.EVENT_TIMEZONE, it)
                }
                call.argument<String>("notes")?.takeIf { it.isNotBlank() }?.let {
                    putExtra(CalendarContract.Events.DESCRIPTION, it)
                }
            }
            try {
                startActivity(intent)
                // ACTION_INSERT doesn't standardize a saved/cancelled result across
                // calendar apps. Report only that the editor opened.
                result.success("launched")
            } catch (_: ActivityNotFoundException) {
                result.success("unavailable")
            } catch (_: SecurityException) {
                result.success("unavailable")
            }
        }
    }
}
