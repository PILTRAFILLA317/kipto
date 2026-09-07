import { BackendError, boundedBytes, rpc } from "../_shared/backend.ts";
import { webhookHandler } from "./handler.ts";
Deno.serve(webhookHandler({
  secret: () => Deno.env.get("REVENUECAT_WEBHOOK_AUTH") ?? "",
  subscriber: async (user) => {
    const key = Deno.env.get("REVENUECAT_SECRET_API_KEY");
    if (!key) throw new BackendError("configurationUnavailable");
    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(user)}`,
      {
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(10000),
      },
    );
    if (!response.ok) {
      await response.body?.cancel();
      throw new BackendError("providerUnavailable");
    }
    const bytes = await boundedBytes(
      new Request(
        "https://local.invalid",
        { method: "POST", body: response.body, duplex: "half" } as RequestInit,
      ),
      262144,
    );
    return JSON.parse(new TextDecoder().decode(bytes));
  },
  apply: (id, user, environment, eventAt, value) =>
    rpc("kipto_apply_billing_event", {
      p_event_id: id,
      p_user_id: user,
      p_environment: environment,
      p_event_at: eventAt,
      p_active: value.active,
      p_expires_at: value.expiresAt,
    }),
}));
