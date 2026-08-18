/**
 * CSRF protection middleware — Member 3
 *
 * Simple CSRF protection for stateless APIs using the double-submit cookie pattern:
 * - Client reads CSRF token from a response header or body
 * - Client includes it in the X-CSRF-Token header on all state-changing requests
 * - Server verifies token matches the one in cookies
 *
 * For mobile/Flutter clients: use Bearer tokens in Authorization header
 * (your JWT access tokens serve as CSRF protection because they cannot be
 * automatically sent by a malicious website). This middleware is more for
 * browser-based clients that might be vulnerable to CSRF.
 *
 * Team decision: Apply to POST/PUT/DELETE routes that are not API-only.
 * For pure mobile APIs (which is your case), this is OPTIONAL but recommended
 * as a defense-in-depth layer.
 */
import crypto from 'node:crypto';
import type { RequestHandler } from 'express';

const CSRF_TOKEN_LENGTH = 32;
const CSRF_COOKIE_NAME = 'X-CSRF-Token';
const CSRF_HEADER_NAME = 'X-CSRF-Token';

/**
 * Generate a CSRF token.
 */
export function generateCsrfToken(): string {
  return crypto.randomBytes(CSRF_TOKEN_LENGTH).toString('hex');
}

/**
 * Middleware to set CSRF token in cookies (safe to do on GET requests).
 * Attach this to GET endpoints that precede form submission or API calls.
 */
export const csrfSetCookie: RequestHandler = (req, res, next) => {
  // Check if already set in cookies
  const existing = req.cookies?.[CSRF_COOKIE_NAME];
  if (!existing) {
    const token = generateCsrfToken();
    res.cookie(CSRF_COOKIE_NAME, token, {
      httpOnly: false, // Must be readable by JavaScript to send in header
      secure: process.env.NODE_ENV === 'production', // HTTPS only in production
      sameSite: 'strict',
      maxAge: 24 * 60 * 60 * 1000, // 24 hours
    });
  }
  return next();
};

/**
 * Middleware to VERIFY CSRF token on state-changing requests (POST/PUT/DELETE).
 * Checks that the X-CSRF-Token header matches the cookie.
 */
export const csrfVerify: RequestHandler = (req, res, next) => {
  // Only protect state-changing methods
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  // Allow requests with valid Bearer tokens (JWT) to bypass CSRF check
  // (mobile clients using JWT don't need CSRF protection)
  const auth = req.headers.authorization;
  if (auth && auth.startsWith('Bearer ')) {
    return next();
  }

  // For browser-based clients (form submissions), verify CSRF token
  const tokenFromCookie = req.cookies?.[CSRF_COOKIE_NAME];
  const tokenFromHeader = req.headers[CSRF_HEADER_NAME.toLowerCase()] as string | undefined;

  if (!tokenFromCookie || !tokenFromHeader || tokenFromCookie !== tokenFromHeader) {
    return res.status(403).json({
      error: {
        code: 'CSRF_TOKEN_INVALID',
        message: 'Invalid CSRF token',
        details: [],
      },
    });
  }

  return next();
};
