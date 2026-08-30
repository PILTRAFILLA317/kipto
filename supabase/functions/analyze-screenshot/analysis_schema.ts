export const ANALYSIS_SCHEMA_VERSION = 1 as const
export const ANALYSIS_PROMPT_VERSION = '1.0.0' as const

export const categories = [
  'event',
  'place',
  'product',
  'order',
  'recipe',
  'coupon',
  'conversation',
  'media',
  'meme',
  'information',
  'other',
] as const

export const intents = [
  'attend_event',
  'visit_place',
  'consider_purchase',
  'track_order',
  'cook_recipe',
  'use_coupon',
  'remember_task',
  'save_media',
  'keep_for_reference',
  'entertainment',
  'unknown',
] as const

export const suggestedActions = [
  'addCalendar',
  'createReminder',
  'openMaps',
  'openUrl',
  'webSearch',
  'copyCode',
  'trackPackage',
  'save',
  'none',
] as const

export const relevances = [
  'active',
  'expired',
  'obsolete',
  'evergreen',
  'unknown',
] as const

export const uncertainFieldNames = [
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
  'searchKeywords',
] as const

export const entityKeys = [
  'merchant',
  'productName',
  'priceText',
  'currency',
  'orderNumber',
  'trackingCode',
  'carrier',
  'couponCode',
  'discountText',
  'placeName',
  'address',
  'artist',
  'venue',
  'mediaTitle',
  'creator',
  'recipeName',
  'primaryUrl',
  'phoneNumber',
] as const

const nullableString = (maxLength: number) => ({
  type: ['string', 'null'],
  minLength: 1,
  maxLength,
})

const nullableIsoDate = {
  ...nullableString(40),
  pattern: '(?:Z|[+-][0-9]{2}:[0-9]{2})$',
}

const entityProperties = Object.fromEntries(
  entityKeys.map((key) => [key, nullableString(500)]),
)

export const screenshotAnalysisJsonSchema = {
  type: 'object',
  additionalProperties: false,
  required: [
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
  ],
  properties: {
    schemaVersion: { type: 'integer', enum: [ANALYSIS_SCHEMA_VERSION] },
    category: { type: 'string', enum: categories },
    subtype: {
      ...nullableString(48),
      pattern: '^[a-z0-9]+(?:_[a-z0-9]+)*$',
    },
    intent: { type: 'string', enum: intents },
    title: { type: 'string', minLength: 1, maxLength: 80 },
    summary: { type: 'string', minLength: 1, maxLength: 200 },
    sourceApp: nullableString(60),
    requiresAction: { type: 'boolean' },
    suggestedActions: {
      type: 'array',
      maxItems: 9,
      uniqueItems: true,
      items: { type: 'string', enum: suggestedActions },
    },
    eventAt: nullableIsoDate,
    expiresAt: nullableIsoDate,
    location: {
      type: ['object', 'null'],
      additionalProperties: false,
      required: ['name', 'address', 'city', 'country', 'query'],
      properties: {
        name: nullableString(120),
        address: nullableString(200),
        city: nullableString(100),
        country: nullableString(100),
        query: nullableString(240),
      },
    },
    entities: {
      type: 'object',
      additionalProperties: false,
      required: entityKeys,
      properties: entityProperties,
    },
    relevance: { type: 'string', enum: relevances },
    confidence: { type: 'number', minimum: 0, maximum: 1 },
    uncertainFields: {
      type: 'array',
      maxItems: 12,
      uniqueItems: true,
      items: { type: 'string', enum: uncertainFieldNames },
    },
    searchKeywords: {
      type: 'array',
      maxItems: 12,
      uniqueItems: true,
      items: { type: 'string', minLength: 1, maxLength: 60 },
    },
  },
} as const

export type ScreenshotAnalysis = {
  schemaVersion: number
  category: (typeof categories)[number]
  subtype: string | null
  intent: (typeof intents)[number]
  title: string
  summary: string
  sourceApp: string | null
  requiresAction: boolean
  suggestedActions: Array<(typeof suggestedActions)[number]>
  eventAt: string | null
  expiresAt: string | null
  location: {
    name: string | null
    address: string | null
    city: string | null
    country: string | null
    query: string | null
  } | null
  entities: Record<(typeof entityKeys)[number], string | null>
  relevance: (typeof relevances)[number]
  confidence: number
  uncertainFields: Array<(typeof uncertainFieldNames)[number]>
  searchKeywords: string[]
}
