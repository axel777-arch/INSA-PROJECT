/**
 * Role / permission authorization middleware — Member 3
 *
 * The backend — not Flutter — enforces permissions (B5 security rule).
 *
 * Two styles are available:
 *
 *   requireRole('ADMIN')                        → coarse, whole-role check
 *   requirePermission('content:approve')        → fine-grained, uses the
 *                                                 permissions matrix
 *                                                 (src/config/permissions.ts)
 *
 * PREFER requirePermission for module endpoints — it keeps authorization
 * data-driven. Use requireRole only when an entire role genuinely owns a
 * route (e.g. admin-only diagnostics).
 *
 * Always place AFTER requireAuth:
 *   router.post('/:id/approve', requireAuth, requirePermission('content:approve'), handler);
 */
import type { RequestHandler } from 'express';
import type { UserRole } from '../config/constants.js';
import { hasPermission, type Permission } from '../config/permissions.js';
import { ForbiddenError, UnauthorizedError } from '../utils/errors.js';

export function requireRole(...roles: UserRole[]): RequestHandler {
  return (req, _res, next) => {
    if (!req.user) {
      return next(new UnauthorizedError());
    }
    if (!roles.includes(req.user.role)) {
      return next(
        new ForbiddenError(`This action requires one of the following roles: ${roles.join(', ')}`),
      );
    }
    return next();
  };
}

export function requirePermission(permission: Permission): RequestHandler {
  return (req, _res, next) => {
    if (!req.user) {
      return next(new UnauthorizedError());
    }
    if (!hasPermission(req.user.role, permission)) {
      return next(new ForbiddenError(`Missing required permission: ${permission}`));
    }
    return next();
  };
}
