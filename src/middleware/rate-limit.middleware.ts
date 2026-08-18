/**
 * Rate limiting — Member 3
 *
 * Team decision: 5 login attempts per 15 minutes per IP; registration capped
 * separately. Limits are configurable via env so tests can raise them.
 */
import rateLimit from 'express-rate-limit';
import { env } from '../config/env.js';

const tooMany = (retryMinutes: number) => ({
  error: {
    code: 'RATE_LIMITED',
    message: 'Too many attempts. Please try again later.',
    details: [{ retryAfterMinutes: retryMinutes }],
  },
});

/** Login brute-force protection (analysis §2c). Mounted on POST /api/auth/login. */
export const loginLimiter = rateLimit({
  windowMs: env.AUTH_RATE_LIMIT_WINDOW_MINUTES * 60 * 1000,
  max: env.AUTH_RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => res.status(429).json(tooMany(env.AUTH_RATE_LIMIT_WINDOW_MINUTES)),
});

/** Registration flood protection. Mounted on POST /api/auth/register. */
export const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => res.status(429).json(tooMany(60)),
});
