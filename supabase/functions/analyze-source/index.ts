import { AnalysisError } from "../_shared/analysis_contract.ts";
import { callOpenAI } from "../_shared/analysis_provider.ts";
import { analysisHandler, type Reservation } from "./handler.ts";

const url = Deno.env.get("SUPABASE_URL") ?? "";
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const publicKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const apiKey = Deno.env.get("OPENAI_API_KEY") ?? "";
const model = Deno.env.get("OPENAI_MODEL") ?? "";
async function rpc<T>(name: string, args: Record<string, unknown>): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${url}/rest/v1/rpc/${name}`, {
      method: "POST",
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(args),
      signal: AbortSignal.timeout(10000),
    });
  } catch {
    throw new AnalysisError("serviceUnavailable", 503);
  }
  if (!response.ok) {
    await response.body?.cancel();
    throw new AnalysisError("serviceUnavailable", 503);
  }
  const text = await response.text();
  return text ? JSON.parse(text) as T : undefined as T;
}
Deno.serve(analysisHandler({
  configured: () => Boolean(url && serviceKey && apiKey && model),
  authenticate: async (token) => {
    if (!url || !publicKey) {
      throw new AnalysisError("configurationUnavailable", 503);
    }
    const response = await fetch(`${url}/auth/v1/user`, {
      headers: { apikey: publicKey, Authorization: `Bearer ${token}` },
      signal: AbortSignal.timeout(10000),
    });
    if (!response.ok) {
      await response.body?.cancel();
      return null;
    }
    const user = await response.json();
    return typeof user.id === "string" ? user.id : null;
  },
  reserve: (userId, request, hash) =>
    rpc<Reservation>("kipto_reserve_analysis", {
      p_user_id: userId,
      p_request_id: request.requestId,
      p_source_id: request.sourceId,
      p_source_revision: request.sourceRevision,
      p_payload_hash: hash,
    }),
  complete: (userId, requestId, leaseToken, envelope) =>
    rpc<void>("kipto_complete_analysis", {
      p_user_id: userId,
      p_request_id: requestId,
      p_lease_token: leaseToken,
      p_envelope: envelope,
    }),
  fail: (userId, requestId, leaseToken, code, retryAfter) =>
    rpc<void>("kipto_fail_analysis", {
      p_user_id: userId,
      p_request_id: requestId,
      p_lease_token: leaseToken,
      p_error_code: code,
      p_retry_after: retryAfter ?? null,
    }),
  analyze: (request) => callOpenAI(request, { apiKey, model }),
}));
