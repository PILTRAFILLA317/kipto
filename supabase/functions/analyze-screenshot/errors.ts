export type PublicAnalysisError = {
  code: string
  retryable: boolean
  retryAfterSeconds?: number
}

export class AnalysisHttpError extends Error {
  constructor(
    readonly status: number,
    readonly publicError: PublicAnalysisError,
  ) {
    super(publicError.code)
  }
}

export function errorResponse(error: AnalysisHttpError): Response {
  const headers = new Headers({ 'content-type': 'application/json' })
  if (error.publicError.retryAfterSeconds != null) {
    headers.set('retry-after', String(error.publicError.retryAfterSeconds))
  }
  return new Response(JSON.stringify({ error: error.publicError }), {
    status: error.status,
    headers,
  })
}

export function asAnalysisError(error: unknown): AnalysisHttpError {
  if (error instanceof AnalysisHttpError) return error
  return new AnalysisHttpError(500, {
    code: 'server_error',
    retryable: true,
  })
}
