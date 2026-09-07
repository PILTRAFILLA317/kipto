import { imageSize } from "image-size";
import { Ajv } from "ajv";
import requestSchema from "./contracts/analysis-request-v1.schema.json" with {
  type: "json",
};
import outputSchema from "./contracts/analysis-output-v1.schema.json" with {
  type: "json",
};

export const MAX_BODY_BYTES = 8 * 1024 * 1024;
export class AnalysisError extends Error {
  constructor(
    public readonly code: string,
    public readonly status = 400,
    public readonly retryAfter?: number,
  ) {
    super(code);
  }
}
export type AnalysisRequest = {
  requestVersion: 1;
  requestId: string;
  captureId: string;
  sourceId: string;
  sourceRevision: number;
  locale: "es" | "en";
  userTimeZone: string;
  importedAt: string;
  knownDocumentContext: {
    documentDate: string;
    dateSource: "userConfirmed" | "documentExplicit";
  } | null;
  input: {
    type: "text" | "imagePages";
    textPages: { page: number; text: string }[];
    imagePages: { page: number; mimeType: string; base64: string }[];
  };
  coverage: {
    totalPagesKnown: number | null;
    analyzedPages: number[];
    isPartial: boolean;
  };
};
export type AnalysisOutput = {
  schemaVersion: 1;
  sourceRevision: number;
  documentLabel: string;
  title: string;
  summary: string;
  coverage: { isPartial: boolean; analyzedPages: number[] };
  facts: {
    key: string;
    type: string;
    valueType: string;
    value: Record<string, unknown>;
    evidence: { page: number | null; quote: string | null };
    uncertainty: string | null;
  }[];
  suggestions: {
    key: string;
    kind: "remind" | "event" | "keep";
    title: string;
    relatedFactKeys: string[];
    anchorFactKey: string | null;
    needsUserInput: string[];
    reason: string;
  }[];
  warnings: string[];
};
const ajv = new Ajv({ strict: true, allowUnionTypes: true, allErrors: false });
ajv.addFormat(
  "date-time",
  (v: string) =>
    /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$/.test(
      v,
    ) && Number.isFinite(Date.parse(v)),
);
const requestShape = ajv.compile<AnalysisRequest>(requestSchema);
const outputShape = ajv.compile<AnalysisOutput>(outputSchema);
const valueSchemas = outputSchema.properties.facts.items.properties.value.anyOf;
const valueShapes = new Map(
  ["text", "date", "datetime", "duration", "money"].map((
    key,
    i,
  ) => [key, ajv.compile(valueSchemas[i])]),
);
function dateValid(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const d = new Date(`${value}T00:00:00Z`);
  return Number.isFinite(d.valueOf()) &&
    d.toISOString().slice(0, 10) === value && !value.startsWith("0000");
}
function zoneValid(zone: string): boolean {
  try {
    new Intl.DateTimeFormat("en", { timeZone: zone });
    return true;
  } catch {
    return false;
  }
}
function samePages(a: number[], b: number[]) {
  return a.length === b.length && new Set(a).size === a.length &&
    a.every((p) => b.includes(p));
}
export async function readRequest(request: Request): Promise<AnalysisRequest> {
  if (
    !request.headers.get("content-type")?.toLowerCase().startsWith(
      "application/json",
    )
  ) throw new AnalysisError("invalidContentType");
  const declared = Number(request.headers.get("content-length"));
  if (declared > MAX_BODY_BYTES) {
    throw new AnalysisError("payloadTooLarge", 413);
  }
  const reader = request.body?.getReader();
  if (!reader) throw new AnalysisError("invalidRequest");
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      size += value.byteLength;
      if (size > MAX_BODY_BYTES) {
        await reader.cancel();
        throw new AnalysisError("payloadTooLarge", 413);
      }
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  let data: unknown;
  try {
    data = JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes));
  } catch {
    throw new AnalysisError("invalidRequest");
  }
  return validateRequest(data);
}
export function validateRequest(data: unknown): AnalysisRequest {
  if (!requestShape(data)) throw new AnalysisError("invalidRequest");
  const { input, coverage } = data;
  const pages = input.type === "text" ? input.textPages : input.imagePages;
  if (
    pages.length === 0 ||
    !samePages(pages.map((p) => p.page), coverage.analyzedPages) ||
    (input.type === "text"
        ? input.imagePages.length
        : input.textPages.length) !== 0 ||
    input.textPages.reduce((n, p) => n + p.text.length, 0) > 60000 ||
    !zoneValid(data.userTimeZone) || !dateValid(data.importedAt.slice(0, 10)) ||
    data.knownDocumentContext !== null &&
      !dateValid(data.knownDocumentContext.documentDate) ||
    coverage.totalPagesKnown === null && !coverage.isPartial ||
    coverage.totalPagesKnown !== null &&
      (coverage.analyzedPages.some((p) => p > coverage.totalPagesKnown!) ||
        coverage.isPartial !== (coverage.totalPagesKnown > pages.length))
  ) {
    throw new AnalysisError("invalidRequest");
  }
  for (const page of input.imagePages) {
    if (
      page.base64.length % 4 !== 0 ||
      !/^[A-Za-z0-9+/]*={0,2}$/.test(page.base64)
    ) throw new AnalysisError("invalidImage");
    let bytes: Uint8Array;
    try {
      bytes = Uint8Array.from(atob(page.base64), (c) => c.charCodeAt(0));
    } catch {
      throw new AnalysisError("invalidImage");
    }
    if (!bytes.length || imageMime(bytes) !== page.mimeType) {
      throw new AnalysisError("invalidImage");
    }
    try {
      const { width, height } = imageSize(bytes);
      if (
        !width || !height || width > 4096 || height > 4096 ||
        width * height > 4194304
      ) throw new Error();
    } catch {
      throw new AnalysisError("invalidImage");
    }
  }
  return data;
}
export function imageMime(b: Uint8Array): string | null {
  if (
    b.length >= 8 &&
    [137, 80, 78, 71, 13, 10, 26, 10].every((v, i) => b[i] === v)
  ) return "image/png";
  if (b.length >= 3 && b[0] === 255 && b[1] === 216 && b[2] === 255) {
    return "image/jpeg";
  }
  const ascii = (from: number, to: number) =>
    new TextDecoder().decode(b.subarray(from, to));
  if (b.length >= 12 && ascii(0, 4) === "RIFF" && ascii(8, 12) === "WEBP") {
    return "image/webp";
  }
  return null;
}
export function validateOutput(
  data: unknown,
  request: AnalysisRequest,
): AnalysisOutput {
  if (!outputShape(data)) throw new AnalysisError("invalidOutput", 502);
  if (
    data.sourceRevision !== request.sourceRevision ||
    data.coverage.isPartial !== request.coverage.isPartial ||
    !samePages(data.coverage.analyzedPages, request.coverage.analyzedPages)
  ) throw new AnalysisError("invalidOutput", 502);
  const keys = new Set(data.facts.map((f) => f.key));
  if (
    keys.size !== data.facts.length ||
    new Set(data.suggestions.map((a) => a.key)).size !==
      data.suggestions.length ||
    !data.title.trim() || !data.documentLabel.trim() ||
    data.warnings.some((w) => !w.trim())
  ) throw new AnalysisError("invalidOutput", 502);
  for (const fact of data.facts) {
    const value = fact.value;
    if (
      !valueShapes.get(fact.valueType)?.(value) || !fact.key.trim() ||
      !fact.type.trim() ||
      typeof value.text === "string" && !value.text.trim() ||
      typeof value.raw === "string" && !value.raw.trim() ||
      fact.uncertainty !== null && !fact.uncertainty.trim() ||
      fact.evidence.page !== null &&
        !request.coverage.analyzedPages.includes(fact.evidence.page) ||
      typeof value.date === "string" && !dateValid(value.date) ||
      typeof value.time === "string" &&
        !/^([01]\d|2[0-3]):[0-5]\d$/.test(value.time) ||
      typeof value.zone === "string" && !zoneValid(value.zone) ||
      fact.evidence.quote !== null && !fact.evidence.quote.trim()
    ) throw new AnalysisError("invalidOutput", 502);
  }
  for (const a of data.suggestions) {
    if (
      !a.key.trim() || !a.title.trim() || !a.reason.trim() ||
      new Set(a.relatedFactKeys).size !== a.relatedFactKeys.length ||
      !a.relatedFactKeys.every((k) => keys.has(k)) ||
      a.anchorFactKey !== null &&
        !a.relatedFactKeys.includes(a.anchorFactKey) ||
      new Set(a.needsUserInput).size !== a.needsUserInput.length
    ) throw new AnalysisError("invalidOutput", 502);
  }
  return data;
}
export { outputSchema };
