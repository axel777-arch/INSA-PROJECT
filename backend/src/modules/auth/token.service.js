"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.signAccessToken = signAccessToken;
exports.verifyAccessToken = verifyAccessToken;
exports.issueRefreshToken = issueRefreshToken;
exports.rotateRefreshToken = rotateRefreshToken;
exports.revokeRefreshToken = revokeRefreshToken;
exports.revokeAllRefreshTokensForUser = revokeAllRefreshTokensForUser;
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
const node_crypto_1 = __importDefault(require("node:crypto"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const drizzle_orm_1 = require("drizzle-orm");
const env_js_1 = require("../../config/env.js");
const index_js_1 = require("../../db/index.js");
const refresh_tokens_js_1 = require("../../db/schema/refresh-tokens.js");
const users_js_1 = require("../../db/schema/users.js");
const errors_js_1 = require("../../utils/errors.js");
function signAccessToken(user) {
    const payload = { sub: user.id, role: user.role, type: 'access' };
    return jsonwebtoken_1.default.sign(payload, env_js_1.env.JWT_ACCESS_SECRET, {
        expiresIn: env_js_1.env.JWT_ACCESS_TTL, // default: '15m'
    });
}
function verifyAccessToken(token) {
    try {
        const payload = jsonwebtoken_1.default.verify(token, env_js_1.env.JWT_ACCESS_SECRET);
        if (payload.type !== 'access' || !payload.sub || !payload.role) {
            throw new errors_js_1.UnauthorizedError('Invalid access token');
        }
        return { sub: payload.sub, role: payload.role, type: 'access' };
    }
    catch (err) {
        if (err instanceof jsonwebtoken_1.default.TokenExpiredError) {
            // Distinct code so the Flutter client knows to call /api/auth/refresh.
            throw new errors_js_1.TokenExpiredError();
        }
        if (err instanceof errors_js_1.AppError)
            throw err;
        throw new errors_js_1.UnauthorizedError('Invalid access token');
    }
}
// ── Refresh tokens (opaque, DB-backed, rotating) ─────────────────────────────
function hashRefreshToken(token) {
    return node_crypto_1.default.createHash('sha256').update(token).digest('hex');
}
function refreshExpiryDate() {
    return new Date(Date.now() + env_js_1.env.REFRESH_TOKEN_TTL_DAYS * 24 * 60 * 60 * 1000);
}
/** Issue a new refresh token for a user and store its hash. Returns the RAW token (send to client once). */
async function issueRefreshToken(userId, ctx) {
    const token = node_crypto_1.default.randomBytes(48).toString('base64url');
    await index_js_1.db.insert(refresh_tokens_js_1.refreshTokens).values({
        userId,
        tokenHash: hashRefreshToken(token),
        expiresAt: refreshExpiryDate(),
        userAgent: ctx?.userAgent ?? null,
        ipAddress: ctx?.ip ?? null,
    });
    return token;
}
/**
 * Rotate a refresh token: validate → revoke old → issue new + fresh access token.
 * Throws UnauthorizedError for unknown / expired / reused tokens.
 */
async function rotateRefreshToken(presentedToken) {
    const tokenHash = hashRefreshToken(presentedToken);
    const existing = await index_js_1.db.query.refreshTokens.findFirst({
        where: (0, drizzle_orm_1.eq)(refresh_tokens_js_1.refreshTokens.tokenHash, tokenHash),
    });
    if (!existing) {
        throw new errors_js_1.UnauthorizedError('Invalid refresh token');
    }
    if (existing.revokedAt) {
        // A revoked token was presented again → probable theft. Kill the session family.
        await index_js_1.db
            .update(refresh_tokens_js_1.refreshTokens)
            .set({ revokedAt: new Date() })
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(refresh_tokens_js_1.refreshTokens.userId, existing.userId), (0, drizzle_orm_1.isNull)(refresh_tokens_js_1.refreshTokens.revokedAt)));
        throw new errors_js_1.UnauthorizedError('Refresh token reuse detected — all sessions have been revoked');
    }
    if (existing.expiresAt.getTime() < Date.now()) {
        throw new errors_js_1.UnauthorizedError('Refresh token expired — please log in again');
    }
    const user = await index_js_1.db.query.users.findFirst({ where: (0, drizzle_orm_1.eq)(users_js_1.users.id, existing.userId) });
    if (!user) {
        throw new errors_js_1.UnauthorizedError('Account no longer exists');
    }
    // Issue the replacement refresh token, then mark the old one revoked.
    const newRawToken = node_crypto_1.default.randomBytes(48).toString('base64url');
    const [newRow] = await index_js_1.db
        .insert(refresh_tokens_js_1.refreshTokens)
        .values({
        userId: user.id,
        tokenHash: hashRefreshToken(newRawToken),
        expiresAt: refreshExpiryDate(),
        userAgent: existing.userAgent,
        ipAddress: existing.ipAddress,
    })
        .returning({ id: refresh_tokens_js_1.refreshTokens.id });
    await index_js_1.db
        .update(refresh_tokens_js_1.refreshTokens)
        .set({ revokedAt: new Date(), replacedByTokenId: newRow.id })
        .where((0, drizzle_orm_1.eq)(refresh_tokens_js_1.refreshTokens.id, existing.id));
    return {
        accessToken: signAccessToken({ id: user.id, role: user.role }),
        refreshToken: newRawToken,
        user: { id: user.id, role: user.role },
    };
}
/** Revoke a single refresh token (logout). Idempotent — never throws for unknown tokens. */
async function revokeRefreshToken(presentedToken) {
    await index_js_1.db
        .update(refresh_tokens_js_1.refreshTokens)
        .set({ revokedAt: new Date() })
        .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(refresh_tokens_js_1.refreshTokens.tokenHash, hashRefreshToken(presentedToken)), (0, drizzle_orm_1.isNull)(refresh_tokens_js_1.refreshTokens.revokedAt)));
}
/** Revoke every active refresh token for a user (e.g. password change, admin action). */
async function revokeAllRefreshTokensForUser(userId) {
    await index_js_1.db
        .update(refresh_tokens_js_1.refreshTokens)
        .set({ revokedAt: new Date() })
        .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(refresh_tokens_js_1.refreshTokens.userId, userId), (0, drizzle_orm_1.isNull)(refresh_tokens_js_1.refreshTokens.revokedAt)));
}
