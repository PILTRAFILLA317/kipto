/** Opt-in, synthetic-only smoke evaluation. Never run by automated tests. */
if (!Deno.args.includes("--run")) {
  console.log("Opt-in required: pass --run and optionally --cases=1..3. See docs/external-dependencies.md.");
  Deno.exit(0);
}
const count = Number(Deno.args.find((a) => a.startsWith("--cases="))?.split("=")[1] ?? "1");
if (!Number.isInteger(count) || count < 1 || count > 3) throw new Error("Use 1 to 3 synthetic cases");
const endpoint = Deno.env.get("KIPTO_EVAL_URL");
const token = Deno.env.get("KIPTO_EVAL_TOKEN");
const key = Deno.env.get("KIPTO_EVAL_PUBLIC_KEY");
if (!endpoint || !token || !key || new URL(endpoint).protocol !== "https:") {
  throw new Error("Configure an HTTPS project URL, a synthetic session token and the public key");
}
for (const name of ["invoice", "appointment", "ambiguous"].slice(0, count)) {
  const fixture = JSON.parse(await Deno.readTextFile(new URL(`../test/fixtures/analysis/${name}.json`, import.meta.url)));
  const sourceId = crypto.randomUUID();
  const request = {
    requestVersion: 1, requestId: crypto.randomUUID(), captureId: sourceId, sourceId,
    sourceRevision: 1, locale: "es", userTimeZone: "Europe/Madrid",
    importedAt: new Date().toISOString(), knownDocumentContext: null,
    input: { type: "text", textPages: fixture.textPages, imagePages: [] },
    coverage: {totalPagesKnown: fixture.textPages.length, analyzedPages: fixture.textPages.map((p: {page: number}) => p.page), isPartial: false},
  };
  const response = await fetch(`${endpoint.replace(/\/$/, "")}/functions/v1/analyze-source`, {
    method: "POST", redirect: "error", signal: AbortSignal.timeout(65000),
    headers: { Authorization: `Bearer ${token}`, apikey: key, "Content-Type": "application/json" },
    body: JSON.stringify(request),
  });
  const body = await response.json();
  // Only aggregate diagnostics. Do not log output, prompts, file names or tokens.
  console.log(JSON.stringify({case: name, status: response.status, model: typeof body.model === "string" ? body.model : null,
    usage: body.usage ? {inputTokens: body.usage.inputTokens, outputTokens: body.usage.outputTokens} : null,
    facts: Array.isArray(body.output?.facts) ? body.output.facts.length : null,
    suggestions: Array.isArray(body.output?.suggestions) ? body.output.suggestions.length : null}));
  if (!response.ok) Deno.exit(1); // No automatic paid retry.
}
