import { pgTable, uuid, text, timestamp } from "drizzle-orm/pg-core";
import { messages } from "./messages";
import { farmers } from "./farmers";

export const messageRecipients = pgTable("message_recipients", {
  id: uuid("id").primaryKey().defaultRandom(),
  messageId: uuid("message_id")
    .notNull()
    .references(() => messages.id, { onDelete: "cascade" }),
  farmerId: uuid("farmer_id")
    .notNull()
    .references(() => farmers.id, { onDelete: "cascade" }),
  status: text("status").notNull().default("PENDING"),
  sentAt: timestamp("sent_at", { withTimezone: true }),
});

export type MessageRecipient = typeof messageRecipients.$inferSelect;
export type NewMessageRecipient = typeof messageRecipients.$inferInsert;
