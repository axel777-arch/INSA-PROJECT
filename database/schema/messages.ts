import { sql } from "drizzle-orm";
import { pgTable, pgEnum, uuid, text, timestamp, uniqueIndex } from "drizzle-orm/pg-core";
import { users } from "./users";
import { content } from "./content";

export const messageChannelEnum = pgEnum("message_channel", [
  "SMS",
  "IVR",
  "USSD",
]);

export const messages = pgTable(
  "messages",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    title: text("title"),
    body: text("body").notNull(),
    contentId: uuid("content_id").references(() => content.id, { onDelete: "set null" }),
    channel: messageChannelEnum("channel").notNull(),
    status: text("status").notNull().default("QUEUED"),
    createdBy: uuid("created_by")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    contentChannelUnique: uniqueIndex("messages_content_channel_unique")
      .on(table.contentId, table.channel)
      .where(sql`${table.contentId} IS NOT NULL`),
  }),
);

export type Message = typeof messages.$inferSelect;
export type NewMessage = typeof messages.$inferInsert;
