"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConflictError = exports.NotFoundError = exports.ForbiddenError = exports.TokenExpiredError = exports.UnauthorizedError = exports.ValidationError = exports.AppError = void 0;
/**
 * Application error hierarchy — Member 3
 *
 * Team-wide error contract (B26): every error response looks like
 *   { "error": { "code": "...", "message": "...", "details": [] } }
 *
 * Team members: THROW these errors from services/controllers — do not hand-write
 * res.status(...).json(...) error bodies. The centralized error middleware
 * (src/middleware/error.middleware.ts) converts them into the standard shape.
 *
 * HTTP mapping (B26): 400 invalid input · 401 unauthenticated · 403 forbidden
 *                     404 not found · 409 conflict · 500 unexpected
 */
class AppError extends Error {
    statusCode;
    code;
    details;
    constructor(statusCode, code, message, details = []) {
        super(message);
        this.statusCode = statusCode;
        this.code = code;
        this.details = details;
        this.name = new.target.name;
    }
}
exports.AppError = AppError;
/** 400 — request failed validation (also produced by the validate middleware). */
class ValidationError extends AppError {
    constructor(message = 'Invalid request', details = []) {
        super(400, 'VALIDATION_ERROR', message, details);
    }
}
exports.ValidationError = ValidationError;
/** 401 — no/invalid credentials, or invalid refresh token. */
class UnauthorizedError extends AppError {
    constructor(message = 'Authentication required', details = []) {
        super(401, 'UNAUTHENTICATED', message, details);
    }
}
exports.UnauthorizedError = UnauthorizedError;
/**
 * 401 with a DISTINCT code for expired access tokens.
 * The Flutter client (Member 2) watches for code === 'TOKEN_EXPIRED' and then
 * calls POST /api/auth/refresh instead of forcing a re-login.
 */
class TokenExpiredError extends AppError {
    constructor(message = 'Access token has expired') {
        super(401, 'TOKEN_EXPIRED', message);
    }
}
exports.TokenExpiredError = TokenExpiredError;
/** 403 — authenticated, but the role/permission check failed. */
class ForbiddenError extends AppError {
    constructor(message = 'You do not have permission to perform this action', details = []) {
        super(403, 'FORBIDDEN', message, details);
    }
}
exports.ForbiddenError = ForbiddenError;
/** 404 — resource does not exist. */
class NotFoundError extends AppError {
    constructor(resource = 'Resource', details = []) {
        super(404, 'NOT_FOUND', `${resource} not found`, details);
    }
}
exports.NotFoundError = NotFoundError;
/** 409 — uniqueness conflict or illegal state transition (e.g. duplicate email). */
class ConflictError extends AppError {
    constructor(message = 'Resource conflict', details = []) {
        super(409, 'CONFLICT', message, details);
    }
}
exports.ConflictError = ConflictError;
