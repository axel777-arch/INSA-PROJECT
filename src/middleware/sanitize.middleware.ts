/**
 * Input sanitization middleware — Member 3
 *
 * Prevents XSS and injection attacks by sanitizing request body strings.
 * This is a FIRST LINE OF DEFENSE; validation middleware (validate.middleware.ts)
 * is the PRIMARY defense via Zod schemas.
 *
 * Security principle: never trust user input. Sanitize broadly here, then
 * validate strictly in schemas.
 */
import type { RequestHandler } from 'express';

/**
 * Recursively remove dangerous characters from string values (not in objects/arrays
 * themselves, just the string values). This catches basic XSS attempts.
 */
function sanitizeValue(value: unknown): unknown {
  if (typeof value === 'string') {
    // Remove common XSS vectors without destroying legitimate content
    return value
      .replace(/<script[^>]*>.*?<\/script>/gi, '') // Remove script tags
      .replace(/on\w+\s*=/gi, '') // Remove event handlers (onclick=, onerror=, etc.)
      .replace(/<iframe[^>]*>.*?<\/iframe>/gi, '') // Remove iframes
      .trim();
  }

  if (Array.isArray(value)) {
    return value.map(sanitizeValue);
  }

  if (value && typeof value === 'object') {
    const sanitized: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value)) {
      sanitized[k] = sanitizeValue(v);
    }
    return sanitized;
  }

  return value;
}

/**
 * Sanitize the request body (and optionally query/params).
 * Applied early in the middleware stack, BEFORE validation.
 */
export const sanitize: RequestHandler = (req, _res, next) => {
  if (req.body) {
    req.body = sanitizeValue(req.body);
  }
  // Optionally sanitize query and params as well
  if (req.query) {
    req.query = sanitizeValue(req.query) as Record<string, any>;
  }
  if (req.params) {
    req.params = sanitizeValue(req.params) as Record<string, any>;
  }
  return next();
};
