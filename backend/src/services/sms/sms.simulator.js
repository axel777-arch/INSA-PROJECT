"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmsSimulator = void 0;
class SmsSimulator {
    messages = new Map();
    validTransitions = {
        QUEUED: ["SENT", "FAILED"],
        SENT: ["DELIVERED", "FAILED"],
        DELIVERED: [],
        FAILED: [],
    };
    canTransition(from, to) {
        return this.validTransitions[from]?.includes(to) ?? false;
    }
    send(payload) {
        const now = new Date();
        const message = {
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
    updateStatus(id, status) {
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
    makeId() {
        return `sms_${Math.random().toString(36).slice(2, 10)}`;
    }
}
exports.SmsSimulator = SmsSimulator;
