import type { Request, Response } from 'express';

import { UssdSessionService } from './ussd.service';

const ussdService = new UssdSessionService();

export function handleUssdCallback(req: Request, res: Response): void {
  const payload = req.body ?? {};
  const sessionId = typeof payload.sessionId === 'string' ? payload.sessionId : '';
  const serviceCode = typeof payload.serviceCode === 'string' ? payload.serviceCode : '';
  const phoneNumber = typeof payload.phoneNumber === 'string' ? payload.phoneNumber : '';
  const text = typeof payload.text === 'string' ? payload.text : '';

  if (!sessionId || !serviceCode || !phoneNumber) {
    res.status(400).type('text/plain').send('END Invalid USSD callback payload.');
    return;
  }

  const response = ussdService.handleRequest({
    sessionId,
    serviceCode,
    phoneNumber,
    text,
  });

  res.type('text/plain').send(response);
}
