/**
 * Centralised error handler — converts AppError subclasses and Zod errors
 * into the standard API error envelope:
 *   { "error": { "code": "...", "message": "...", "details": [] } }
 */
import type { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { AppError } from '../utils/errors';

export function errorHandler(
  err: unknown,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // Known application errors
  if (err instanceof AppError) {
    console.error(`[ERROR] ${req.method} ${req.originalUrl} → ${err.statusCode} ${err.code}: ${err.message}`);
    res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details ?? [],
      },
    });
    return;
  }

  // Zod validation errors (thrown by .parse() inside controllers)
  if (err instanceof ZodError) {
    console.error(`[VALIDATION ERROR] ${req.method} ${req.originalUrl}:`, err.flatten());
    res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid request data',
        details: err.issues,
      },
    });
    return;
  }

  // Content workflow errors
  if (err instanceof Error) {
    if (err.name === 'ContentNotFoundError') {
      res.status(404).json({ error: { code: 'NOT_FOUND', message: err.message, details: [] } });
      return;
    }
    if (err.name === 'InvalidContentTransitionError') {
      res.status(409).json({ error: { code: 'INVALID_TRANSITION', message: err.message, details: [] } });
      return;
    }
  }

  // Unexpected errors
  console.error(`[UNHANDLED ERROR] ${req.method} ${req.originalUrl}:`, err);
  res.status(500).json({
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred',
      details: [],
    },
  });
}
