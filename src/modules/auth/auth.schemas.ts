/**
 * Auth request schemas (Zod) — Member 3
 *
 * Team decisions encoded here:
 *   - Password policy: min 8 chars, at least one letter and one number (§2c).
 *   - Self-registration role: FARMER or EXTENSION_WORKER only — EXPERT/ADMIN
 *     are created via the seed script (§2b). Sending any other role is a 400.
 *   - preferredLanguage drives Member 5's content targeting, not UI language.
 *
 * Team members: reuse `uuidParamSchema` and `paginationQuerySchema` in your
 * own routes so ID/pagination validation stays consistent across modules.
 */
import { z } from 'zod';
import { SELF_REGISTERABLE_ROLES } from '../../config/constants.js';

export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(128, 'Password must be at most 128 characters')
  .regex(/[A-Za-z]/, 'Password must contain at least one letter')
  .regex(/[0-9]/, 'Password must contain at least one number');

export const registerSchema = z.object({
  fullName: z.string().trim().min(2, 'Full name is required').max(120),
  email: z.string().trim().toLowerCase().email('A valid email is required'),
  phone: z
    .string()
    .trim()
    .regex(/^\+?[0-9]{7,15}$/, 'Phone must be 7-15 digits, optionally starting with +')
    .optional(),
  password: passwordSchema,
  role: z.enum(SELF_REGISTERABLE_ROLES).default('FARMER'),
  preferredLanguage: z.string().trim().min(2).max(10).default('en'),
});

export const loginSchema = z.object({
  email: z.string().trim().toLowerCase().email('A valid email is required'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'refreshToken is required'),
});

/** Shared: validates `:id` route params as UUIDs. Reuse in every module. */
export const uuidParamSchema = z.object({
  id: z.string().uuid('Invalid id format (expected UUID)'),
});

/**
 * Shared pagination contract (team decision): ?page=1&limit=20.
 * List endpoints should respond with:
 *   { "data": [...], "pagination": { "page", "limit", "total", "totalPages" } }
 */
export const paginationQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
