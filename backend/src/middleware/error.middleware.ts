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
    if (err.statusCode === 400) {
      console.error(
        `\n❌ [400 BAD REQUEST] ${req.method} ${req.originalUrl}\n` +
        `   Code:    ${err.code}\n` +
        `   Message: ${err.message}\n` +
        `   Details: ${JSON.stringify(err.details ?? [], null, 2)}\n`
      );
    } else {
      console.error(`[ERROR] ${req.method} ${req.originalUrl} → ${err.statusCode} ${err.code}: ${err.message}`);
    }
    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errors: err.details ?? [],
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
    const flattened = err.flatten();
    const formattedIssues = err.issues.map((issue) => {
      const issueObj: Record<string, unknown> = {
        path: issue.path.join('.') || '(root)',
        code: issue.code,
        message: issue.message,
      };
      if ('expected' in issue) issueObj.expected = (issue as unknown as Record<string, unknown>).expected;
      if ('received' in issue) issueObj.received = (issue as unknown as Record<string, unknown>).received;
      return issueObj;
    });

    console.error(
      `\n❌ [400 VALIDATION FAILURE] ${req.method} ${req.originalUrl}\n` +
      `   Field Errors:\n${JSON.stringify(flattened.fieldErrors, null, 4)}\n` +
      `   Form Errors:\n${JSON.stringify(flattened.formErrors, null, 4)}\n` +
      `   Specific Issues:\n${JSON.stringify(formattedIssues, null, 4)}\n`
    );

    res.status(400).json({
      success: false,
      message: 'Invalid request data',
      errors: err.issues,
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
      res.status(404).json({
        success: false,
        message: err.message,
        errors: [],
        error: { code: 'NOT_FOUND', message: err.message, details: [] },
      });
      return;
    }
    if (err.name === 'InvalidContentTransitionError') {
      res.status(409).json({
        success: false,
        message: err.message,
        errors: [],
        error: { code: 'INVALID_TRANSITION', message: err.message, details: [] },
      });
      return;
    }
  }

  // Unexpected errors
  console.error(`[UNHANDLED ERROR] ${req.method} ${req.originalUrl}:`, err);
  res.status(500).json({
    success: false,
    message: 'An unexpected error occurred',
    errors: [],
    error: {
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred',
      details: [],
    },
  });
}
