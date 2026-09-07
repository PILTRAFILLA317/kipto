import {
  authenticate,
  backend,
  BackendError,
  boundedBytes,
  failure,
  reply,
  rpc,
  uuid,
} from "../_shared/backend.ts";
Deno.serve(async (request) => {
  try {
    if (request.method !== "POST") {
      throw new BackendError("methodNotAllowed", 405);
    }
    const data = JSON.parse(
      new TextDecoder().decode(await boundedBytes(request, 1024)),
    );
    if (
      data.confirmation !== "deleteAccount" || !uuid.test(data.requestId ?? "")
    ) throw new BackendError("invalid", 400);
    let user: string;
    try {
      user = await authenticate(request);
    } catch (error) {
      // A lost success response remains recoverable after Auth is gone. This
      // opaque receipt reveals only completion, never identity or document data.
      const receipt = await backend(
        `/rest/v1/account_deletions?request_id=eq.${data.requestId}&select=state,user_id`,
      );
      if (receipt.ok) {
        const rows = await receipt.json();
        if (rows.length === 1) {
          if (rows[0].state === "complete") return reply({ state: "complete" });
          const remaining = await backend(
            `/auth/v1/admin/users/${rows[0].user_id}`,
          );
          const absent = remaining.status === 404;
          await remaining.body?.cancel();
          if (absent) {
            const marked = await backend(
              `/rest/v1/account_deletions?request_id=eq.${data.requestId}`,
              {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                  state: "complete",
                  completed_at: new Date().toISOString(),
                }),
              },
            );
            if (!marked.ok) throw new BackendError("deleteFailed");
            await marked.body?.cancel();
            return reply({ state: "complete" });
          }
        }
      }
      throw error;
    }
    const begun = await rpc<{ requestId: string; pending: boolean }>(
      "kipto_begin_account_delete",
      { p_user_id: user, p_request_id: data.requestId },
    );
    if (begun.pending) {
      return reply({ state: "pending", requestId: begun.requestId }, 202);
    }
    while (true) {
      const rows = await backend(
        `/rest/v1/source_backups?user_id=eq.${user}&select=object_path&limit=100`,
      );
      if (!rows.ok) throw new BackendError("deleteFailed");
      const backups = await rows.json();
      if (!backups.length) break;
      const removed = await backend("/storage/v1/object/kipto-sources", {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          prefixes: backups.map((b: { object_path: string }) => b.object_path),
        }),
      });
      if (!removed.ok) {
        await removed.body?.cancel();
        throw new BackendError("deleteFailed");
      }
      await removed.body?.cancel();
      const paths = backups.map((b: { object_path: string }) =>
        `"${b.object_path}"`
      ).join(",");
      const cleared = await backend(
        `/rest/v1/source_backups?user_id=eq.${user}&object_path=in.(${
          encodeURIComponent(paths)
        })`,
        { method: "DELETE" },
      );
      if (!cleared.ok) {
        await cleared.body?.cancel();
        throw new BackendError("deleteFailed");
      }
      await cleared.body?.cancel();
    }
    // Product tables and internal ledgers have auth.users cascading foreign keys.
    const deleted = await backend(`/auth/v1/admin/users/${user}`, {
      method: "DELETE",
    });
    if (!deleted.ok && deleted.status !== 404) {
      await deleted.body?.cancel();
      throw new BackendError("deleteFailed");
    }
    await deleted.body?.cancel();
    const completed = await backend(
      `/rest/v1/account_deletions?user_id=eq.${user}`,
      {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          state: "complete",
          completed_at: new Date().toISOString(),
        }),
      },
    );
    if (!completed.ok) {
      await completed.body?.cancel();
      throw new BackendError("deleteFailed");
    }
    await completed.body?.cancel();
    return reply({ state: "complete", requestId: begun.requestId });
  } catch (error) {
    return failure(error);
  }
});
