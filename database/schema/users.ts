import {
  boolean,
  pgTable,
  text,
  timestamp,
  uuid,
} from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),

  fullName: text("full_name").notNull(),

  phone: text("phone"),
  email: text("email"),

  passwordHash: text("password_hash").notNull(),

  role: text("role").notNull(),

  preferredLanguage: text("preferred_language").notNull(),

  active: boolean("active").notNull().default(true),

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
});