"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.auditLogs = void 0;
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
const pg_core_1 = require("drizzle-orm/pg-core");
const users_js_1 = require("./users.js");
exports.auditLogs = (0, pg_core_1.pgTable)('audit_logs', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    // Null when the actor account was deleted; the log entry itself is kept.
    actorUserId: (0, pg_core_1.uuid)('actor_user_id').references(() => users_js_1.users.id, { onDelete: 'set null' }),
    action: (0, pg_core_1.varchar)('action', { length: 100 }).notNull(), // e.g. 'auth.login', 'content.approve'
    entityType: (0, pg_core_1.varchar)('entity_type', { length: 100 }).notNull(), // e.g. 'user', 'content', 'message'
    entityId: (0, pg_core_1.uuid)('entity_id'),
    metadata: (0, pg_core_1.jsonb)('metadata'),
    createdAt: (0, pg_core_1.timestamp)('created_at', { withTimezone: true }).notNull().defaultNow(),
});
