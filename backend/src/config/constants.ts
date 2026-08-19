/**
 * Shared domain constants — Member 3 (Backend Foundation, Auth & Security)
 *
 * Team decision: these enums are defined ONCE here (single source of truth)
 * so every member uses identical status/role strings (docs analysis, §12).
 * Members 4/5/6: import from here — do NOT redefine these strings locally.
 */

// ── User roles (B5) ──────────────────────────────────────────────────────────
export const USER_ROLES = ['FARMER', 'EXTENSION_WORKER', 'EXPERT', 'ADMIN'] as const;
export type UserRole = (typeof USER_ROLES)[number];

export const UserRole = {
  FARMER: 'FARMER',
  EXTENSION_WORKER: 'EXTENSION_WORKER',
  EXPERT: 'EXPERT',
  ADMIN: 'ADMIN',
} as const satisfies Record<string, UserRole>;

/**
 * Team decision: self-registration is only allowed for FARMER and
 * EXTENSION_WORKER. EXPERT and ADMIN accounts are created exclusively via the
 * seed script (src/db/seed.ts). There is no endpoint to change roles.
 */
export const SELF_REGISTERABLE_ROLES = ['FARMER', 'EXTENSION_WORKER'] as const satisfies readonly UserRole[];
export type SelfRegisterableRole = (typeof SELF_REGISTERABLE_ROLES)[number];

// ── Content workflow statuses (B7) — OWNED by Member 5, defined here as the
//    shared reference. Member 5: use these exact values in your Drizzle enum. ──
export const CONTENT_STATUSES = [
  'DRAFT',
  'IN_REVIEW',
  'APPROVED',
  'REJECTED',
  'PUBLISHED',
  'ARCHIVED',
] as const;
export type ContentStatus = (typeof CONTENT_STATUSES)[number];

export const ContentStatus = {
  DRAFT: 'DRAFT',
  IN_REVIEW: 'IN_REVIEW',
  APPROVED: 'APPROVED',
  REJECTED: 'REJECTED',
  PUBLISHED: 'PUBLISHED',
  ARCHIVED: 'ARCHIVED',
} as const satisfies Record<string, ContentStatus>;

// ── Message / delivery statuses (B8) — OWNED by Member 6, shared reference. ──
export const MESSAGE_STATUSES = ['QUEUED', 'SENT', 'DELIVERED', 'FAILED'] as const;
export type MessageStatus = (typeof MESSAGE_STATUSES)[number];

export const MessageStatus = {
  QUEUED: 'QUEUED',
  SENT: 'SENT',
  DELIVERED: 'DELIVERED',
  FAILED: 'FAILED',
} as const satisfies Record<string, MessageStatus>;

export const DELIVERY_STATUSES = ['QUEUED', 'SENT', 'DELIVERED', 'FAILED'] as const;
export type DeliveryStatus = (typeof DELIVERY_STATUSES)[number];

export const DeliveryStatus = {
  QUEUED: 'QUEUED',
  SENT: 'SENT',
  DELIVERED: 'DELIVERED',
  FAILED: 'FAILED',
} as const satisfies Record<string, DeliveryStatus>;
