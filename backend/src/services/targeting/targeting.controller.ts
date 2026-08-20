import type { Request, Response } from 'express';

import { db } from '../../config/database';
import { TargetingService } from './targeting.service';

const targetingService = new TargetingService();

export async function matchFarmers(req: Request, res: Response): Promise<void> {
  const payload = req.body ?? {};
  const cropName = typeof payload.cropName === 'string' ? payload.cropName : '';
  const location = typeof payload.location === 'string' ? payload.location : '';
  const language = typeof payload.language === 'string' ? payload.language : '';
  const farmers = Array.isArray(payload.farmers) ? payload.farmers : [];

  if (!cropName || !location || !language) {
    res.status(400).json({ error: 'cropName, location, and language are required.' });
    return;
  }

  let matches;

  if (farmers.length > 0) {
    matches = targetingService.findTargetFarmers({ cropName, location, language, farmers });
  } else if (db) {
    matches = await targetingService.findTargetFarmersFromDb({ cropName, location, language, db });
  } else {
    matches = [];
  }

  res.status(200).json({ matches });
}
