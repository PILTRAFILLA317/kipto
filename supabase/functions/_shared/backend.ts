/** Server-only operations. Errors never include payloads, tokens or URLs. */
export class BackendError extends Error {
  constructor(readonly code: string, readonly status = 503) {
    super(code);
  }
}
const url = Deno.env.get("SUPABASE_URL") ?? "";
const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const publicKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
export async function backend(
  path: string,
  init: RequestInit = {},
): Promise<Response> {
  if (!url || !service) throw new BackendError("configurationUnavailable");
  const response = await fetch(`${url}${path}`, {
    ...init,
    headers: {
      apikey: service,
      Authorization: `Bearer ${service}`,
      ...init.headers,
    },
    signal: AbortSignal.timeout(45000),
  });
  return response;
}
export async function rpc<T>(
  name: string,
  args: Record<string, unknown>,
): Promise<T> {
  const response = await backend(`/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(args),
  });
  if (!response.ok) {
    await response.body?.cancel();
    throw new BackendError("serviceUnavailable");
  }
  return await response.json() as T;
}
export async function authenticate(request: Request): Promise<string> {
  const token = request.headers.get("authorization") ?? "";
  if (!token.startsWith("Bearer ") || !url || !publicKey) {
    throw new BackendError("unauthorized", 401);
  }
  const response = await fetch(`${url}/auth/v1/user`, {
    headers: { apikey: publicKey, Authorization: token },
    signal: AbortSignal.timeout(10000),
  });
  if (!response.ok) {
    await response.body?.cancel();
    throw new BackendError("unauthorized", 401);
  }
  const user = await response.json();
  if (typeof user.id !== "string") throw new BackendError("unauthorized", 401);
  return user.id;
}
export const uuid =
  /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i;
export function reply(value: unknown, status = 200): Response {
  return Response.json(value, {
    status,
    headers: { "Cache-Control": "no-store" },
  });
}
export function failure(error: unknown): Response {
  return error instanceof BackendError
    ? reply({ error: error.code }, error.status)
    : reply({ error: "serviceUnavailable" }, 503);
}
export async function boundedBytes(
  request: Request,
  limit: number,
): Promise<Uint8Array> {
  if (!request.body) throw new BackendError("invalid", 400);
  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  let deadline: ReturnType<typeof setTimeout> | undefined;
  const expired = new Promise<never>((_, reject) => {
    deadline = setTimeout(
      () => reject(new BackendError("requestTimeout", 408)),
      35000,
    );
  });
  try {
    while (true) {
      const { value, done } = await Promise.race([reader.read(), expired]);
      if (done) break;
      size += value.length;
      if (size > limit) throw new BackendError("tooLarge", 413);
      chunks.push(value);
    }
  } finally {
    clearTimeout(deadline);
    await reader.cancel();
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  return bytes;
}
export async function hashBytes(bytes: Uint8Array): Promise<string> {
  const hash = await crypto.subtle.digest("SHA-256", bytes as BufferSource);
  return [...new Uint8Array(hash)].map((x) => x.toString(16).padStart(2, "0"))
    .join("");
}
