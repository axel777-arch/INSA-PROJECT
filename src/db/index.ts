/**
 * Database connection — Member 3 (Backend Foundation, Auth & Security)
 *
 * Creates the shared PostgreSQL pool + Drizzle client.
 * EVERY module (Members 4/5/6 included) must import the db client from here:
 *
 *     import { db } from '../../db/index.js';
 *
 * Do NOT create additional pools — one pool per process.
 */
import pg from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import { env } from '../config/env.js';
import * as schema from './schema/index.js';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: env.DATABASE_URL,
  max: 10,
});

export const db = drizzle(pool, { schema });

export type DbClient = typeof db;
