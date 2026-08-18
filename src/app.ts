/**
 * Express application assembly — Member 3
 *
 * Security stack (team decision, analysis §11):
 *   helmet (secure headers) → CORS (whitelist) → 10kb JSON body limit
 *   → routes → 404 handler → centralized error handler
 *
 * ── TEAMMATE ROUTE PLACEHOLDERS ────────────────────────────────────────────
 * Each backend member mounts their router below as it is delivered.
 * IMPORTANT: every router MUST start protected routes with requireAuth and
 * the appropriate requirePermission(...) check — see src/middleware/.
 * ───────────────────────────────────────────────────────────────────────────
 */
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { env } from './config/env.js';
import { errorHandler, notFoundHandler } from './middleware/error.middleware.js';
import authRouter from './modules/auth/auth.routes.js';

// ── TEAMMATE PLACEHOLDER IMPORTS (uncomment when each module is delivered) ──
// import farmerRouter from './modules/farmers/farmer.routes.js';       // Member 4
// import cropRouter from './modules/crops/crop.routes.js';             // Member 4
// import contentRouter from './modules/content/content.routes.js';     // Member 5
// import messagingRouter from './modules/messaging/messaging.routes.js'; // Member 6
// import simulationRouter from './modules/messaging/simulation.routes.js'; // Member 6

export function createApp() {
  const app = express();

  app.disable('x-powered-by');

  // ── Security middleware (Member 3) ──
  app.use(helmet());
  app.use(cors({ origin: env.corsOrigins, credentials: true }));
  app.use(express.json({ limit: '10kb' })); // request size limit (team decision)

  // ── Health check (unauthenticated, used by CI and demo setup) ──
  app.get('/api/health', (_req, res) => {
    res.json({ data: { status: 'ok', service: 'agri-insight-beacon-backend', time: new Date().toISOString() } });
  });

  // ── Member 3: Authentication & security ──
  app.use('/api/auth', authRouter);

  // ── TEAMMATE ROUTE MOUNTS (uncomment as delivered; keep /api prefix — B12) ──
  // app.use('/api/farmers', farmerRouter);        // Member 4
  // app.use('/api/crops', cropRouter);            // Member 4
  // app.use('/api/content', contentRouter);       // Member 5
  // app.use('/api/messages', messagingRouter);    // Member 6
  // app.use('/api/simulation', simulationRouter); // Member 6

  // ── Error handling: 404 catch-all, then the centralized error handler (LAST) ──
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
