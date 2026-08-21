/**
 * Auth business logic — Member 3
 *
 * register / login / refresh / logout / getMe.
 * Password hashes NEVER leave this module (see toPublicUser).
 */
import { eq } from 'drizzle-orm';
import { env } from '../../config/env.js';
import { db } from '../../db/index.js';
import { users, type UserRow } from '../../db/schema/users.js';
import { ConflictError, NotFoundError, UnauthorizedError } from '../../utils/errors.js';
import { hashPassword, verifyPassword } from './password.service.js';
import { issueRefreshToken, revokeRefreshToken, rotateRefreshToken, signAccessToken } from './token.service.js';
import type { LoginInput, RegisterInput } from './auth.schemas.js';
import type { AuthResponse, PublicUser, RequestContext, TokenPair } from './auth.types.js';

/** Strip sensitive fields before a user object leaves the backend (B25). */
export function toPublicUser(user: UserRow): PublicUser {
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    role: user.role,
    preferredLanguage: user.preferredLanguage,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}

function buildTokens(accessToken: string, refreshToken: string): TokenPair {
  return { accessToken, refreshToken, accessTokenExpiresIn: env.JWT_ACCESS_TTL };
}

export async function register(input: RegisterInput, ctx?: RequestContext): Promise<AuthResponse> {
  const existing = await db.query.users.findFirst({ where: eq(users.email, input.email) });
  if (existing) {
    throw new ConflictError('A user with this email already exists');
  }

  const passwordHash = await hashPassword(input.password);

  const [created] = await db
    .insert(users)
    .values({
      fullName: input.fullName,
      email: input.email,
      phone: input.phone ?? null,
      passwordHash,
      role: input.role, // schema already restricts this to FARMER | EXTENSION_WORKER
      preferredLanguage: input.preferredLanguage,
    })
    .returning();

  // ── TEAMMATE PLACEHOLDER (Member 4 — Farmers & Crops) ─────────────────────
  // When a FARMER registers, a farmer profile row should be created so the
  // farmer can later set region/zone/woreda/kebele. Once Member 4 delivers the
  // farmers module, uncomment and wire this up:
  //
  //   import { createFarmerProfileForUser } from '../farmers/farmer.service.js';
  //   if (created.role === 'FARMER') {
  //     await createFarmerProfileForUser(created.id);
  //   }
  //
  // Until then, POST /api/farmers (Member 4) remains the way to create the
  // farmer profile after registration.
  // ───────────────────────────────────────────────────────────────────────────

  const accessToken = signAccessToken({ id: created.id, role: created.role });
  const refreshToken = await issueRefreshToken(created.id, ctx);

  return { user: toPublicUser(created), tokens: buildTokens(accessToken, refreshToken) };
}

export async function login(input: LoginInput, ctx?: RequestContext): Promise<AuthResponse> {
  const user = await db.query.users.findFirst({ where: eq(users.email, input.email) });

  // Generic message on BOTH failure branches — prevents account enumeration (B25).
  if (!user) {
    throw new UnauthorizedError('Invalid email or password');
  }
  const passwordOk = await verifyPassword(user.passwordHash, input.password);
  if (!passwordOk) {
    throw new UnauthorizedError('Invalid email or password');
  }

  const accessToken = signAccessToken({ id: user.id, role: user.role });
  const refreshToken = await issueRefreshToken(user.id, ctx);

  return { user: toPublicUser(user), tokens: buildTokens(accessToken, refreshToken) };
}

/**
 * Exchange a refresh token for a NEW token pair (rotation — the presented
 * token is revoked). This is what keeps sessions alive past the 15-minute
 * access-token expiry.
 */
export async function refresh(presentedToken: string): Promise<AuthResponse> {
  const rotated = await rotateRefreshToken(presentedToken);
  const user = await db.query.users.findFirst({ where: eq(users.id, rotated.user.id) });
  if (!user) {
    throw new UnauthorizedError('Account no longer exists');
  }
  return {
    user: toPublicUser(user),
    tokens: buildTokens(rotated.accessToken, rotated.refreshToken),
  };
}

/** Logout = revoke the presented refresh token. Always succeeds (idempotent). */
export async function logout(presentedToken: string): Promise<void> {
  await revokeRefreshToken(presentedToken);
}

export async function getMe(userId: string): Promise<PublicUser> {
  const user = await db.query.users.findFirst({ where: eq(users.id, userId) });
  if (!user) {
    throw new NotFoundError('User');
  }
  return toPublicUser(user);
}
