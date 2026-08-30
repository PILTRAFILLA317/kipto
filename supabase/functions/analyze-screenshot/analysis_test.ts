import { entityKeys, type ScreenshotAnalysis } from './analysis_schema.ts'
import { handleAnalyzeScreenshot, parseDailyLimit } from './handler.ts'
import { analyzeWithOpenAi } from './openai_client.ts'
import { type UsageRecorder } from './usage.ts'
import { validateAnalysis, validateRequestBody } from './validation.ts'

const jpegBase64 = '/9j/AA=='

const entities = Object.fromEntries(
  entityKeys.map((key) => [key, null]),
) as ScreenshotAnalysis['entities']

const validAnalysis: ScreenshotAnalysis = {
  schemaVersion: 1,
  category: 'event',
  subtype: 'concert',
  intent: 'attend_event',
  title: 'Coldplay — Music of the Spheres',
  summary: 'Concierto de Coldplay en Madrid el 18 de septiembre.',
  sourceApp: 'Instagram',
  requiresAction: true,
  suggestedActions: ['addCalendar'],
  eventAt: '2026-09-18T20:00:00+02:00',
  expiresAt: null,
  location: {
    name: 'Estadio Metropolitano',
    address: null,
    city: 'Madrid',
    country: 'España',
    query: 'Estadio Metropolitano Madrid',
  },
  entities,
  relevance: 'active',
  confidence: 0.94,
  uncertainFields: [],
  searchKeywords: ['coldplay', 'madrid', 'concert'],
}

Deno.test('request validation checks version, MIME, size, base64, and magic bytes', () => {
  const request = validateRequestBody(validRequest())
  assertEquals(request.mimeType, 'image/jpeg')
  assertThrows(() => validateRequestBody({ ...validRequest(), mimeType: 'image/png' }))
  assertThrows(() =>
    validateRequestBody({ ...validRequest(), imageBase64: 'not-base64' })
  )
  assertThrows(() => validateRequestBody({ ...validRequest(), requestVersion: 2 }))
  assertThrowsCode(
    () =>
      validateRequestBody({
        ...validRequest(),
        imageBase64: 'A'.repeat(5_400_000),
      }),
    'payload_too_large',
  )
})

Deno.test('runtime analysis validation rejects invented enum values and shape', () => {
  assertEquals(validateAnalysis(validAnalysis).category, 'event')
  assertThrows(() => validateAnalysis({ ...validAnalysis, category: 'social_media' }))
  assertThrows(() => validateAnalysis({ ...validAnalysis, confidence: 1.5 }))
  assertThrows(() =>
    validateAnalysis({ ...validAnalysis, eventAt: '2026-09-18T20:00:00' })
  )
  assertThrows(() => validateAnalysis({ ...validAnalysis, extra: 'not allowed' }))
})

Deno.test('OpenAI mapping uses Responses image input and strict schema', async () => {
  let sent: Record<string, unknown> = {}
  const result = await analyzeWithOpenAi(validateRequestBody(validRequest()), {
    apiKey: 'test-key',
    model: 'gpt-5.6-luna',
    safetyIdentifier: 'hashed-user',
    fetcher: (_url, init) => {
      sent = JSON.parse(String(init?.body)) as Record<string, unknown>
      return Promise.resolve(
        Response.json({
          status: 'completed',
          output: [
            {
              type: 'message',
              content: [
                { type: 'output_text', text: JSON.stringify(validAnalysis) },
              ],
            },
          ],
          usage: { input_tokens: 210, output_tokens: 95 },
        }),
      )
    },
  })
  assertEquals(result.analysis.title, validAnalysis.title)
  assertEquals(result.inputTokens, 210)
  assertEquals(sent.store, false)
  assertEquals((sent.reasoning as Record<string, unknown>).effort, 'low')
  const text = sent.text as Record<string, unknown>
  const format = text.format as Record<string, unknown>
  assertEquals(format.type, 'json_schema')
  assertEquals(format.strict, true)
  assert(!('tools' in sent), 'No tools may be sent')
})

Deno.test('OpenAI refusal, invalid output, and 429 become typed safe errors', async () => {
  await assertRejects(
    () =>
      analyzeWithOpenAi(validateRequestBody(validRequest()), {
        apiKey: 'test',
        model: 'gpt-5.6-luna',
        safetyIdentifier: 'hash',
        fetcher: () =>
          Promise.resolve(Response.json({
            status: 'completed',
            output: [{
              type: 'message',
              content: [{ type: 'refusal', refusal: 'no' }],
            }],
          })),
      }),
    'refused',
  )
  await assertRejects(
    () =>
      analyzeWithOpenAi(validateRequestBody(validRequest()), {
        apiKey: 'test',
        model: 'gpt-5.6-luna',
        safetyIdentifier: 'hash',
        fetcher: () =>
          Promise.resolve(Response.json({
            status: 'completed',
            output: [{
              type: 'message',
              content: [{ type: 'output_text', text: '{}' }],
            }],
          })),
      }),
    'invalid_response',
  )
  await assertRejects(
    () =>
      analyzeWithOpenAi(validateRequestBody(validRequest()), {
        apiKey: 'test',
        model: 'gpt-5.6-luna',
        safetyIdentifier: 'hash',
        fetcher: () =>
          Promise.resolve(
            new Response('', {
              status: 429,
              headers: { 'retry-after': '30' },
            }),
          ),
      }),
    'rate_limited',
  )
  await assertRejects(
    () =>
      analyzeWithOpenAi(validateRequestBody(validRequest()), {
        apiKey: 'test',
        model: 'gpt-5.6-luna',
        safetyIdentifier: 'hash',
        fetcher: () => Promise.resolve(new Response('', { status: 503 })),
      }),
    'server_error',
  )
})

Deno.test('handler enforces atomic quota dependency and aggregates usage', async () => {
  const usage = new FakeUsage(true)
  const response = await handleAnalyzeScreenshot(
    request(),
    '00000000-0000-4000-8000-000000000001',
    {
      usage,
      analyze: () =>
        Promise.resolve({
          analysis: validAnalysis,
          inputTokens: 20,
          outputTokens: 10,
        }),
      env: (name) => name === 'OPENAI_API_KEY' ? 'configured' : undefined,
      now: () => new Date('2026-08-30T12:00:00Z'),
      log: () => {},
    },
  )
  assertEquals(response.status, 200)
  assertEquals(usage.consumeCalls, 1)
  assertEquals(usage.records[0], [true, 20, 10])

  const denied = new FakeUsage(false)
  const deniedResponse = await handleAnalyzeScreenshot(
    request(),
    '00000000-0000-4000-8000-000000000001',
    {
      usage: denied,
      analyze: () => Promise.reject(new Error('must not run')),
      env: (name) => name === 'OPENAI_API_KEY' ? 'configured' : undefined,
      now: () => new Date('2026-08-30T12:00:00Z'),
      log: () => {},
    },
  )
  assertEquals(deniedResponse.status, 429)
  assertEquals(denied.records.length, 0)

  const failed = new FakeUsage(true)
  const failedResponse = await handleAnalyzeScreenshot(
    request(),
    '00000000-0000-4000-8000-000000000001',
    {
      usage: failed,
      analyze: () => Promise.reject(new Error('provider detail')),
      env: (name) => name === 'OPENAI_API_KEY' ? 'configured' : undefined,
      now: () => new Date('2026-08-30T12:00:00Z'),
      log: () => {},
    },
  )
  assertEquals(failedResponse.status, 500)
  assertEquals(failed.records[0], [false, 0, 0])
})

Deno.test('configuration defaults are bounded and missing OpenAI is explicit', async () => {
  assertEquals(parseDailyLimit(undefined), 2000)
  assertEquals(parseDailyLimit('999999999'), 100000)
  const response = await handleAnalyzeScreenshot(
    request(),
    '00000000-0000-4000-8000-000000000001',
    {
      usage: new FakeUsage(true),
      analyze: () =>
        Promise.resolve({
          analysis: validAnalysis,
          inputTokens: 0,
          outputTokens: 0,
        }),
      env: () => undefined,
      now: () => new Date('2026-08-30T12:00:00Z'),
      log: () => {},
    },
  )
  assertEquals(response.status, 503)
  assert((await response.text()).includes('not_configured'))
})

class FakeUsage implements UsageRecorder {
  constructor(private readonly allowed: boolean) {}
  consumeCalls = 0
  records: Array<[boolean, number, number]> = []

  consume(): Promise<boolean> {
    this.consumeCalls++
    return Promise.resolve(this.allowed)
  }

  record(
    _userId: string,
    success: boolean,
    inputTokens: number,
    outputTokens: number,
  ): Promise<void> {
    this.records.push([success, inputTokens, outputTokens])
    return Promise.resolve()
  }
}

function validRequest(): Record<string, unknown> {
  return {
    requestVersion: 1,
    imageBase64: jpegBase64,
    mimeType: 'image/jpeg',
    capturedAt: '2026-08-29T18:32:00+01:00',
    locale: 'es-ES',
  }
}

function request(): Request {
  return new Request('http://localhost/analyze-screenshot', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(validRequest()),
  })
}

function assert(value: unknown, message = 'Assertion failed'): asserts value {
  if (!value) throw new Error(message)
}

function assertEquals(actual: unknown, expected: unknown): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(`Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`)
  }
}

function assertThrows(operation: () => unknown): void {
  let threw = false
  try {
    operation()
  } catch {
    threw = true
  }
  assert(threw, 'Expected operation to throw')
}

function assertThrowsCode(operation: () => unknown, expectedCode: string): void {
  try {
    operation()
  } catch (error) {
    assert(
      error instanceof Error && error.message === expectedCode,
      `Expected ${expectedCode}, got ${String(error)}`,
    )
    return
  }
  throw new Error('Expected operation to throw')
}

async function assertRejects(
  operation: () => Promise<unknown>,
  expectedCode: string,
): Promise<void> {
  try {
    await operation()
  } catch (error) {
    assert(
      error instanceof Error && error.message === expectedCode,
      `Expected ${expectedCode}, got ${String(error)}`,
    )
    return
  }
  throw new Error('Expected promise to reject')
}
