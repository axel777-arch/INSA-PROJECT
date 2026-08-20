import type { Request, Response } from 'express';

import { SmsSimulator } from '../../services/sms/sms.simulator';
import { MessageService } from './message.service';

const smsSimulator = new SmsSimulator();
const messageService = new MessageService();

export function createSmsMessage(req: Request, res: Response): void {
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
