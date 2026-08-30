export type UsageRecorder = {
  consume(userId: string, limit: number): Promise<boolean>
  record(
    userId: string,
    success: boolean,
    inputTokens: number,
    outputTokens: number,
  ): Promise<void>
}

export type RpcClient = {
  rpc(
    functionName: string,
    parameters: Record<string, unknown>,
  ): Promise<{ data: unknown; error: unknown }>
}

export function supabaseUsageRecorder(client: RpcClient): UsageRecorder {
  return {
    async consume(userId, limit) {
      const { data, error } = await client.rpc('kipto_consume_analysis_quota', {
        p_user_id: userId,
        p_limit: limit,
      })
      if (error != null) throw new Error('quota_rpc_failed')
      return data === true
    },
    async record(userId, success, inputTokens, outputTokens) {
      const { error } = await client.rpc('kipto_record_analysis_usage', {
        p_user_id: userId,
        p_success: success,
        p_input_tokens: inputTokens,
        p_output_tokens: outputTokens,
      })
      if (error != null) throw new Error('usage_rpc_failed')
    },
  }
}
