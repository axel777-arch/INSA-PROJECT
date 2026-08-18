/**
 * Demo seed — Member 3 (users only)
 *
 * Creates the four demo accounts agreed by the team (analysis §10).
 * EXPERT and ADMIN exist ONLY via this seed — self-registration is restricted
 * to FARMER / EXTENSION_WORKER.
 *
 * Run with:  npm run db:seed        (after migrations / db:push)
 *
 * Idempotent: existing emails are skipped, so it is safe to re-run.
 *
 * ── TEAMMATE PLACEHOLDERS ──────────────────────────────────────────────────
 * Member 4: seed crops (Teff, Wheat, Maize, Barley, Sorghum), regions
 *           (Amhara, Oromia, Tigray, SNNPR) and the demo farmer's profile +
 *           crop assignments. Extend this file or add database/seed/ scripts.
 * Member 5: seed demo content in each status (DRAFT, IN_REVIEW, APPROVED,
 *           PUBLISHED, ARCHIVED) so the review workflow can be demoed.
 * ───────────────────────────────────────────────────────────────────────────
 */
import { eq } from 'drizzle-orm';
import { db, pool } from './index.js';
import { users } from './schema/users.js';
import { hashPassword } from '../modules/auth/password.service.js';
import type { UserRole } from '../config/constants.js';
import { logger } from '../utils/logger.js';

// Demo credentials — documented in the README; demo-only, never for production.
const SEED_USERS: Array<{ fullName: string; email: string; password: string; role: UserRole }> = [
  { fullName: 'Admin User', email: 'admin@agri.local', password: 'Admin123!', role: 'ADMIN' },
  { fullName: 'Expert User', email: 'expert@agri.local', password: 'Expert123!', role: 'EXPERT' },
  { fullName: 'Extension Worker', email: 'worker@agri.local', password: 'Worker123!', role: 'EXTENSION_WORKER' },
  { fullName: 'Demo Farmer', email: 'farmer@agri.local', password: 'Farmer123!', role: 'FARMER' },
];

async function seed(): Promise<void> {
  for (const seedUser of SEED_USERS) {
    const existing = await db.query.users.findFirst({ where: eq(users.email, seedUser.email) });
    if (existing) {
      logger.info(`skip  ${seedUser.email} (already exists)`);
      continue;
    }
    await db.insert(users).values({
      fullName: seedUser.fullName,
      email: seedUser.email,
      passwordHash: await hashPassword(seedUser.password),
      role: seedUser.role,
      preferredLanguage: 'en',
    });
    logger.info(`seed  ${seedUser.email} (${seedUser.role})`);
  }
  logger.info('User seed complete.');
}

seed()
  .catch((err) => {
    logger.error('Seed failed', err);
    process.exitCode = 1;
  })
  .finally(() => void pool.end());
