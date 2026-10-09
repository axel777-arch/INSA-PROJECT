import type { Request, Response } from 'express';

import { SmsSimulator } from '../../services/sms/sms.simulator';
import { MessageService } from './message.service';

const smsSimulator = new SmsSimulator();
const messageService = new MessageService();

export async function createSmsMessage(req: Request, res: Response): Promise<void> {
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

  const record = await messageService.createMessageAsync({
    contentId,
    title: 'Advisory SMS',
    body: messageText,
    channel: 'SMS',
    createdBy,
    recipientPhone: recipient,
  });

  res.status(201).json({
    message,
    record,
    status: 'QUEUED',
  });
}
