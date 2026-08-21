/**
 * Request validation middleware — Member 3
 *
 * Team convention: every endpoint validates body / query / params with Zod
 * BEFORE the controller runs (B12/B25). Validated (and coerced) values replace
 * the raw request data, so controllers can trust their inputs.
 *
 * Usage:
 *   router.post('/', validate({ body: createFarmerSchema }), handler);
 *   router.get('/:id', validate({ params: uuidParamSchema }), handler);
 *   router.get('/', validate({ query: paginationQuerySchema }), handler);
 *
 * Zod errors are converted to the standard 400 VALIDATION_ERROR shape (B26)
 * with per-field details.
 */
import type { RequestHandler } from 'express';
import { ZodError, type ZodTypeAny } from 'zod';
import { ValidationError } from '../utils/errors.js';

interface ValidationSchemas {
  body?: ZodTypeAny;
  query?: ZodTypeAny;
  params?: ZodTypeAny;
}

export function validate(schemas: ValidationSchemas): RequestHandler {
  return (req, _res, next) => {
    try {
      if (schemas.body) {
        req.body = schemas.body.parse(req.body);
      }
      if (schemas.query) {
        const parsedQuery = schemas.query.parse(req.query);
        // Express 4 defines req.query as a getter-only accessor; assignment in
        // strict-mode ESM would throw, so redefine the property explicitly.
        Object.defineProperty(req, 'query', {
          value: parsedQuery,
          writable: true,
          enumerable: true,
          configurable: true,
        });
      }
      if (schemas.params) {
        req.params = schemas.params.parse(req.params);
      }
      return next();
    } catch (err) {
      if (err instanceof ZodError) {
        return next(
          new ValidationError(
            'Invalid request',
            err.issues.map((issue) => ({
              field: issue.path.join('.') || '(root)',
              message: issue.message,
            })),
          ),
        );
      }
      return next(err);
    }
  };
}
