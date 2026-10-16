/**
 * refresh_tokens table — Member 3 (Backend Foundation, Auth & Security)
 *
 * Long-lived (7-day) refresh tokens so users are NOT logged out when the
 * 15-minute access token expires. Security design:
 *   - The refresh token itself is an opaque random string (NOT a JWT).
 *   - Only its SHA-256 hash is stored — a database leak does not leak tokens.
 *   - Rotation: every /auth/refresh call revokes the old token and issues a new
 *     one (replaced_by_token_id keeps the rotation chain).
 *   - Reuse detection: if a revoked token is presented again, ALL tokens for
 *     that user are revoked (theft protection).
 */
export * from '../../../../database/schema/refreshTokens';

