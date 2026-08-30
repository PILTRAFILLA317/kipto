import { analyzeWithOpenAi, responseMeta } from './openai_client.ts'
import { AnalysisHttpError, asAnalysisError, errorResponse } from './errors.ts'
import { supabaseUsageRecorder, type UsageRecorder } from './usage.ts'
import {
  type AnalyzeScreenshotRequest,
  MAX_REQUEST_BYTES,
  validateRequestBody,
} from './validation.ts'

export type AnalyzeHandlerDependencies = {
  usage: UsageRecorder
  analyze(
    request: AnalyzeScreenshotRequest,
    options: { apiKey: string; model: string; safetyIdentifier: string },
  ): ReturnType<typeof analyzeWithOpenAi>
  env(name: string): string | undefined
  now(): Date
  log(event: string, fields: Record<string, unknown>): void
}

export function defaultDependencies(
  adminClient: Parameters<typeof supabaseUsageRecorder>[0],
): AnalyzeHandlerDependencies {
  return {
    usage: supabaseUsageRecorder(adminClient),
    analyze: (request, options) => analyzeWithOpenAi(request, options),
    env: (name) => Deno.env.get(name),
    now: () => new Date(),
    log: (event, fields) => console.log(JSON.stringify({ event, ...fields })),
  }
}

export async function handleAnalyzeScreenshot(
  request: Request,
  userId: string,
  dependencies: AnalyzeHandlerDependencies,
): Promise<Response> {
  const requestId = crypto.randomUUID()
  const startedAt = dependencies.now().getTime()
  const userHash = await shortHash(userId)
  let quotaConsumed = false
  try {
    if (request.method !== 'POST') {
      throw new AnalysisHttpError(405, {
        code: 'invalid_request',
        retryable: false,
      })
    }
    const contentLength = Number.parseInt(
      request.headers.get('content-length') ?? '0',
      10,
    )
    if (Number.isFinite(contentLength) && contentLength > MAX_REQUEST_BYTES) {
      throw new AnalysisHttpError(413, {
        code: 'payload_too_large',
        retryable: false,
      })
    }
    const apiKey = dependencies.env('OPENAI_API_KEY')?.trim()
    if (!apiKey) {
      throw new AnalysisHttpError(503, {
        code: 'not_configured',
        retryable: false,
      })
    }
    const model = dependencies.env('OPENAI_MODEL')?.trim() || 'gpt-5.6-luna'
    const dailyLimit = parseDailyLimit(
      dependencies.env('ANALYSIS_DAILY_LIMIT'),
    )
    let body: unknown
    try {
      const rawBody = await request.text()
      if (new TextEncoder().encode(rawBody).byteLength > MAX_REQUEST_BYTES) {
        throw new AnalysisHttpError(413, {
          code: 'payload_too_large',
          retryable: false,
        })
      }
      body = JSON.parse(rawBody)
    } catch (error) {
      if (error instanceof AnalysisHttpError) throw error
      throw new AnalysisHttpError(400, {
        code: 'invalid_request',
        retryable: false,
      })
    }
    const validated = validateRequestBody(body)
    quotaConsumed = await dependencies.usage.consume(userId, dailyLimit)
    if (!quotaConsumed) {
      dependencies.log('analysis.quota.exceeded', {
        requestId,
        user: userHash,
      })
      throw new AnalysisHttpError(429, {
        code: 'quota_exceeded',
        retryable: true,
        retryAfterSeconds: secondsUntilNextUtcDay(dependencies.now()),
      })
    }
    dependencies.log('analysis.request.started', {
      requestId,
      user: userHash,
      model,
    })
    const result = await dependencies.analyze(validated, {
      apiKey,
      model,
      safetyIdentifier: userHash,
    })
    try {
      await dependencies.usage.record(
        userId,
        true,
        result.inputTokens,
        result.outputTokens,
      )
    } catch {
      dependencies.log('analysis.usage.failed', { requestId, user: userHash })
    }
    quotaConsumed = false
    dependencies.log('analysis.request.completed', {
      requestId,
      user: userHash,
      model,
      latencyMs: dependencies.now().getTime() - startedAt,
      inputTokens: result.inputTokens,
      outputTokens: result.outputTokens,
      status: 'completed',
    })
    return Response.json({
      ok: true,
      analysis: result.analysis,
      meta: responseMeta(model),
    })
  } catch (error) {
    const safe = asAnalysisError(error)
    if (quotaConsumed) {
      try {
        await dependencies.usage.record(userId, false, 0, 0)
      } catch {
        // Usage telemetry must not replace the original sanitized failure.
      }
    }
    dependencies.log('analysis.request.failed', {
      requestId,
      user: userHash,
      latencyMs: dependencies.now().getTime() - startedAt,
      status: 'failed',
      errorCode: safe.publicError.code,
    })
    return errorResponse(safe)
  }
}

export function parseDailyLimit(value: string | undefined): number {
  const parsed = Number.parseInt(value ?? '', 10)
  if (!Number.isFinite(parsed) || parsed < 1) return 2000
  return Math.min(parsed, 100_000)
}

function secondsUntilNextUtcDay(now: Date): number {
  const next = Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() + 1,
  )
  return Math.max(1, Math.ceil((next - now.getTime()) / 1000))
}

async function shortHash(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value)
  const digest = await crypto.subtle.digest('SHA-256', bytes)
  return Array.from(new Uint8Array(digest).slice(0, 6))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('')
}
