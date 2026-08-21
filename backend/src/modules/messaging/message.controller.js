"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createSmsMessage = createSmsMessage;
const sms_simulator_1 = require("../../services/sms/sms.simulator");
const message_service_1 = require("./message.service");
const smsSimulator = new sms_simulator_1.SmsSimulator();
const messageService = new message_service_1.MessageService();
function createSmsMessage(req, res) {
    const payload = req.body ?? {};
    const recipient = typeof payload.recipient === 'string' ? payload.recipient : '';
    const messageText = typeof payload.message === 'string' ? payload.message : '';
    const contentId = typeof payload.contentId === 'string' ? payload.contentId : '';
    const createdBy = typeof payload.createdBy === 'string' ? payload.createdBy : '';
    if (!recipient || !messageText || !contentId || !createdBy) {
        res.status(400).json({ error: 'recipient, message, contentId, and createdBy are required.' });
        return;
    }
    const message = smsSimulator.send({ recipient, message: messageText });
    const record = messageService.createMessage({
        contentId,
        channel: 'SMS',
        createdBy,
    });
    res.status(201).json({
        message,
        record,
        status: 'QUEUED',
    });
}
