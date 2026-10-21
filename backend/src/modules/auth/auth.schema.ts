import { z } from 'zod';

export const phoneSchema = z.string().refine((value) => /^(09\d{8}|\+251\d{9})$/.test(value), {
  message: 'Phone must be 10 digits starting with 09 or 13 characters starting with +251',
});

export const loginSchema = z
  .object({
    identifier: z.string().trim().optional(),
    email: z.string().trim().optional(),
    phone: z.string().trim().optional(),
    username: z.string().trim().optional(),
    password: z.string().min(1, 'Password is required'),
  })
  .transform((data) => {
    const identifier = (data.identifier || data.email || data.phone || data.username || '').trim();
    return {
      identifier,
      password: data.password,
    };
  })
  .refine((data) => data.identifier.length > 0, {
    message: 'Identifier (phone or email) is required',
    path: ['identifier'],
  });

export const registerSchema = z.object({
  fullName: z.string().trim().min(2).max(120),
  phone: phoneSchema,
  email: z.string().email().optional(),
  password: z.string().min(8, 'Password must be at least 8 characters').max(128),
  role: z.enum(['FARMER', 'EXTENSION_WORKER', 'EXPERT']),
  preferredLanguage: z.string().default('en'),
});
