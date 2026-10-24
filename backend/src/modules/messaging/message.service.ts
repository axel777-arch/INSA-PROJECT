import { eq, desc } from "drizzle-orm";
import { db } from "../../db/index";
import { messages } from "../../../../database/schema/messages";
import { messageRecipients } from "../../../../database/schema/messageRecipients";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import type {
  BroadcastMessageInput,
  BroadcastResult,
  CreateMessageInput,
  MessageRecord,
} from "./message.types";

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export class MessageService {
  /**
   * Resolves a valid user UUID for foreign key integrity against `users.id`.
   */
  private async resolveUserId(userId?: string): Promise<string> {
    if (!db) return "00000000-0000-0000-0000-000000000000";

    try {
      if (userId && UUID_REGEX.test(userId)) {
        const [u] = await db.select({ id: users.id }).from(users).where(eq(users.id, userId)).limit(1);
        if (u) return u.id;
      }

      const [firstUser] = await db.select({ id: users.id }).from(users).limit(1);
      if (firstUser) return firstUser.id;
    } catch (err) {
      console.warn("[MESSAGING] User ID resolution warning:", err);
    }

    return "00000000-0000-0000-0000-000000000000";
  }

  /**
   * Dispatches a broadcast to multiple farmers:
   * 1. Inserts master message in `messages` table.
   * 2. Inserts linked recipient records into `message_recipients` table with delivery status tracking.
   */
  async dispatchBroadcast(input: BroadcastMessageInput): Promise<BroadcastResult> {
    const creatorId = await this.resolveUserId(input.createdBy);

    // 1. Insert master message
    const [masterMessage] = await db
      .insert(messages)
      .values({
        title: input.title ?? "Advisory Broadcast",
        body: input.body,
        channel: input.channel ?? "SMS",
        status: "SENT",
        createdBy: creatorId,
      })
      .returning();

    console.log(
      `[DATABASE] Master message created: id=${masterMessage.id}, channel=${masterMessage.channel}, title="${masterMessage.title}"`
    );

    // 2. Insert linked recipient records
    let insertedRecipients: any[] = [];
    if (input.farmerIds && input.farmerIds.length > 0) {
      const uniqueFarmerIds = [...new Set(input.farmerIds)];

      // Verify existing farmers to respect foreign keys
      const existingFarmers = await db.select({ id: farmers.id }).from(farmers);
      const existingFarmerSet = new Set(existingFarmers.map((f) => f.id));

      const eligibleFarmerIds = uniqueFarmerIds.filter((fid) => existingFarmerSet.has(fid));

      if (eligibleFarmerIds.length > 0) {
        const rows = eligibleFarmerIds.map((farmerId) => ({
          messageId: masterMessage.id,
          farmerId,
          status: "SENT",
          sentAt: new Date(),
        }));

        insertedRecipients = await db
          .insert(messageRecipients)
          .values(rows)
          .returning();

        console.log(
          `[DATABASE] Inserted ${insertedRecipients.length} message_recipients for master message ${masterMessage.id}`
        );
      }
    }

    return {
      message: {
        id: masterMessage.id,
        title: masterMessage.title,
        body: masterMessage.body,
        channel: masterMessage.channel,
        status: masterMessage.status,
        createdBy: masterMessage.createdBy,
        createdAt: masterMessage.createdAt,
      },
      recipients: insertedRecipients,
    };
  }

  /**
   * Asynchronously creates and persists a single message to PostgreSQL.
   */
  async createMessageAsync(input: CreateMessageInput): Promise<MessageRecord> {
    const creatorId = await this.resolveUserId(input.createdBy);

    const [created] = await db
      .insert(messages)
      .values({
        title: input.title ?? "System Alert",
        body: input.body ?? `Advisory update for content ${input.contentId ?? "N/A"}`,
        channel: input.channel,
        status: "QUEUED",
        createdBy: creatorId,
      })
      .returning();

    // Link recipient farmer if phone matches a farmer
    if (input.recipientPhone) {
      try {
        const [matchedFarmer] = await db
          .select({ farmerId: farmers.id })
          .from(farmers)
          .innerJoin(users, eq(users.id, farmers.userId))
          .where(eq(users.phone, input.recipientPhone))
          .limit(1);

        if (matchedFarmer) {
          await db.insert(messageRecipients).values({
            messageId: created.id,
            farmerId: matchedFarmer.farmerId,
            status: "SENT",
            sentAt: new Date(),
          });
        }
      } catch (err) {
        console.warn("[MESSAGING] Recipient linking warning:", err);
      }
    }

    return {
      id: created.id,
      contentId: input.contentId,
      title: created.title,
      body: created.body,
      channel: created.channel,
      status: created.status,
      createdBy: created.createdBy,
      createdAt: created.createdAt,
      updatedAt: created.createdAt,
    };
  }

  /**
   * Synchronous signature for backwards compatibility with existing unit tests.
   */
  createMessage(input: CreateMessageInput): MessageRecord {
    const now = new Date();
    const tempId = `message_${Math.random().toString(36).slice(2, 10)}`;

    const record: MessageRecord = {
      id: tempId,
      contentId: input.contentId,
      channel: input.channel,
      status: "QUEUED",
      createdBy: input.createdBy,
      createdAt: now,
      updatedAt: now,
    };

    // Background persistence
    this.createMessageAsync(input).catch((err) => {
      console.warn("[MESSAGING] Background message insert warning:", err);
    });

    return record;
  }

  updateMessageStatus(message: MessageRecord, status: MessageRecord["status"]): MessageRecord {
    const updated = {
      ...message,
      status,
      updatedAt: new Date(),
    };

    if (UUID_REGEX.test(message.id)) {
      db.update(messages)
        .set({ status })
        .where(eq(messages.id, message.id))
        .catch((err) => {
          console.warn("[MESSAGING] Message status update warning:", err);
        });
    }

    return updated;
  }

  async listMessages(): Promise<MessageRecord[]> {
    const rows = await db.select().from(messages).orderBy(desc(messages.createdAt));
    return rows.map((r) => ({
      id: r.id,
      title: r.title,
      body: r.body,
      channel: r.channel,
      status: r.status,
      createdBy: r.createdBy,
      createdAt: r.createdAt,
      updatedAt: r.createdAt,
    }));
  }

  async listRecipients(messageId: string): Promise<any[]> {
    return db
      .select()
      .from(messageRecipients)
      .where(eq(messageRecipients.messageId, messageId));
  }
}

export const messageService = new MessageService();

