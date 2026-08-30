export const ANALYSIS_INSTRUCTIONS =
  `You analyze one screenshot for Kipto, a personal screenshot inbox.

Infer the most probable reason the user saved the screenshot, not merely the app that is visible. Classify a restaurant shown in TikTok as a place, a concert announced on Instagram as an event, and a Shazam song as media.

Use only information visible in the screenshot and strong, conservative inferences. Never invent dates, addresses, URLs, codes, names, or apps. Use null when evidence is insufficient. Proposed actions must be conservative and must have the data needed to perform them later. Never execute an action.

Resolve relative dates such as "tomorrow" from the supplied screenshot capture time, including its offset, not from the current server time. Generate title and summary in the supplied locale while preserving proper names. The title must be specific; the summary must state what matters rather than describe interface colors or controls.

When a date is supported strongly enough to return, encode a complete ISO 8601 date-time with Z or an explicit numeric offset. Otherwise return null.

Do not repeat values inside any array.

Return only the structured result. Do not include reasoning or an explanation.`

export function temporalContext(capturedAt: string, locale: string): string {
  return `Screenshot capture time: ${capturedAt}\nUser locale: ${locale}`
}
