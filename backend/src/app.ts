import express from "express";
import type { Request, Response, NextFunction } from "express";

import cropRoutes from "./modules/crops/crop.routes";
import farmerRoutes from "./modules/farmers/farmer.routes";
import authRoutes from "./modules/auth/auth.routes";
import contentRoutes from "./modules/content/content.routes";
import messagingRoutes from './modules/messaging/messaging.routes';
import adminRoutes from './modules/admin/admin.routes';
import ivrRoutes from './modules/simulation/ivr.routes';
import { matchFarmers } from './services/targeting/targeting.controller';
import { handleUssdCallback } from './services/ussd/ussd.controller';
import { requestLogger } from './middleware/logger.middleware';
import { errorHandler } from './middleware/error.middleware';

const app = express();

// ── CORS ─────────────────────────────────────────────────────────────────────
const ALLOWED_ORIGINS = (process.env.CORS_ORIGINS ?? 'http://localhost:3000,http://localhost:8080,http://10.0.2.2:3000,http://10.0.0.2:3000')
  .split(',')
  .map((o) => o.trim());

app.use((req: Request, res: Response, next: NextFunction) => {
  const origin = req.headers.origin ?? '';
  const isLocalhost = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
  if (ALLOWED_ORIGINS.includes(origin) || ALLOWED_ORIGINS.includes('*') || isLocalhost) {
    res.setHeader('Access-Control-Allow-Origin', origin || '*');
  } else {
    // Allow all in development; tighten in production
    res.setHeader('Access-Control-Allow-Origin', '*');
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(204);
    return;
  }
  next();
});

// ── Body parser ───────────────────────────────────────────────────────────────
app.use(express.json());

// ── Request / response logger ─────────────────────────────────────────────────
app.use(requestLogger);

// ── Health check ──────────────────────────────────────────────────────────────
app.get("/", (_req, res) => {
  res.json({ message: "Agri-Insight Beacon API is running" });
});

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// ── Feature routes ────────────────────────────────────────────────────────────
app.use("/api/auth", authRoutes);
app.use("/api/crops", cropRoutes);
app.use("/api/farmers", farmerRoutes);
app.use("/api/content", contentRoutes);           // ← was missing, now mounted
app.use("/api/messaging", messagingRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/simulation/ivr", ivrRoutes);
app.use("/api/messaging/ivr", ivrRoutes);

// ── Standalone handlers ───────────────────────────────────────────────────────
app.post('/api/ussd', handleUssdCallback);
app.post('/api/targeting/match', matchFarmers);

// ── Centralised error handler (must be last) ──────────────────────────────────
app.use(errorHandler);

export default app;
