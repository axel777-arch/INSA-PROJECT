/**
 * Centralized error handling — Member 3
 *
 * Guarantees the B26 error contract for EVERY failure:
 *   { "error": { "code": "...", "message": "...", "details": [...] } }
 *
 * Security (B25): stack traces and internal details are NEVER sent to clients.
 * Request IDs are logged for audit trails and forensic analysis.
 * Register notFoundHandler AFTER all routes, and errorHandler LAST in app.ts.
 */
import type { ErrorRequestHandler, RequestHandler } from 'express';
import { env } from '../config/env.js';
import { AppError } from '../utils/errors.js';
import { logger } from '../utils/logger.js';

/** Catch-all for unmatched routes — returns the standard 404 shape. */
export const notFoundHandler: RequestHandler = (req, res) => {
  const requestId = res.locals.requestId || 'unknown';
  logger.warn('Route not found', {
    requestId,
    method: req.method,
    path: req.path,
    ip: req.ip,
  });

  res.status(404).json({
    error: {
      code: 'NOT_FOUND',
      message: `Route not found: ${req.method} ${req.path}`,
      details: [],
    },
  });
};

/** Final error handler — must be registered LAST (after all routes). */
export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  const requestId = res.locals.requestId || 'unknown';

  // Known application errors thrown by services/middleware.
  if (err instanceof AppError) {
    if (err.statusCode >= 500) {
      logger.error('Application error (5xx)', {
        requestId,
        code: err.code,
        message: err.message,
        statusCode: err.statusCode,
        method: req.method,
        path: req.path,
        ip: req.ip,
      });
    } else if (err.statusCode === 401 || err.statusCode === 403) {
      // Security-relevant 4xx errors
      logger.warn('Security event (auth/authz failure)', {
        requestId,
        code: err.code,
        statusCode: err.statusCode,
        method: req.method,
        path: req.path,
        ip: req.ip,
      });
    }

    res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details ?? [],
      },
    });
    return;
  }

  // Body-parser errors (malformed JSON / oversized payload).
  const bodyParserError = err as { type?: string; status?: number };
  if (bodyParserError?.type === 'entity.parse.failed') {
    logger.warn('Malformed JSON request', {
      requestId,
      method: req.method,
      path: req.path,
      ip: req.ip,
    });

    res.status(400).json({
      error: { code: 'VALIDATION_ERROR', message: 'Malformed JSON request body', details: [] },
    });
    return;
  }
  if (bodyParserError?.type === 'entity.too.large') {
    logger.warn('Payload too large', {
      requestId,
      method: req.method,
      path: req.path,
      ip: req.ip,
    });

    res.status(413).json({
      error: { code: 'PAYLOAD_TOO_LARGE', message: 'Request body exceeds the 10kb limit', details: [] },
    });
    return;
  }

  // Unexpected error — log internally (with stack), return a safe generic body.
  logger.error('Unhandled error', {
    requestId,
    method: req.method,
    path: req.path,
    ip: req.ip,
    error: err instanceof Error ? { name: err.name, message: err.message, stack: env.isProd ? undefined : err.stack } : err,
  });

  res.status(500).json({
    error: { code: 'INTERNAL_ERROR', message: 'Unexpected server error', details: [] },
  });
};
