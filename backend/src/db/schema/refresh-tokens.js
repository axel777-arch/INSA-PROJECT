"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshTokens = void 0;
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
const pg_core_1 = require("drizzle-orm/pg-core");
const users_js_1 = require("./users.js");
exports.refreshTokens = (0, pg_core_1.pgTable)('refresh_tokens', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    userId: (0, pg_core_1.uuid)('user_id')
        .notNull()
        .references(() => users_js_1.users.id, { onDelete: 'cascade' }),
    tokenHash: (0, pg_core_1.text)('token_hash').notNull().unique(),
    expiresAt: (0, pg_core_1.timestamp)('expires_at', { withTimezone: true }).notNull(),
    // Set when the token is rotated out or the user logs out.
    revokedAt: (0, pg_core_1.timestamp)('revoked_at', { withTimezone: true }),
    // The token that replaced this one during rotation (audit trail).
    replacedByTokenId: (0, pg_core_1.uuid)('replaced_by_token_id'),
    userAgent: (0, pg_core_1.varchar)('user_agent', { length: 255 }),
    ipAddress: (0, pg_core_1.varchar)('ip_address', { length: 45 }),
    createdAt: (0, pg_core_1.timestamp)('created_at', { withTimezone: true }).notNull().defaultNow(),
});
