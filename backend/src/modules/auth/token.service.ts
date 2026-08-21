/**
 * Token service — Member 3
 *
 * TWO-token design (team decision, JWT access + refresh pattern):
 *
 *   ACCESS TOKEN  — JWT, 15-minute lifetime (JWT_ACCESS_TTL='15m').
 *                   Stateless; verified by requireAuth on every request.
 *                   Short-lived so a leaked token quickly becomes useless.
 *
 *   REFRESH TOKEN — opaque random string, 7-day lifetime
 *                   (REFRESH_TOKEN_TTL_DAYS=7). Only its SHA-256 hash is
 *                   stored in the refresh_tokens table, so the session does
 *                   NOT terminate when the access token expires. ROTATED on
 *                   every use: the old token is revoked and a new one issued.
 *
 *   REUSE DETECTION — if a revoked (already-rotated) refresh token is
 *                   presented again, we assume theft and revoke ALL refresh
 *                   tokens for that user, forcing a fresh login.
 */
import crypto from 'node:crypto';
import jwt from 'jsonwebtoken';
import { and, eq, isNull } from 'drizzle-orm';
import { env } from '../../config/env.js';
import type { UserRole } from '../../config/constants.js';
import { db } from '../../db/index.js';
import { refreshTokens } from '../../db/schema/refresh-tokens.js';
import { users } from '../../db/schema/users.js';
import { AppError, TokenExpiredError, UnauthorizedError } from '../../utils/errors.js';

// ── Access tokens (JWT) ──────────────────────────────────────────────────────

export interface AccessTokenPayload {
  sub: string;
  role: UserRole;
  type: 'access';
}

export function signAccessToken(user: { id: string; role: UserRole }): string {
  const payload: AccessTokenPayload = { sub: user.id, role: user.role, type: 'access' };
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, {
    expiresIn: env.JWT_ACCESS_TTL as jwt.SignOptions['expiresIn'], // default: '15m'
  });
}

export function verifyAccessToken(token: string): AccessTokenPayload {
  try {
    const payload = jwt.verify(token, env.JWT_ACCESS_SECRET) as jwt.JwtPayload & AccessTokenPayload;
    if (payload.type !== 'access' || !payload.sub || !payload.role) {
      throw new UnauthorizedError('Invalid access token');
    }
    return { sub: payload.sub, role: payload.role, type: 'access' };
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      // Distinct code so the Flutter client knows to call /api/auth/refresh.
      throw new TokenExpiredError();
    }
    if (err instanceof AppError) throw err;
    throw new UnauthorizedError('Invalid access token');
  }
}

// ── Refresh tokens (opaque, DB-backed, rotating) ─────────────────────────────

function hashRefreshToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function refreshExpiryDate(): Date {
  return new Date(Date.now() + env.REFRESH_TOKEN_TTL_DAYS * 24 * 60 * 60 * 1000);
}

/** Issue a new refresh token for a user and store its hash. Returns the RAW token (send to client once). */
export async function issueRefreshToken(
  userId: string,
  ctx?: { userAgent?: string; ip?: string },
): Promise<string> {
  const token = crypto.randomBytes(48).toString('base64url');
  await db.insert(refreshTokens).values({
    userId,
    tokenHash: hashRefreshToken(token),
    expiresAt: refreshExpiryDate(),
    userAgent: ctx?.userAgent ?? null,
    ipAddress: ctx?.ip ?? null,
  });
  return token;
}

export interface RotatedTokens {
  accessToken: string;
  refreshToken: string;
  user: { id: string; role: UserRole };
}

/**
 * Rotate a refresh token: validate → revoke old → issue new + fresh access token.
 * Throws UnauthorizedError for unknown / expired / reused tokens.
 */
export async function rotateRefreshToken(presentedToken: string): Promise<RotatedTokens> {
  const tokenHash = hashRefreshToken(presentedToken);

  const existing = await db.query.refreshTokens.findFirst({
    where: eq(refreshTokens.tokenHash, tokenHash),
  });
  if (!existing) {
    throw new UnauthorizedError('Invalid refresh token');
  }

  if (existing.revokedAt) {
    // A revoked token was presented again → probable theft. Kill the session family.
    await db
      .update(refreshTokens)
      .set({ revokedAt: new Date() })
      .where(and(eq(refreshTokens.userId, existing.userId), isNull(refreshTokens.revokedAt)));
    throw new UnauthorizedError('Refresh token reuse detected — all sessions have been revoked');
  }

  if (existing.expiresAt.getTime() < Date.now()) {
    throw new UnauthorizedError('Refresh token expired — please log in again');
  }

  const user = await db.query.users.findFirst({ where: eq(users.id, existing.userId) });
  if (!user) {
    throw new UnauthorizedError('Account no longer exists');
  }

  // Issue the replacement refresh token, then mark the old one revoked.
  const newRawToken = crypto.randomBytes(48).toString('base64url');
  const [newRow] = await db
    .insert(refreshTokens)
    .values({
      userId: user.id,
      tokenHash: hashRefreshToken(newRawToken),
      expiresAt: refreshExpiryDate(),
      userAgent: existing.userAgent,
      ipAddress: existing.ipAddress,
    })
    .returning({ id: refreshTokens.id });

  await db
    .update(refreshTokens)
    .set({ revokedAt: new Date(), replacedByTokenId: newRow.id })
    .where(eq(refreshTokens.id, existing.id));

  return {
    accessToken: signAccessToken({ id: user.id, role: user.role }),
    refreshToken: newRawToken,
    user: { id: user.id, role: user.role },
  };
}

/** Revoke a single refresh token (logout). Idempotent — never throws for unknown tokens. */
export async function revokeRefreshToken(presentedToken: string): Promise<void> {
  await db
    .update(refreshTokens)
    .set({ revokedAt: new Date() })
    .where(and(eq(refreshTokens.tokenHash, hashRefreshToken(presentedToken)), isNull(refreshTokens.revokedAt)));
}

/** Revoke every active refresh token for a user (e.g. password change, admin action). */
export async function revokeAllRefreshTokensForUser(userId: string): Promise<void> {
  await db
    .update(refreshTokens)
    .set({ revokedAt: new Date() })
    .where(and(eq(refreshTokens.userId, userId), isNull(refreshTokens.revokedAt)));
}
