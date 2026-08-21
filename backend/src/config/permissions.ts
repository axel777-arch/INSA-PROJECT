/**
 * Permissions matrix — Member 3 (Backend Foundation, Auth & Security)
 *
 * This is the SINGLE SOURCE OF TRUTH for role-based access control (B5/B25).
 * The backend — never the Flutter app — enforces these permissions.
 *
 * HOW TEAMMATES USE THIS:
 *   - Member 4 (farmers/crops):   requirePermission('farmer:create'), requirePermission('farmer:edit'), ...
 *   - Member 5 (content/review):  requirePermission('content:approve'), requirePermission('content:reject'), ...
 *   - Member 6 (messaging):       requirePermission('message:send'), requirePermission('simulator:use'), ...
 * If you need a new permission string, add it here (with a PR) — do not invent
 * per-module permission strings.
 *
 * Matrix (agreed by the team):
 * ┌──────────────────────────────┬────────┬──────────────────┬────────┬───────┐
 * │ Action                       │ Farmer │ Extension Worker │ Expert │ Admin │
 * ├──────────────────────────────┼────────┼──────────────────┼────────┼───────┤
 * │ Register                     │ self   │ self             │ seed   │ seed  │
 * │ View own profile (/auth/me)  │   ✓    │        ✓         │   ✓    │   ✓   │
 * │ Create / edit farmers        │   -    │        ✓         │   -    │   ✓   │
 * │ Manage crops                 │   -    │        ✓         │   -    │   ✓   │
 * │ Create/edit/submit content   │   -    │        ✓         │   ✓    │   ✓   │
 * │ Approve / reject content     │   -    │        -         │   ✓    │   -   │
 * │ Publish / archive content    │   -    │        -         │   ✓    │   ✓   │
 * │ Run targeting / send message │   -    │        -         │   -    │   ✓   │
 * │ View own messages (alerts)   │   ✓    │        -         │   -    │   ✓   │
 * │ View audit logs              │   -    │        -         │   -    │   ✓   │
 * │ Use SMS / IVR simulator      │   ✓    │        ✓         │   ✓    │   ✓   │
 * └──────────────────────────────┴────────┴──────────────────┴────────┴───────┘
 */
import type { UserRole } from './constants.js';

export type Permission =
  | 'profile:read'
  | 'farmer:create'
  | 'farmer:read'
  | 'farmer:edit'
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
  | 'simulator:use';

export const ROLE_PERMISSIONS: Record<UserRole, readonly Permission[]> = {
  FARMER: ['profile:read', 'content:read', 'message:read', 'simulator:use'],

  EXTENSION_WORKER: [
    'profile:read',
    'farmer:create',
    'farmer:read',
    'farmer:edit',
    'crop:manage',
    'content:create',
    'content:read',
    'content:edit',
    'content:submit-review',
    'simulator:use',
  ],

  EXPERT: [
    'profile:read',
    'content:create',
    'content:read',
    'content:edit',
    'content:submit-review',
    'content:approve',
    'content:reject',
    'content:publish',
    'content:archive',
    'simulator:use',
  ],

  ADMIN: [
    'profile:read',
    'farmer:create',
    'farmer:read',
    'farmer:edit',
    'crop:manage',
    'content:read',
    'content:publish',
    'content:archive',
    'message:send',
    'message:read',
    'audit:read',
    'simulator:use',
  ],
};

/** Check whether a role holds a permission. */
export function hasPermission(role: UserRole, permission: Permission): boolean {
  return ROLE_PERMISSIONS[role]?.includes(permission) ?? false;
}
