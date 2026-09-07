import {
  authenticate,
  backend,
  BackendError,
  boundedBytes,
  failure,
  hashBytes,
  reply,
  rpc,
  uuid,
} from "../_shared/backend.ts";

type Backup = {
  error?: string;
  state: string;
  byte_size: number;
  content_hash: string;
  object_path: string;
};
Deno.serve(async (request) => {
  try {
    const user = await authenticate(request);
    const input = new URL(request.url);
    const id = input.searchParams.get("source") ?? "";
    const revision = Number(input.searchParams.get("revision"));
    if (!uuid.test(id) || !Number.isSafeInteger(revision) || revision < 1) {
      throw new BackendError("invalid", 400);
    }
    if (request.method === "PUT") {
      const reservation = await rpc<Backup>("kipto_reserve_backup", {
        p_user_id: user,
        p_source_id: id,
        p_revision: revision,
      });
      if (reservation.error) {
        throw new BackendError(
          reservation.error,
          reservation.error === "proRequired" ? 403 : 409,
        );
      }
      if (reservation.state === "ready") return reply({ state: "ready" });
      if (
        !await rpc<boolean>("kipto_backup_upload_lease", {
          p_user_id: user,
          p_source_id: id,
          p_revision: revision,
        })
      ) throw new BackendError("sourceChanged", 409);
      const bytes = await boundedBytes(request, 20971520);
      if (
        bytes.length !== reservation.byte_size ||
        await hashBytes(bytes) !== reservation.content_hash
      ) throw new BackendError("contentMismatch", 400);
      const metadata = await backend(
        `/rest/v1/sources?id=eq.${id}&user_id=eq.${user}&select=mime_type`,
      );
      if (!metadata.ok) throw new BackendError("sourceUnavailable", 409);
      const rows = await metadata.json();
      if (rows.length !== 1) throw new BackendError("sourceUnavailable", 409);
      const uploaded = await backend(
        `/storage/v1/object/kipto-sources/${reservation.object_path}`,
        {
          method: "POST",
          headers: { "Content-Type": rows[0].mime_type, "x-upsert": "true" },
          body: bytes as BodyInit,
        },
      );
      if (!uploaded.ok) {
        await uploaded.body?.cancel();
        throw new BackendError("uploadFailed");
      }
      await uploaded.body?.cancel();
      const confirmed = await rpc<boolean>("kipto_finish_backup", {
        p_user_id: user,
        p_source_id: id,
        p_revision: revision,
        p_hash: reservation.content_hash,
      });
      if (!confirmed) {
        const cleanup = await backend("/storage/v1/object/kipto-sources", {
          method: "DELETE",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ prefixes: [reservation.object_path] }),
        });
        await cleanup.body?.cancel();
        throw new BackendError("sourceChanged", 409);
      }
      return reply({ state: "ready" });
    }
    if (request.method === "DELETE") {
      const deletion = await rpc<{ pending: boolean; paths: string[] }>(
        "kipto_begin_source_delete",
        { p_user_id: user, p_source_id: id },
      );
      if (deletion.pending) return reply({ error: "deletionPending" }, 202);
      if (deletion.paths.length) {
        const removed = await backend("/storage/v1/object/kipto-sources", {
          method: "DELETE",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ prefixes: deletion.paths }),
        });
        if (!removed.ok) {
          await removed.body?.cancel();
          throw new BackendError("deleteFailed");
        }
        await removed.body?.cancel();
      }
      const cleared = await backend(
        `/rest/v1/source_backups?user_id=eq.${user}&source_id=eq.${id}&state=eq.deleting`,
        { method: "DELETE" },
      );
      if (!cleared.ok) {
        await cleared.body?.cancel();
        throw new BackendError("deleteFailed");
      }
      await cleared.body?.cancel();
      return reply({ state: "deleted" });
    }
    if (request.method === "GET") {
      const response = await backend(
        `/rest/v1/source_backups?user_id=eq.${user}&source_id=eq.${id}&revision=eq.${revision}&state=eq.ready&select=object_path`,
      );
      if (!response.ok) throw new BackendError("serviceUnavailable");
      const rows = await response.json();
      if (rows.length !== 1) return reply({ state: "unavailable" }, 404);
      // Native client verifies size and SHA-256 again before exposing a local file.
      const file = await backend(
        `/storage/v1/object/kipto-sources/${rows[0].object_path}`,
      );
      if (!file.ok) {
        await file.body?.cancel();
        throw new BackendError("downloadFailed");
      }
      return new Response(file.body, {
        headers: {
          "Content-Type": file.headers.get("content-type") ??
            "application/octet-stream",
          "Cache-Control": "no-store",
        },
      });
    }
    throw new BackendError("methodNotAllowed", 405);
  } catch (error) {
    return failure(error);
  }
});
