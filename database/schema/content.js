"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.content = exports.contentStatusEnum = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
exports.contentStatusEnum = (0, pg_core_1.pgEnum)("content_status", [
    "DRAFT",
    "IN_REVIEW",
    "APPROVED",
    "REJECTED",
    "PUBLISHED",
    "ARCHIVED",
]);
exports.content = (0, pg_core_1.pgTable)("content", {
    id: (0, pg_core_1.uuid)("id").primaryKey().defaultRandom(),
    title: (0, pg_core_1.varchar)("title", { length: 255 }).notNull(),
    body: (0, pg_core_1.text)("body").notNull(),
    // Targeting metadata (future FK to crops.id)
    cropId: (0, pg_core_1.uuid)("crop_id"),
    language: (0, pg_core_1.varchar)("language", { length: 50 }).notNull(),
    location: (0, pg_core_1.varchar)("location", { length: 255 }),
    // Review / approval workflow state
    status: (0, exports.contentStatusEnum)("status").notNull().default("DRAFT"),
    // Authorship / approval (future FKs to users.id)
    createdBy: (0, pg_core_1.uuid)("created_by").notNull(),
    approvedBy: (0, pg_core_1.uuid)("approved_by"),
    approvedAt: (0, pg_core_1.timestamp)("approved_at", { withTimezone: true }),
    createdAt: (0, pg_core_1.timestamp)("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)("updated_at", { withTimezone: true }).notNull().defaultNow(),
});
