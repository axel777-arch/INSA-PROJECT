/**
 * Server entry point — Member 3
 *
 * Verifies the database connection BEFORE accepting traffic (fail fast),
 * then starts the HTTP listener and registers graceful shutdown handlers.
 */
import { createApp } from './app.js';
import { env } from './config/env.js';
import { pool } from './db/index.js';
import { logger } from './utils/logger.js';

async function main(): Promise<void> {
  // Fail fast if PostgreSQL is unreachable (docker compose up -d first).
  await pool.query('SELECT 1');
  logger.info('Database connection established');

  const app = createApp();
  const server = app.listen(env.PORT, () => {
    logger.info(`Agri-Insight Beacon API listening on http://localhost:${env.PORT}/api (${env.NODE_ENV})`);
  });

  const shutdown = async (signal: string): Promise<void> => {
    logger.info(`${signal} received — shutting down gracefully`);
    server.close();
    await pool.end();
    process.exit(0);
  };

  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
}

main().catch((err) => {
  logger.error('Fatal startup error', err);
  process.exit(1);
});
