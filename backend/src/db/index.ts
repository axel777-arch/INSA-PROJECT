import "dotenv/config";
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from '../../../database/schema';
import * as refreshTokensSchema from './schema/refresh-tokens';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5433/agri_insight',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

export const db = drizzle(pool, { schema: { ...schema, ...refreshTokensSchema } });
export function getDb() {
  return db;
}
export { pool };
