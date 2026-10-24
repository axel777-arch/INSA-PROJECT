import { eq } from "drizzle-orm";
import { db } from "../../db/index";
import { messages } from "../../../../database/schema/messages";
import { users } from "../../../../database/schema/users";
import type { SmsMessage, SmsProvider, SmsSendPayload, SmsStatus } from "./sms.types";

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export class SmsSimulator implements SmsProvider {
  private readonly validTransitions: Record<SmsStatus, SmsStatus[]> = {
    QUEUED: ["SENT", "FAILED"],
    SENT: ["DELIVERED", "FAILED"],
    DELIVERED: [],
    FAILED: [],
  };

  canTransition(from: SmsStatus, to: SmsStatus): boolean {
    return this.validTransitions[from]?.includes(to) ?? false;
  }

  send(payload: SmsSendPayload): SmsMessage {
    const now = new Date();
    const id = this.makeId("QUEUED");
    const message: SmsMessage = {
      id,
      recipient: payload.recipient,
      message: payload.message,
      status: "QUEUED",
      createdAt: now,
      updatedAt: now,
    };

    // Asynchronously persist to database if available
    this.persistToDb(message).catch((err) => {
      // Background non-blocking error log
      console.warn("[SMS SIMULATOR] Background DB persistence warning:", err.message);
    });

    return message;
  }

  updateStatus(id: string, status: SmsStatus): SmsMessage {
    const currentStatus = this.extractStatusFromId(id);

    if (!this.canTransition(currentStatus, status)) {
      throw new Error(`SMS status transition from ${currentStatus} to ${status} is invalid.`);
    }

    const now = new Date();
    const updated: SmsMessage = {
      id: this.makeId(status, id),
      recipient: "",
      message: "",
      status,
      createdAt: now,
      updatedAt: now,
    };

    // Asynchronously update in database if available
    this.updateDb(id, status).catch((err) => {
      console.warn("[SMS SIMULATOR] Background DB update warning:", err.message);
    });

    return updated;
  }

  private extractStatusFromId(id: string): SmsStatus {
    const parts = id.split("_");
    if (parts.length >= 2 && (parts[1] === "QUEUED" || parts[1] === "SENT" || parts[1] === "DELIVERED" || parts[1] === "FAILED")) {
      return parts[1] as SmsStatus;
    }
    return "QUEUED";
  }

  private makeId(status: SmsStatus, prevId?: string): string {
    const seed = prevId ? prevId.split("_").slice(2).join("_") : Math.random().toString(36).slice(2, 10);
    return `sms_${status}_${seed}`;
  }

  private async persistToDb(message: SmsMessage): Promise<void> {
    if (!db) return;
    try {
      const [firstUser] = await db.select({ id: users.id }).from(users).limit(1);
      const creatorId = firstUser?.id;
      if (!creatorId) return;

      await db.insert(messages).values({
        title: "SMS Simulator Message",
        body: message.message,
        channel: "SMS",
        status: message.status,
        createdBy: creatorId,
      });
    } catch {
      // Ignore background persistence errors
    }
  }

  private async updateDb(id: string, status: SmsStatus): Promise<void> {
    if (!db) return;
    try {
      if (UUID_REGEX.test(id)) {
        await db.update(messages).set({ status }).where(eq(messages.id, id));
      }
    } catch {
      // Ignore
    }
  }
}

