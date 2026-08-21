/**
 * Drizzle Kit configuration — Member 3
 *
 * `schema` points at the schema barrel, so teammate tables (Members 4/5/6) are
 * picked up automatically once they re-export them from src/db/schema/index.ts.
 *
 * `out` targets the REPO-ROOT database/migrations/ folder (repo structure B3),
 * which Member 4 owns. Run drizzle-kit from inside backend/:
 *   cd backend && npm run db:generate
 *
 * COORDINATION (Member 4): if you relocate schema files to database/schema/,
 * update the `schema` path here accordingly.
 */
import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/db/schema/index.ts',
  out: '../database/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL ?? '',
  },
  strict: true,
  verbose: true,
});
