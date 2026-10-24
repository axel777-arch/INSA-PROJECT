import { pgTable, pgEnum, uuid, text, timestamp } from "drizzle-orm/pg-core";
import { users } from "./users";

export const messageChannelEnum = pgEnum("message_channel", [
  "SMS",
  "IVR",
  "USSD",
]);

export const messages = pgTable("messages", {
  id: uuid("id").primaryKey().defaultRandom(),
  title: text("title"),
  body: text("body").notNull(),
  channel: messageChannelEnum("channel").notNull(),
  status: text("status").notNull().default("QUEUED"),
  createdBy: uuid("created_by")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
});

export type Message = typeof messages.$inferSelect;
export type NewMessage = typeof messages.$inferInsert;
