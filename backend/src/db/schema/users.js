"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.users = exports.userRoleEnum = void 0;
/**
 * users table — Member 3 (Backend Foundation, Auth & Security)
 *
 * Matches the exact model in the documentation (B11):
 *   id (uuid pk), full_name, email, phone, password_hash, role,
 *   preferred_language, created_at, updated_at
 *
 * NOTE FOR MEMBER 4 (schema owner of database/schema/):
 *   This file defines the users + auth tables. If you relocate Drizzle schema
 *   files into the repo-root `database/schema/` folder, MOVE (not copy) these
 *   files and update `drizzle.config.ts` accordingly. Your farmers table must
 *   reference: users.id with ON DELETE CASCADE (team decision, analysis §12).
 */
const pg_core_1 = require("drizzle-orm/pg-core");
const constants_js_1 = require("../../config/constants.js");
exports.userRoleEnum = (0, pg_core_1.pgEnum)('user_role', constants_js_1.USER_ROLES);
exports.users = (0, pg_core_1.pgTable)('users', {
    id: (0, pg_core_1.uuid)('id').primaryKey().defaultRandom(),
    fullName: (0, pg_core_1.varchar)('full_name', { length: 120 }).notNull(),
    email: (0, pg_core_1.varchar)('email', { length: 255 }).notNull().unique(),
    // Optional — some farmers may authenticate with phone only in the future.
    phone: (0, pg_core_1.varchar)('phone', { length: 20 }),
    passwordHash: (0, pg_core_1.text)('password_hash').notNull(),
    role: (0, exports.userRoleEnum)('role').notNull().default('FARMER'),
    // Used by Member 5's targeting service for language matching.
    preferredLanguage: (0, pg_core_1.varchar)('preferred_language', { length: 10 }).notNull().default('en'),
    createdAt: (0, pg_core_1.timestamp)('created_at', { withTimezone: true }).notNull().defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)('updated_at', { withTimezone: true })
        .notNull()
        .defaultNow()
        .$onUpdate(() => new Date()),
});
