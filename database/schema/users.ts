import { pgTable, boolean, text, timestamp, uuid, uniqueIndex } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),

  fullName: text("full_name").notNull(),

  phone: text("phone"),
  email: text("email"),

  passwordHash: text("password_hash").notNull(),

  role: text("role").notNull(),

  status: text("status").notNull().default("PENDING_APPROVAL"),

  active: boolean("active").notNull().default(true),

  preferredLanguage: text("preferred_language").notNull(),

  createdAt: timestamp("created_at", {
    withTimezone: true,
  })
    .notNull()
    .defaultNow(),

  updatedAt: timestamp("updated_at", {
    withTimezone: true,
  })
    .notNull()
    .defaultNow(),
}, (table) => ({
  phoneUnique: uniqueIndex("users_phone_unique").on(table.phone),
}));
