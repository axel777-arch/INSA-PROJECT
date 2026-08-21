"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ROLE_PERMISSIONS = void 0;
exports.hasPermission = hasPermission;
exports.ROLE_PERMISSIONS = {
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
function hasPermission(role, permission) {
    return exports.ROLE_PERMISSIONS[role]?.includes(permission) ?? false;
}
