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
import { pgTable, timestamp, uuid, text, varchar } from 'drizzle-orm/pg-core';
import { users } from './users.js';

export const refreshTokens = pgTable('refresh_tokens', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id')
    .notNull()
    .references(() => users.id, { onDelete: 'cascade' }),
  tokenHash: text('token_hash').notNull().unique(),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  // Set when the token is rotated out or the user logs out.
  revokedAt: timestamp('revoked_at', { withTimezone: true }),
  // The token that replaced this one during rotation (audit trail).
  replacedByTokenId: uuid('replaced_by_token_id'),
  userAgent: varchar('user_agent', { length: 255 }),
  ipAddress: varchar('ip_address', { length: 45 }),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export type RefreshTokenRow = typeof refreshTokens.$inferSelect;
export type NewRefreshTokenRow = typeof refreshTokens.$inferInsert;
