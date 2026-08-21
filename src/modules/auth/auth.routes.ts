/**
 * Auth routes — Member 3
 *
 *   POST /api/auth/register   (rate-limited, validated)       → 201 { user, tokens }
 *   POST /api/auth/login      (rate-limited 5/15min, validated)→ 200 { user, tokens }
 *   POST /api/auth/refresh    (validated)                     → 200 { user, tokens }  (rotation)
 *   POST /api/auth/logout     (validated)                     → 200 { message }
 *   GET  /api/auth/me         (requireAuth)                   → 200 { user }
 */
import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.middleware.js';
import { loginLimiter, registerLimiter } from '../../middleware/rate-limit.middleware.js';
import { validate } from '../../middleware/validate.middleware.js';
import { loginSchema, refreshTokenSchema, registerSchema } from './auth.schemas.js';
import { loginHandler, logoutHandler, meHandler, refreshHandler, registerHandler } from './auth.controller.js';

const authRouter = Router();

authRouter.post('/register', registerLimiter, validate({ body: registerSchema }), registerHandler);
authRouter.post('/login', loginLimiter, validate({ body: loginSchema }), loginHandler);
authRouter.post('/refresh', validate({ body: refreshTokenSchema }), refreshHandler);
authRouter.post('/logout', validate({ body: refreshTokenSchema }), logoutHandler);
authRouter.get('/me', requireAuth, meHandler);

export default authRouter;
