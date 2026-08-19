/**
 * audit_logs table — Member 3 (Backend Foundation, Auth & Security)
 *
 * Basic audit logging is an MVP requirement (A4) and a security concern (B25),
 * so the table + writer utility (src/utils/audit.ts) are provided here.
 *
 * COORDINATION NOTE (Member 4): if you prefer to own this table under
 * database/schema/, move this file there and update src/utils/audit.ts imports.
 * Until then, Members 5/6 should call auditLog(...) for sensitive actions
 * (content approval/rejection/publish, message sends, simulator runs).
 */
import { jsonb, pgTable, timestamp, uuid, varchar } from 'drizzle-orm/pg-core';
import { users } from './users.js';

export const auditLogs = pgTable('audit_logs', {
  id: uuid('id').primaryKey().defaultRandom(),
  // Null when the actor account was deleted; the log entry itself is kept.
  actorUserId: uuid('actor_user_id').references(() => users.id, { onDelete: 'set null' }),
  action: varchar('action', { length: 100 }).notNull(), // e.g. 'auth.login', 'content.approve'
  entityType: varchar('entity_type', { length: 100 }).notNull(), // e.g. 'user', 'content', 'message'
  entityId: uuid('entity_id'),
  metadata: jsonb('metadata'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export type AuditLogRow = typeof auditLogs.$inferSelect;
