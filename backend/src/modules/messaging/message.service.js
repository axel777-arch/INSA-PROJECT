"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MessageService = void 0;
class MessageService {
    createMessage(input) {
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
    updateMessageStatus(message, status) {
        return {
            ...message,
            status,
            updatedAt: new Date(),
        };
    }
    makeId() {
        return `message_${Math.random().toString(36).slice(2, 10)}`;
    }
}
exports.MessageService = MessageService;
