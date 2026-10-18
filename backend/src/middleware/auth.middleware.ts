/**
 * Authentication middleware — Member 3
 *
 * `requireAuth` verifies the Bearer ACCESS token (JWT, 15-minute lifetime) and
 * attaches the authenticated user to `req.user`:
 *
 *     req.user = { id: string, role: UserRole }
 *
 * Team members: every protected route MUST start with requireAuth, e.g.
 *     router.get('/api/farmers', requireAuth, requirePermission('farmer:read'), handler);
 *
 * Expired tokens produce 401 with code TOKEN_EXPIRED so the Flutter client
 * knows to call POST /api/auth/refresh instead of logging the user out.
 */
import type { RequestHandler } from 'express';
import { eq } from 'drizzle-orm';
import { users } from '../../../database/schema/users.js';
import { db } from '../db/index.js';
import { verifyAccessToken } from '../modules/auth/token.service.js';
import { UnauthorizedError } from '../utils/errors.js';

export const requireAuth: RequestHandler = async (req, _res, next) => {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return next(new UnauthorizedError('Missing or malformed Authorization header (expected "Bearer <token>")'));
  }

  const token = header.slice('Bearer '.length).trim();
  if (!token) {
    return next(new UnauthorizedError('Missing access token'));
  }

  try {
    const payload = verifyAccessToken(token);
    const [user] = await db
      .select({ active: users.active })
      .from(users)
      .where(eq(users.id, payload.sub))
      .limit(1);

    if (!user || !user.active) {
      return next(new UnauthorizedError('Account is inactive or unavailable'));
    }

    req.user = { id: payload.sub, role: payload.role };
    return next();
  } catch (err) {
    // verifyAccessToken already throws AppError subclasses with the right codes
    // (TOKEN_EXPIRED for expired, UNAUTHENTICATED for invalid).
    return next(err);
  }
};
