/**
 * Permissions matrix — Agri-Insight Beacon
 *
 * This is the SINGLE SOURCE OF TRUTH for role-based access control.
 * The backend — never the Flutter app — enforces these permissions.
 */
import type { UserRole } from './constants.js';

export type Permission =
  | 'profile:read'
  | 'farmer:create'
  | 'farmer:read'
  | 'farmer:edit'
  | 'farmer:assign'
  | 'observation:create'
  | 'observation:read'
  | 'observation:edit'
  | 'observation:escalate'
  | 'followup:create'
  | 'followup:read'
  | 'followup:edit'
  | 'crop:manage'
  | 'content:create'
  | 'content:read'
  | 'content:edit'
  | 'content:submit-review'
  | 'content:approve'
  | 'content:reject'
  | 'content:publish'
  | 'content:archive'
  | 'message:send'
  | 'message:read'
  | 'audit:read'
  | 'simulator:use'
  | 'case:read'
  | 'case:create'
  | 'case:manage'
  | 'case:message';

export const ROLE_PERMISSIONS: Record<UserRole, readonly Permission[]> = {
  FARMER: [
    'profile:read',
    'content:read',
    'message:read',
    'simulator:use',
    'case:read',
    'case:create',
    'case:message',
  ],
  EXTENSION_WORKER: [
    'profile:read',
    'farmer:create',
    'farmer:read',
    'farmer:edit',
    'farmer:assign',
    'observation:create',
    'observation:read',
    'observation:edit',
    'observation:escalate',
    'followup:create',
    'followup:read',
    'followup:edit',
    'crop:manage',
    'content:create',
    'content:read',
    'content:edit',
    'content:submit-review',
    'simulator:use',
    'case:read',
    'case:create',
    'case:manage',
    'case:message',
  ],
  EXPERT: [
    'profile:read',
    'farmer:read',
    'observation:read',
    'observation:edit',
    'content:create',
    'content:read',
    'content:edit',
    'content:submit-review',
    'content:approve',
    'content:reject',
    'content:publish',
    'content:archive',
    'simulator:use',
    'case:read',
    'case:create',
    'case:manage',
    'case:message',
  ],
  ADMIN: [
    'profile:read',
    'farmer:create',
    'farmer:read',
    'farmer:edit',
    'farmer:assign',
    'observation:create',
    'observation:read',
    'observation:edit',
    'observation:escalate',
    'followup:create',
    'followup:read',
    'followup:edit',
    'crop:manage',
    'content:create',
    'content:read',
    'content:edit',
    'content:submit-review',
    'content:approve',
    'content:reject',
    'content:publish',
    'content:archive',
    'message:send',
    'message:read',
    'audit:read',
    'simulator:use',
    'case:read',
    'case:create',
    'case:manage',
    'case:message',
  ],
};

export const hasPermission = (role: UserRole, permission: Permission): boolean => {
  const perms = ROLE_PERMISSIONS[role];
  return perms ? perms.includes(permission) : false;
};
