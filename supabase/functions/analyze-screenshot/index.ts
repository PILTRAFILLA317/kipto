import { withSupabase } from '@supabase/server'
import { defaultDependencies, handleAnalyzeScreenshot } from './handler.ts'
import { type RpcClient } from './usage.ts'

export default {
  fetch: withSupabase({ auth: 'user' }, async (request, context) => {
    const claims = context.userClaims as { id?: string; sub?: string } | null
    const userId = claims?.id ?? claims?.sub
    if (userId == null) {
      return Response.json(
        { error: { code: 'unauthorized', retryable: false } },
        { status: 401 },
      )
    }
    return await handleAnalyzeScreenshot(
      request,
      userId,
      defaultDependencies(context.supabaseAdmin as unknown as RpcClient),
    )
  }),
}
