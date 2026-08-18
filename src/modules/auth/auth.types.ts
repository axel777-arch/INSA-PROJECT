/**
 * Auth module types — Member 3
 *
 * These types ARE the mobile API contract (Member 2 builds Dart models from
 * them — see docs/authentication-contract.md). Changing them is an API
 * contract change: announce it and update the docs.
 */
import type { UserRole } from '../../config/constants.js';

/** User shape safe to send to clients — NEVER includes passwordHash. */
export interface PublicUser {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  role: UserRole;
  preferredLanguage: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface TokenPair {
  /** JWT access token — expires after 15 minutes (JWT_ACCESS_TTL). */
  accessToken: string;
  /** Opaque refresh token — valid for 7 days, rotated on every use. */
  refreshToken: string;
  /** Access-token lifetime string, e.g. "15m" — informational for clients. */
  accessTokenExpiresIn: string;
}

export interface AuthResponse {
  user: PublicUser;
  tokens: TokenPair;
}

/** Client context recorded on refresh tokens for audit purposes. */
export interface RequestContext {
  userAgent?: string;
  ip?: string;
}
