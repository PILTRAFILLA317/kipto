import {
  BackendError,
  boundedBytes,
  failure,
  reply,
  uuid,
} from "../_shared/backend.ts";
export type VerifiedEntitlement = { active: boolean; expiresAt: string | null };
export function subscriberEntitlement(
  payload: Record<string, unknown>,
  environment: string,
  now = Date.now(),
): VerifiedEntitlement | null {
  const subscriber = payload.subscriber as Record<string, unknown>;
  if (!subscriber || typeof subscriber !== "object") {
    throw new BackendError("invalidProviderResponse");
  }
  const entitlements = subscriber.entitlements as Record<
    string,
    Record<string, unknown>
  >;
  if (!entitlements || typeof entitlements !== "object") {
    throw new BackendError("invalidProviderResponse");
  }
  const entitlement = entitlements.kipto_pro;
  if (!entitlement) return { active: false, expiresAt: null };
  const subscriptions = subscriber.subscriptions as Record<
    string,
    Record<string, unknown>
  >;
  const subscription = subscriptions?.[String(entitlement.product_identifier)];
  if (!subscription || typeof subscription.is_sandbox !== "boolean") {
    throw new BackendError("invalidProviderResponse");
  }
  // RevenueCat v1 returns one entitlement across both environments. Never let
  // a sandbox record overwrite production when that view is ambiguous.
  if (subscription.is_sandbox !== (environment === "sandbox")) return null;
  const end = Date.parse(
    String(entitlement.grace_period_expires_date ?? entitlement.expires_date),
  );
  if (!Number.isFinite(end)) throw new BackendError("invalidProviderResponse");
  return {
    active: end > now && subscription.refunded_at == null,
    expiresAt: new Date(end).toISOString(),
  };
}
type Dependencies = {
  secret: () => string;
  subscriber: (user: string) => Promise<Record<string, unknown>>;
  apply: (
    eventId: string,
    user: string,
    environment: string,
    eventAt: string,
    value: VerifiedEntitlement,
  ) => Promise<unknown>;
};
export function webhookHandler(deps: Dependencies) {
  return async (request: Request): Promise<Response> => {
    try {
      if (request.method !== "POST") {
        throw new BackendError("methodNotAllowed", 405);
      }
      const secret = deps.secret();
      if (secret.length < 32) {
        throw new BackendError("configurationUnavailable");
      }
      const expected = new Uint8Array(
        await crypto.subtle.digest("SHA-256", new TextEncoder().encode(secret)),
      );
      const received = new Uint8Array(
        await crypto.subtle.digest(
          "SHA-256",
          new TextEncoder().encode(request.headers.get("authorization") ?? ""),
        ),
      );
      let difference = 0;
      for (let i = 0; i < expected.length; i++) {
        difference |= expected[i] ^ received[i];
      }
      if (difference !== 0) throw new BackendError("unauthorized", 401);
      const body = JSON.parse(
        new TextDecoder().decode(await boundedBytes(request, 65536)),
      );
      const event = body.event;
      if (
        body.api_version !== "1.0" || typeof event?.id !== "string" ||
        event.id.length < 1 || event.id.length > 180 ||
        !Number.isSafeInteger(event.event_timestamp_ms) ||
        event.event_timestamp_ms > Date.now() + 300000
      ) throw new BackendError("invalid", 400);
      const users = event.type === "TRANSFER"
        ? [...(event.transferred_from ?? []), ...(event.transferred_to ?? [])]
        : [event.app_user_id];
      if (users.length > 40) throw new BackendError("invalid", 400);
      const environments = event.environment === "PRODUCTION"
        ? ["production"]
        : event.environment === "SANDBOX"
        ? ["sandbox"]
        : event.type === "TRANSFER"
        ? ["production", "sandbox"]
        : [];
      if (environments.length === 0) throw new BackendError("invalid", 400);
      for (
        const user of new Set<string>(
          users.filter((u: unknown) => typeof u === "string" && uuid.test(u)),
        )
      ) {
        const subscriber = await deps.subscriber(user);
        for (const environment of environments) {
          const value = subscriberEntitlement(subscriber, environment);
          if (value === null) continue;
          await deps.apply(
            event.id + ":" + environment,
            user,
            environment,
            new Date(event.event_timestamp_ms).toISOString(),
            value,
          );
        }
      }
      return reply({ received: true });
    } catch (error) {
      return failure(error);
    }
  };
}
