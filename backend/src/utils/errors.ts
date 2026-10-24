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
export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
    message: string,
    public readonly details: unknown = [],
  ) {
    super(message);
    this.name = new.target.name;
  }
}

/** 400 — request failed validation (also produced by the validate middleware). */
export class ValidationError extends AppError {
  constructor(message = 'Invalid request', details: unknown = []) {
    super(400, 'VALIDATION_ERROR', message, details);
  }
}

/** 401 — no/invalid credentials, or invalid refresh token. */
export class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required', details: unknown = []) {
    super(401, 'UNAUTHENTICATED', message, details);
  }
}

/**
 * 401 with a DISTINCT code for expired access tokens.
 * The Flutter client (Member 2) watches for code === 'TOKEN_EXPIRED' and then
 * calls POST /api/auth/refresh instead of forcing a re-login.
 */
export class TokenExpiredError extends AppError {
  constructor(message = 'Access token has expired') {
    super(401, 'TOKEN_EXPIRED', message);
  }
}

/** 403 — authenticated, but the role/permission check failed. */
export class ForbiddenError extends AppError {
  constructor(message = 'You do not have permission to perform this action', details: unknown = []) {
    super(403, 'FORBIDDEN', message, details);
  }
}

/** 404 — resource does not exist. */
export class NotFoundError extends AppError {
  constructor(resource = 'Resource', details: unknown = []) {
    super(404, 'NOT_FOUND', `${resource} not found`, details);
  }
}

/** 409 — uniqueness conflict or illegal state transition (e.g. duplicate email). */
export class ConflictError extends AppError {
  constructor(message = 'Resource conflict', details: unknown = []) {
    super(409, 'CONFLICT', message, details);
  }
}
