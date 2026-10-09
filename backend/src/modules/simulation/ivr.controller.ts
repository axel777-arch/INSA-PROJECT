import type { Request, Response } from 'express';
import { ivrSimulator } from '../../services/ivr/ivr.simulator';

export function startIvrSessionHandler(req: Request, res: Response): void {
  const { phone, farmerId } = req.body ?? {};
  const session = ivrSimulator.startSession({ phone, farmerId });

  res.status(200).json({
    sessionId: session.sessionId,
    phone: session.phone,
    farmerId: session.farmerId,
    status: session.status,
    currentMenu: session.currentMenu,
    prompt: session.prompt,
    message: session.prompt,
  });
}

export function sendIvrDtmfHandler(req: Request, res: Response): void {
  const { sessionId, key } = req.body ?? {};

  if (!sessionId || key === undefined) {
    res.status(400).json({ error: 'sessionId and key are required' });
    return;
  }

  const session = ivrSimulator.handleDtmf(sessionId, String(key));

  res.status(200).json({
    sessionId: session.sessionId,
    phone: session.phone,
    status: session.status,
    currentMenu: session.currentMenu,
    prompt: session.prompt,
    message: session.prompt,
    lastInput: session.lastInput,
  });
}

export function endIvrSessionHandler(req: Request, res: Response): void {
  const { sessionId } = req.body ?? {};

  if (!sessionId) {
    res.status(400).json({ error: 'sessionId is required' });
    return;
  }

  const session = ivrSimulator.endSession(sessionId);

  res.status(200).json({
    sessionId: session.sessionId,
    status: session.status,
    prompt: session.prompt,
    message: session.prompt,
  });
}

export function getIvrSessionHandler(req: Request, res: Response): void {
  const rawSessionId = req.params.sessionId;
  const sessionId = typeof rawSessionId === 'string' ? rawSessionId : Array.isArray(rawSessionId) ? rawSessionId[0] : String(rawSessionId ?? '');
  const session = ivrSimulator.getSession(sessionId);

  if (!session) {
    res.status(404).json({ error: 'IVR session not found' });
    return;
  }

  res.status(200).json(session);
}
