import type { CreateMessageInput, MessageRecord } from "./message.types";

export class MessageService {
  createMessage(input: CreateMessageInput): MessageRecord {
    const now = new Date();

    return {
      id: this.makeId(),
      contentId: input.contentId,
      channel: input.channel,
      status: "QUEUED",
      createdBy: input.createdBy,
      createdAt: now,
      updatedAt: now,
    };
  }

  updateMessageStatus(message: MessageRecord, status: MessageRecord["status"]): MessageRecord {
    return {
      ...message,
      status,
      updatedAt: new Date(),
    };
  }

  private makeId(): string {
    return `message_${Math.random().toString(36).slice(2, 10)}`;
  }
}
