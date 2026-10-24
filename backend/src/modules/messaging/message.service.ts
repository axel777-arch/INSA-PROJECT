import { eq, desc, and, inArray } from "drizzle-orm";
import { db } from "../../db/index";
import { messages } from "../../../../database/schema/messages";
import { messageRecipients } from "../../../../database/schema/messageRecipients";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { content } from "../../../../database/schema/content";
import { NotFoundError, ValidationError } from "../../utils/errors";
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
    if (!userId || !UUID_REGEX.test(userId)) {
      throw new ValidationError("A valid authenticated creator ID is required");
    }
    const [user] = await db.select({ id: users.id }).from(users).where(eq(users.id, userId)).limit(1);
    if (!user) throw new NotFoundError("Message creator");
    return user.id;
  }

  /**
   * Dispatches a broadcast to multiple farmers:
   * 1. Inserts master message in `messages` table.
   * 2. Inserts linked recipient records into `message_recipients` table with delivery status tracking.
   */
  async dispatchBroadcast(input: BroadcastMessageInput): Promise<BroadcastResult> {
    if (!input.contentId) {
      throw new ValidationError("Broadcasts must reference approved published content");
    }
    const [publishedContent] = await db
      .select({ id: content.id, status: content.status })
      .from(content)
      .where(eq(content.id, input.contentId))
      .limit(1);
    if (!publishedContent || publishedContent.status !== "PUBLISHED") {
      throw new ValidationError("Only published content can be sent to farmers");
    }
    const creatorId = await this.resolveUserId(input.createdBy);
    const channel = input.channel ?? "SMS";
    const [existingMessage] = await db
      .select()
      .from(messages)
      .where(and(eq(messages.contentId, input.contentId), eq(messages.channel, channel)))
      .limit(1);
    if (existingMessage) {
      const existingRecipients = await this.listRecipients(existingMessage.id);
      return { message: existingMessage, recipients: existingRecipients };
    }

    const [masterMessage] = await db
      .insert(messages)
      .values({
        title: input.title ?? "Advisory Broadcast",
        body: input.body,
        contentId: input.contentId,
        channel,
        status: "SIMULATED",
        createdBy: creatorId,
      })
      .onConflictDoNothing()
      .returning();
    if (!masterMessage) {
      const [racedMessage] = await db
        .select()
        .from(messages)
        .where(and(eq(messages.contentId, input.contentId), eq(messages.channel, channel)))
        .limit(1);
      if (!racedMessage) throw new Error("Broadcast conflict occurred but the existing record could not be loaded");
      return { message: racedMessage, recipients: await this.listRecipients(racedMessage.id) };
    }

    const uniqueFarmerIds = [...new Set(input.farmerIds)];
    const eligibleFarmers = uniqueFarmerIds.length
      ? await db
          .select({ id: farmers.id, phone: users.phone })
          .from(farmers)
          .innerJoin(users, eq(users.id, farmers.userId))
          .where(and(
            inArray(farmers.id, uniqueFarmerIds),
            eq(farmers.alertEnabled, true),
            eq(users.active, true),
            eq(users.status, "APPROVED"),
          ))
      : [];
    const attemptedAt = new Date();
    const recipientRows = eligibleFarmers.map((farmer) => ({
      messageId: masterMessage.id,
      farmerId: farmer.id,
      status: farmer.phone?.trim() ? "SIMULATED_SENT" : "SIMULATED_FAILED",
      deliveryMode: "SIMULATED",
      failureReason: farmer.phone?.trim() ? null : "MISSING_PHONE",
      sentAt: attemptedAt,
      deliveredAt: null,
    }));
    const insertedRecipients = recipientRows.length
      ? await db
          .insert(messageRecipients)
          .values(recipientRows)
          .onConflictDoNothing()
          .returning()
      : [];

    return {
      message: masterMessage,
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
        contentId: input.contentId ?? null,
        channel: input.channel,
        status: "QUEUED",
        createdBy: creatorId,
      })
      .returning();

    // Link recipient farmer if phone matches a farmer
    if (input.recipientPhone) {
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
          status: "QUEUED",
          deliveryMode: "SIMULATED",
        });
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
