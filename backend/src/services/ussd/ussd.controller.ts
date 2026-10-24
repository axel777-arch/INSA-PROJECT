import type { NextFunction, Request, Response } from 'express';

import { UssdSessionService, UssdValidationError } from './ussd.service';

const ussdService = new UssdSessionService();

export function handleUssdCallback(req: Request, res: Response, next: NextFunction): void {
  const payload = req.body ?? {};
  const sessionId = typeof payload.sessionId === 'string' ? payload.sessionId : '';
  const serviceCode = typeof payload.serviceCode === 'string' ? payload.serviceCode : '';
  const phoneNumber = typeof payload.phoneNumber === 'string' ? payload.phoneNumber : '';
  const text = payload.text === undefined ? '' : payload.text;

  if (!sessionId || !serviceCode || !phoneNumber || typeof text !== 'string') {
    res.status(400).type('text/plain').send('END Invalid USSD callback payload.');
    return;
  }

  try {
    const response = ussdService.handleRequest({
      sessionId,
      serviceCode,
      phoneNumber,
      text,
    });

    res.type('text/plain').send(response);
  } catch (error) {
    if (error instanceof UssdValidationError) {
      res.status(400).type('text/plain').send('END Invalid USSD callback payload.');
      return;
    }
    next(error);
  }
}
