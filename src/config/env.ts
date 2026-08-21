/**
 * Environment configuration — Member 3 (Backend Foundation, Auth & Security)
 *
 * Loads and validates ALL environment variables at startup using Zod.
 * The process exits immediately if required variables are missing/invalid,
 * so misconfiguration can never reach runtime.
 *
 * Setup: copy the repo-root `.env.example` to `backend/.env` and fill values.
 * NEVER commit `.env` (it is gitignored).
 */
import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),

  PORT: z.coerce.number().int().positive().default(4000),

  // PostgreSQL connection string, e.g. postgresql://agri:agri_password@localhost:5432/agri_insight
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),

  // Secret used to sign JWT ACCESS tokens. Minimum 32 chars — generate with: openssl rand -base64 48
  JWT_ACCESS_SECRET: z.string().min(32, 'JWT_ACCESS_SECRET must be at least 32 characters'),

  // Access token lifetime. Team decision (see docs/authentication-contract.md):
  // 15 minutes — short-lived so a leaked token expires quickly.
  // The REFRESH token keeps the session alive, so users are not logged out.
  JWT_ACCESS_TTL: z.string().default('15m'),

  // Refresh token lifetime in days. Team decision: 7 days.
  // Refresh tokens are opaque random strings stored HASHED in the refresh_tokens table
  // and are ROTATED on every use (old one is revoked).
  REFRESH_TOKEN_TTL_DAYS: z.coerce.number().int().positive().default(7),

  // Comma-separated list of allowed CORS origins (Flutter dev runners, etc.)
  CORS_ORIGINS: z.string().default('http://localhost:3000,http://localhost:8081'),

  // Login brute-force protection: max attempts per window per IP (team decision: 5 / 15 min).
  AUTH_RATE_LIMIT_WINDOW_MINUTES: z.coerce.number().int().positive().default(15),
  AUTH_RATE_LIMIT_MAX: z.coerce.number().int().positive().default(5),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  // Safe to print: only field names/validation issues, never secret values.
  console.error('Invalid environment configuration:');
  console.error(JSON.stringify(parsed.error.flatten().fieldErrors, null, 2));
  process.exit(1);
}

export const env = {
  ...parsed.data,
  isProd: parsed.data.NODE_ENV === 'production',
  isTest: parsed.data.NODE_ENV === 'test',
  corsOrigins: parsed.data.CORS_ORIGINS.split(',').map((origin) => origin.trim()),
} as const;
