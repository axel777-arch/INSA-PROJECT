import type { SmsMessage, SmsProvider, SmsSendPayload, SmsStatus } from "./sms.types";

export class SmsSimulator implements SmsProvider {
  private messages = new Map<string, SmsMessage>();

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
    const message: SmsMessage = {
      id: this.makeId(),
      recipient: payload.recipient,
      message: payload.message,
      status: "QUEUED",
      createdAt: now,
      updatedAt: now,
    };

    this.messages.set(message.id, message);
    return message;
  }

  updateStatus(id: string, status: SmsStatus): SmsMessage {
    const current = this.messages.get(id);

    if (!current) {
      throw new Error(`SMS message ${id} was not found.`);
    }

    if (!this.canTransition(current.status, status)) {
      throw new Error(`SMS status transition from ${current.status} to ${status} is invalid.`);
    }

    const updated = {
      ...current,
      status,
      updatedAt: new Date(),
    };

    this.messages.set(id, updated);
    return updated;
  }

  private makeId(): string {
    return `sms_${Math.random().toString(36).slice(2, 10)}`;
  }
}
