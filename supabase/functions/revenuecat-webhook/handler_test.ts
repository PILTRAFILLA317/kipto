import { assertEquals } from "@std/assert";
import { subscriberEntitlement, webhookHandler } from "./handler.ts";
Deno.test("T19 webhook authenticates before provider access; cancellation retains paid expiry; sandbox cannot grant production", async () => {
  let calls = 0;
  const applied: unknown[] = [];
  const secret = "synthetic-test-only-authorization-123456789";
  const payload = {
    subscriber: {
      entitlements: {
        kipto_pro: {
          expires_date: "2099-01-01T00:00:00Z",
          product_identifier: "synthetic_monthly",
        },
      },
      subscriptions: {
        synthetic_monthly: {
          is_sandbox: true,
          refunded_at: null,
          unsubscribe_detected_at: "2026-09-05T00:00:00Z",
        },
      },
    },
  };
  const handler = webhookHandler({
    secret: () => secret,
    subscriber: () => {
      calls++;
      return Promise.resolve(payload);
    },
    apply: (_id, _user, _env, _at, value) => {
      applied.push(value);
      return Promise.resolve();
    },
  });
  const body = JSON.stringify({
    api_version: "1.0",
    event: {
      id: "synthetic",
      type: "CANCELLATION",
      environment: "SANDBOX",
      app_user_id: "971691c4-4d96-4786-bff6-94c9f128e61a",
      event_timestamp_ms: Date.now(),
    },
  });
  assertEquals(
    (await handler(
      new Request("https://test.invalid", { method: "POST", body }),
    )).status,
    401,
  );
  assertEquals(calls, 0);
  assertEquals(
    (await handler(
      new Request("https://test.invalid", {
        method: "POST",
        headers: { authorization: secret },
        body,
      }),
    )).status,
    200,
  );
  assertEquals(applied, [{
    active: true,
    expiresAt: "2099-01-01T00:00:00.000Z",
  }]);
  assertEquals(subscriberEntitlement(payload, "production"), null);
  payload.subscriber.subscriptions.synthetic_monthly.refunded_at =
    "2026-09-05" as unknown as null;
  assertEquals(subscriberEntitlement(payload, "sandbox")?.active, false);
});
