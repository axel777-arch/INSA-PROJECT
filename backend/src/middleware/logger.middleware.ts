/**
 * Request / response logger middleware
 *
 * Prints structured, human-readable lines for every API call so the
 * presentation team can demonstrate the full chain:
 *
 *   Flutter button → API REQUEST → Controller → Service → DB → API RESPONSE
 *
 * Sensitive fields (passwords, tokens) are NEVER logged.
 */
import type { Request, Response, NextFunction } from 'express';

function timestamp(): string {
  return new Date().toISOString();
}

/** Redact keys that must never appear in logs. */
function redactBody(body: unknown): unknown {
  if (!body || typeof body !== 'object') return body;
  const safe = { ...(body as Record<string, unknown>) };
  for (const key of ['password', 'passwordHash', 'token', 'refreshToken', 'accessToken']) {
    if (key in safe) safe[key] = '[REDACTED]';
  }
  return safe;
}

export function requestLogger(req: Request, res: Response, next: NextFunction): void {
  const start = Date.now();
  const { method, originalUrl } = req;

  // Log the incoming request
  console.log(`\n[API REQUEST]  ${timestamp()}`);
  console.log(`  ${method} ${originalUrl}`);
  if (req.user) {
    console.log(`  Auth: userId=${req.user.id}  role=${req.user.role}`);
  }
  if (req.body && Object.keys(req.body).length > 0) {
    console.log(`  Body: ${JSON.stringify(redactBody(req.body))}`);
  }

  // Intercept res.end to log the response status
  const originalEnd = res.end.bind(res);
  (res as any).end = function (...args: Parameters<typeof res.end>) {
    const duration = Date.now() - start;
    const statusCode = res.statusCode;
    const levelTag = statusCode >= 500 ? '[API ERROR]  ' : statusCode >= 400 ? '[API WARN]   ' : '[API RESPONSE]';
    console.log(`${levelTag} ${method} ${originalUrl} → ${statusCode} (${duration}ms)`);
    return originalEnd(...args);
  };

  next();
}
