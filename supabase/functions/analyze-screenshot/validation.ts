import {
  ANALYSIS_SCHEMA_VERSION,
  categories,
  entityKeys,
  intents,
  relevances,
  type ScreenshotAnalysis,
  suggestedActions,
  uncertainFieldNames,
} from './analysis_schema.ts'
import { AnalysisHttpError } from './errors.ts'

export const MAX_IMAGE_BYTES = 4_000_000
export const MAX_REQUEST_BYTES = 5_700_000
export const acceptedMimeTypes = [
  'image/jpeg',
  'image/png',
  'image/webp',
] as const

export type AnalyzeScreenshotRequest = {
  requestVersion: 1
  imageBase64: string
  mimeType: (typeof acceptedMimeTypes)[number]
  capturedAt: string
  locale: string
}

export function validateRequestBody(value: unknown): AnalyzeScreenshotRequest {
  const body = object(value)
  const allowed = new Set([
    'requestVersion',
    'imageBase64',
    'mimeType',
    'capturedAt',
    'locale',
  ])
  if (Object.keys(body).some((key) => !allowed.has(key))) invalidRequest()
  if (body.requestVersion !== 1) invalidRequest()
  const imageBase64 = string(body.imageBase64, 1, 5_400_000)
  const mimeType = string(body.mimeType, 1, 20)
  if (!includes(acceptedMimeTypes, mimeType)) invalidImage()
  const capturedAt = string(body.capturedAt, 10, 40)
  const capturedDate = new Date(capturedAt)
  if (Number.isNaN(capturedDate.getTime()) || !hasExplicitOffset(capturedAt)) {
    invalidRequest()
  }
  const locale = string(body.locale, 2, 35)
  if (!/^[A-Za-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$/.test(locale)) {
    invalidRequest()
  }
  validateBase64Image(imageBase64, mimeType)
  return {
    requestVersion: 1,
    imageBase64,
    mimeType: mimeType as AnalyzeScreenshotRequest['mimeType'],
    capturedAt,
    locale,
  }
}

export function validateBase64Image(imageBase64: string, mimeType: string): void {
  if (
    imageBase64.length % 4 !== 0 ||
    !/^[A-Za-z0-9+/]+={0,2}$/.test(imageBase64)
  ) {
    invalidImage()
  }
  const padding = imageBase64.endsWith('==') ? 2 : imageBase64.endsWith('=') ? 1 : 0
  const decodedLength = (imageBase64.length * 3) / 4 - padding
  if (decodedLength <= 0) invalidImage()
  if (decodedLength > MAX_IMAGE_BYTES) {
    throw new AnalysisHttpError(413, {
      code: 'payload_too_large',
      retryable: false,
    })
  }
  let prefix: Uint8Array
  try {
    const decoded = atob(imageBase64.slice(0, 32))
    prefix = Uint8Array.from(decoded, (character) => character.charCodeAt(0))
  } catch {
    invalidImage()
  }
  const detected = detectMime(prefix!)
  if (detected == null || detected !== mimeType) invalidImage()
}

export function validateAnalysis(value: unknown): ScreenshotAnalysis {
  const result = analysisObject(value)
  if (result.schemaVersion !== ANALYSIS_SCHEMA_VERSION) invalidResponse()
  enumValue(result.category, categories)
  nullableSnakeCase(result.subtype, 48)
  enumValue(result.intent, intents)
  analysisString(result.title, 1, 80)
  analysisString(result.summary, 1, 200)
  nullableString(result.sourceApp, 60)
  if (typeof result.requiresAction !== 'boolean') invalidResponse()
  enumArray(result.suggestedActions, suggestedActions, 9)
  nullableDate(result.eventAt)
  nullableDate(result.expiresAt)
  if (result.location !== null) {
    const location = analysisObject(result.location)
    exactKeys(location, ['name', 'address', 'city', 'country', 'query'])
    nullableString(location.name, 120)
    nullableString(location.address, 200)
    nullableString(location.city, 100)
    nullableString(location.country, 100)
    nullableString(location.query, 240)
  }
  const entities = analysisObject(result.entities)
  exactKeys(entities, entityKeys)
  for (const key of entityKeys) nullableString(entities[key], 500)
  enumValue(result.relevance, relevances)
  if (
    typeof result.confidence !== 'number' ||
    !Number.isFinite(result.confidence) ||
    result.confidence < 0 ||
    result.confidence > 1
  ) {
    invalidResponse()
  }
  enumArray(result.uncertainFields, uncertainFieldNames, 12)
  stringArray(result.searchKeywords, 12, 60)
  exactKeys(result, [
    'schemaVersion',
    'category',
    'subtype',
    'intent',
    'title',
    'summary',
    'sourceApp',
    'requiresAction',
    'suggestedActions',
    'eventAt',
    'expiresAt',
    'location',
    'entities',
    'relevance',
    'confidence',
    'uncertainFields',
    'searchKeywords',
  ])
  return result as ScreenshotAnalysis
}

function detectMime(bytes: Uint8Array): string | null {
  if (bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) {
    return 'image/jpeg'
  }
  if (
    bytes[0] === 0x89 &&
    bytes[1] === 0x50 &&
    bytes[2] === 0x4e &&
    bytes[3] === 0x47
  ) {
    return 'image/png'
  }
  const ascii = String.fromCharCode(...bytes)
  if (ascii.startsWith('RIFF') && ascii.slice(8, 12) === 'WEBP') {
    return 'image/webp'
  }
  return null
}

function hasExplicitOffset(value: string): boolean {
  return /(?:Z|[+-]\d{2}:\d{2})$/.test(value)
}

function object(value: unknown): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    invalidRequest()
  }
  return value as Record<string, unknown>
}

function analysisObject(value: unknown): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    invalidResponse()
  }
  return value as Record<string, unknown>
}

function exactKeys(
  value: Record<string, unknown>,
  keys: readonly string[],
): void {
  const actual = Object.keys(value)
  if (actual.length !== keys.length || keys.some((key) => !(key in value))) {
    invalidResponse()
  }
}

function string(
  value: unknown,
  minimum: number,
  maximum: number,
): string {
  if (
    typeof value !== 'string' ||
    value.trim().length < minimum ||
    value.length > maximum
  ) {
    invalidRequest()
  }
  return value
}

function analysisString(
  value: unknown,
  minimum: number,
  maximum: number,
): string {
  if (
    typeof value !== 'string' ||
    value.trim().length < minimum ||
    value.length > maximum
  ) {
    invalidResponse()
  }
  return value
}

function nullableString(value: unknown, maximum: number): void {
  if (value === null) return
  if (
    typeof value !== 'string' ||
    value.trim().length === 0 ||
    value.length > maximum
  ) invalidResponse()
}

function nullableSnakeCase(value: unknown, maximum: number): void {
  nullableString(value, maximum)
  if (value !== null && !/^[a-z0-9]+(?:_[a-z0-9]+)*$/.test(value as string)) {
    invalidResponse()
  }
}

function nullableDate(value: unknown): void {
  if (value === null) return
  if (
    typeof value !== 'string' ||
    value.length > 40 ||
    Number.isNaN(new Date(value).getTime()) ||
    !hasExplicitOffset(value)
  ) {
    invalidResponse()
  }
}

function enumValue<T extends string>(value: unknown, values: readonly T[]): T {
  if (typeof value !== 'string' || !includes(values, value)) invalidResponse()
  return value as T
}

function enumArray<T extends string>(
  value: unknown,
  values: readonly T[],
  maximum: number,
): void {
  if (!Array.isArray(value) || value.length > maximum) invalidResponse()
  const seen = new Set<string>()
  for (const item of value) {
    const parsed = enumValue(item, values)
    if (seen.has(parsed)) invalidResponse()
    seen.add(parsed)
  }
}

function stringArray(value: unknown, maximum: number, maxLength: number): void {
  if (!Array.isArray(value) || value.length > maximum) invalidResponse()
  const seen = new Set<string>()
  for (const item of value) {
    if (typeof item !== 'string' || item.trim() === '' || item.length > maxLength) {
      invalidResponse()
    }
    if (seen.has(item)) invalidResponse()
    seen.add(item)
  }
}

function includes<T extends string>(values: readonly T[], value: string): boolean {
  return values.includes(value as T)
}

function invalidRequest(): never {
  throw new AnalysisHttpError(400, {
    code: 'invalid_request',
    retryable: false,
  })
}

function invalidImage(): never {
  throw new AnalysisHttpError(400, {
    code: 'invalid_image',
    retryable: false,
  })
}

function invalidResponse(): never {
  throw new AnalysisHttpError(502, {
    code: 'invalid_response',
    retryable: true,
  })
}
