/**
 * Permissions matrix — Agri-Insight Beacon
 *
 * This is the SINGLE SOURCE OF TRUTH for role-based access control.
 * The backend — never the Flutter app — enforces these permissions.
 *
 * Matrix (agreed by the team):
 * ┌──────────────────────────────┬────────┬──────────────────┬────────┬───────┐
 * │ Action                       │ Farmer │ Extension Worker │ Expert │ Admin │
 * ├──────────────────────────────┼────────┼──────────────────┼────────┼───────┤
 * │ View own profile (/auth/me)  │   ✓    │        ✓         │   ✓    │   ✓   │
 * │ Create / edit farmers        │   -    │        ✓         │   -    │   ✓   │
 * │ Assign farmers to workers    │   -    │        ✓         │   -    │   ✓   │
 * │ Create field observations    │   -    │        ✓         │   -    │   ✓   │
 * │ Read field observations      │   -    │        ✓         │   ✓    │   ✓   │
 * │ Escalate observations        │   -    │        ✓         │   -    │   ✓   │
 * │ Create / complete follow-ups │   -    │        ✓         │   -    │   ✓   │
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
  | 'simulator:use';

export const ROLE_PERMISSIONS: Record<UserRole, readonly Permission[]> = {
  FARMER: ['profile:read', 'content:read', 'message:read', 'simulator:use'],

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
  ],
};

/** Check whether a role holds a permission. */
export function hasPermission(role: UserRole, permission: Permission): boolean {
  return ROLE_PERMISSIONS[role]?.includes(permission) ?? false;
}
