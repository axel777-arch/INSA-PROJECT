"use strict";
/**
 * Shared domain constants — Member 3 (Backend Foundation, Auth & Security)
 *
 * Team decision: these enums are defined ONCE here (single source of truth)
 * so every member uses identical status/role strings (docs analysis, §12).
 * Members 4/5/6: import from here — do NOT redefine these strings locally.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.DeliveryStatus = exports.DELIVERY_STATUSES = exports.MessageStatus = exports.MESSAGE_STATUSES = exports.ContentStatus = exports.CONTENT_STATUSES = exports.SELF_REGISTERABLE_ROLES = exports.UserRole = exports.USER_ROLES = void 0;
// ── User roles (B5) ──────────────────────────────────────────────────────────
exports.USER_ROLES = ['FARMER', 'EXTENSION_WORKER', 'EXPERT', 'ADMIN'];
exports.UserRole = {
    FARMER: 'FARMER',
    EXTENSION_WORKER: 'EXTENSION_WORKER',
    EXPERT: 'EXPERT',
    ADMIN: 'ADMIN',
};
/**
 * Team decision: self-registration is only allowed for FARMER and
 * EXTENSION_WORKER. EXPERT and ADMIN accounts are created exclusively via the
 * seed script (src/db/seed.ts). There is no endpoint to change roles.
 */
exports.SELF_REGISTERABLE_ROLES = ['FARMER', 'EXTENSION_WORKER'];
// ── Content workflow statuses (B7) — OWNED by Member 5, defined here as the
//    shared reference. Member 5: use these exact values in your Drizzle enum. ──
exports.CONTENT_STATUSES = [
    'DRAFT',
    'IN_REVIEW',
    'APPROVED',
    'REJECTED',
    'PUBLISHED',
    'ARCHIVED',
];
exports.ContentStatus = {
    DRAFT: 'DRAFT',
    IN_REVIEW: 'IN_REVIEW',
    APPROVED: 'APPROVED',
    REJECTED: 'REJECTED',
    PUBLISHED: 'PUBLISHED',
    ARCHIVED: 'ARCHIVED',
};
// ── Message / delivery statuses (B8) — OWNED by Member 6, shared reference. ──
exports.MESSAGE_STATUSES = ['QUEUED', 'SENT', 'DELIVERED', 'FAILED'];
exports.MessageStatus = {
    QUEUED: 'QUEUED',
    SENT: 'SENT',
    DELIVERED: 'DELIVERED',
    FAILED: 'FAILED',
};
exports.DELIVERY_STATUSES = ['QUEUED', 'SENT', 'DELIVERED', 'FAILED'];
exports.DeliveryStatus = {
    QUEUED: 'QUEUED',
    SENT: 'SENT',
    DELIVERED: 'DELIVERED',
    FAILED: 'FAILED',
};
