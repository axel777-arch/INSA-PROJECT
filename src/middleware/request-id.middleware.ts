/**
 * Request ID and correlation tracking middleware — Member 3
 *
 * Assigns a unique ID to every request for:
 * - Tracing requests through logs
 * - Debugging and monitoring
 * - Security auditing and forensics
 *
 * The request ID is attached to:
 * - res.locals.requestId (for use in handlers/middleware)
 * - X-Request-ID response header (for client correlation)
 */
import crypto from 'node:crypto';
import type { RequestHandler } from 'express';

export function generateRequestId(): string {
  return crypto.randomBytes(8).toString('hex');
}

export const requestIdMiddleware: RequestHandler = (req, res, next) => {
  // Check for existing request ID (from load balancer, proxy, etc.)
  const existingId = (req.headers['x-request-id'] as string) || (req.headers['x-correlation-id'] as string);
  const requestId = existingId || generateRequestId();

  // Attach to res.locals for access throughout request lifecycle
  res.locals.requestId = requestId;

  // Add to response header for client to track
  res.set('X-Request-ID', requestId);

  // Optionally extend logger to include requestId in all logs for this request
  // (if you have a logger instance passed in middleware or stored in res.locals)

  return next();
};
