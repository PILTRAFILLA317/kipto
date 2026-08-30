import {
  ANALYSIS_PROMPT_VERSION,
  ANALYSIS_SCHEMA_VERSION,
  type ScreenshotAnalysis,
  screenshotAnalysisJsonSchema,
} from './analysis_schema.ts'
import { ANALYSIS_INSTRUCTIONS, temporalContext } from './analysis_prompt.ts'
import {
  type AnalysisErrorDiagnostics,
  AnalysisHttpError,
} from './errors.ts'
import { type AnalyzeScreenshotRequest, validateAnalysis } from './validation.ts'

export type OpenAiAnalysisResult = {
  analysis: ScreenshotAnalysis
  inputTokens: number
  outputTokens: number
}

export type OpenAiFetch = typeof fetch

export async function analyzeWithOpenAi(
  request: AnalyzeScreenshotRequest,
  options: {
    apiKey: string
    model: string
    safetyIdentifier: string
    fetcher?: OpenAiFetch
    timeoutMs?: number
  },
): Promise<OpenAiAnalysisResult> {
  const fetcher = options.fetcher ?? fetch
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), options.timeoutMs ?? 40_000)
  let response: Response
  try {
    response = await fetcher('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        authorization: `Bearer ${options.apiKey}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: options.model,
        store: false,
        instructions: ANALYSIS_INSTRUCTIONS,
        reasoning: { effort: 'low' },
        max_output_tokens: 1800,
        safety_identifier: options.safetyIdentifier,
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: temporalContext(request.capturedAt, request.locale),
              },
              {
                type: 'input_image',
                image_url: `data:${request.mimeType};base64,${request.imageBase64}`,
                detail: 'high',
              },
            ],
          },
        ],
        text: {
          format: {
            type: 'json_schema',
            name: 'kipto_screenshot_analysis',
            strict: true,
            schema: screenshotAnalysisJsonSchema,
          },
        },
      }),
      signal: controller.signal,
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new AnalysisHttpError(504, {
        code: 'upstream_timeout',
        retryable: true,
      })
    }
    throw new AnalysisHttpError(503, {
      code: 'network',
      retryable: true,
    })
  } finally {
    clearTimeout(timeout)
  }

  if (!response.ok) {
    const retryAfter = retryAfterSeconds(response.headers.get('retry-after'))
    const diagnostics = await providerErrorDiagnostics(response)
    if (response.status === 429) {
      throw new AnalysisHttpError(
        429,
        {
          code: 'rate_limited',
          retryable: true,
          ...(retryAfter == null ? {} : { retryAfterSeconds: retryAfter }),
        },
        diagnostics,
      )
    }
    if (response.status === 408 || response.status >= 500) {
      throw new AnalysisHttpError(
        502,
        {
          code: response.status === 408 ? 'upstream_timeout' : 'server_error',
          retryable: true,
        },
        diagnostics,
      )
    }
    throw new AnalysisHttpError(
      502,
      {
        code: 'invalid_response',
        retryable: false,
      },
      diagnostics,
    )
  }

  let payload: Record<string, unknown>
  try {
    payload = (await response.json()) as Record<string, unknown>
  } catch {
    throw invalidResponse()
  }
  if (payload.status === 'incomplete') {
    throw new AnalysisHttpError(502, {
      code: 'invalid_response',
      retryable: true,
    })
  }
  if (payload.status === 'failed' || payload.error != null) {
    throw new AnalysisHttpError(502, {
      code: 'server_error',
      retryable: true,
    })
  }
  if (payload.status !== 'completed') throw invalidResponse()

  let outputText: string | null = typeof payload.output_text === 'string'
    ? payload.output_text
    : null
  const output = Array.isArray(payload.output) ? payload.output : []
  for (const item of output) {
    if (!isRecord(item) || item.type !== 'message') continue
    const content = Array.isArray(item.content) ? item.content : []
    for (const part of content) {
      if (!isRecord(part)) continue
      if (part.type === 'refusal') {
        throw new AnalysisHttpError(422, {
          code: 'refused',
          retryable: false,
        })
      }
      if (part.type === 'output_text' && typeof part.text === 'string') {
        outputText = part.text
      }
    }
  }
  if (outputText == null) throw invalidResponse()
  let decoded: unknown
  try {
    decoded = JSON.parse(outputText)
  } catch {
    throw invalidResponse()
  }
  const usage = isRecord(payload.usage) ? payload.usage : {}
  return {
    analysis: validateAnalysis(decoded),
    inputTokens: safeTokenCount(usage.input_tokens),
    outputTokens: safeTokenCount(usage.output_tokens),
  }
}

export const responseMeta = (model: string) => ({
  schemaVersion: ANALYSIS_SCHEMA_VERSION,
  promptVersion: ANALYSIS_PROMPT_VERSION,
  model,
})

function safeTokenCount(value: unknown): number {
  return typeof value === 'number' && Number.isInteger(value) && value >= 0 ? value : 0
}

function retryAfterSeconds(value: string | null): number | undefined {
  if (value == null) return undefined
  const parsed = Number.parseInt(value, 10)
  return Number.isFinite(parsed) && parsed > 0 ? Math.min(parsed, 86_400) : undefined
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

async function providerErrorDiagnostics(
  response: Response,
): Promise<AnalysisErrorDiagnostics> {
  const diagnostics: AnalysisErrorDiagnostics = {
    providerStatus: response.status,
  }
  try {
    const payload: unknown = await response.json()
    if (!isRecord(payload) || !isRecord(payload.error)) return diagnostics
    const code = safeDiagnosticValue(payload.error.code)
    const type = safeDiagnosticValue(payload.error.type)
    const param = safeDiagnosticValue(payload.error.param)
    if (code != null) diagnostics.providerCode = code
    if (type != null) diagnostics.providerType = type
    if (param != null) diagnostics.providerParam = param
  } catch {
    // HTTP status is enough when the provider body is absent or malformed.
  }
  return diagnostics
}

function safeDiagnosticValue(value: unknown): string | null {
  if (typeof value !== 'string' || value.length > 120) return null
  return /^[A-Za-z0-9_.\-[\]]+$/.test(value) ? value : null
}

function invalidResponse(): AnalysisHttpError {
  return new AnalysisHttpError(502, {
    code: 'invalid_response',
    retryable: true,
  })
}
