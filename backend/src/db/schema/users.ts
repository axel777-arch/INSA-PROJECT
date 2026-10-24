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
import { pgEnum, pgTable, timestamp, uuid, varchar, text } from 'drizzle-orm/pg-core';
import { USER_ROLES } from '../../config/constants.js';

export const userRoleEnum = pgEnum('user_role', USER_ROLES);

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  fullName: varchar('full_name', { length: 120 }).notNull(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  // Optional — some farmers may authenticate with phone only in the future.
  phone: varchar('phone', { length: 20 }),
  passwordHash: text('password_hash').notNull(),
  role: userRoleEnum('role').notNull().default('FARMER'),
  // Used by Member 5's targeting service for language matching.
  preferredLanguage: varchar('preferred_language', { length: 10 }).notNull().default('en'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true })
    .notNull()
    .defaultNow()
    .$onUpdate(() => new Date()),
});

export type UserRow = typeof users.$inferSelect;
export type NewUserRow = typeof users.$inferInsert;
