import {
  AnalysisError,
  type AnalysisOutput,
  type AnalysisRequest,
  readRequest,
  validateOutput,
} from "../_shared/analysis_contract.ts";
import {
  PROMPT_VERSION,
  type ProviderResult,
} from "../_shared/analysis_provider.ts";

export type AnalysisEnvelope = {
  requestId: string;
  model: string;
  promptVersion: string;
  schemaVersion: 1;
  analyzedAt: string;
  usage: ProviderResult["usage"];
  output: AnalysisOutput;
};
export type Reservation = { decision: "reserved"; leaseToken: string } | {
  decision: "cached";
  envelope: AnalysisEnvelope;
} | {
  decision:
    | "busy"
    | "quotaBlocked"
    | "globalLimit"
    | "mismatch"
    | "expired"
    | "indeterminate"
    | "failed";
  retryAfter?: number;
};
export type AnalysisDependencies = {
  authenticate: (token: string) => Promise<string | null>;
  configured: () => boolean;
  reserve: (
    userId: string,
    request: AnalysisRequest,
    hash: string,
  ) => Promise<Reservation>;
  complete: (
    userId: string,
    requestId: string,
    leaseToken: string,
    envelope: AnalysisEnvelope,
  ) => Promise<void>;
  fail: (
    userId: string,
    requestId: string,
    leaseToken: string,
    code: string,
    retryAfter?: number,
  ) => Promise<void>;
  analyze: (request: AnalysisRequest) => Promise<ProviderResult>;
};
function canonical(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(canonical);
  if (value !== null && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map((
        [k, v],
      ) => [k, canonical(v)]),
    );
  }
  return value;
}
export async function requestHash(request: AnalysisRequest): Promise<string> {
  const bytes = new TextEncoder().encode(JSON.stringify(canonical(request)));
  return Array.from(
    new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)),
    (b) => b.toString(16).padStart(2, "0"),
  ).join("");
}
function json(data: unknown, status = 200, retryAfter?: number) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
      ...(retryAfter ? { "Retry-After": String(retryAfter) } : {}),
    },
  });
}
export function analysisHandler(deps: AnalysisDependencies) {
  return async (request: Request): Promise<Response> => {
    if (request.method !== "POST") {
      return json({ error: "methodNotAllowed" }, 405);
    }
    let body: AnalysisRequest | undefined,
      userId: string | null = null,
      lease: string | undefined;
    try {
      const authorization = request.headers.get("authorization");
      if (
        !authorization?.startsWith("Bearer ") || authorization.length > 16384
      ) throw new AnalysisError("authenticationRequired", 401);
      userId = await deps.authenticate(authorization.slice(7));
      if (!userId) throw new AnalysisError("authenticationRequired", 401);
      if (!deps.configured()) {
        throw new AnalysisError("configurationUnavailable", 503);
      }
      body = await readRequest(request);
      const reserved = await deps.reserve(
        userId,
        body,
        await requestHash(body),
      );
      if (reserved.decision === "cached") return json(reserved.envelope);
      if (reserved.decision !== "reserved") {
        throw new AnalysisError(
          reserved.decision,
          reserved.decision === "quotaBlocked" ||
            reserved.decision === "globalLimit"
            ? 429
            : 409,
          reserved.retryAfter,
        );
      }
      lease = reserved.leaseToken;
      const result = await deps.analyze(body);
      const envelope: AnalysisEnvelope = {
        requestId: body.requestId,
        model: result.model,
        promptVersion: PROMPT_VERSION,
        schemaVersion: 1,
        analyzedAt: new Date().toISOString(),
        usage: result.usage,
        output: validateOutput(result.output, body),
      };
      await deps.complete(userId, body.requestId, lease, envelope);
      return json(envelope);
    } catch (error) {
      const failure = error instanceof AnalysisError
        ? error
        : new AnalysisError("serviceUnavailable", 503);
      if (userId && body && lease) {
        try {
          await deps.fail(
            userId,
            body.requestId,
            lease,
            failure.code,
            failure.retryAfter,
          );
        } catch {
          /* Lease remains indeterminate; never charge a second reservation. */
        }
      }
      return json({ error: failure.code }, failure.status, failure.retryAfter);
    }
  };
}
