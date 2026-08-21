import { z } from 'zod';

const phone = z.string().refine((value) => /^(09\d{8}|\+251\d{9})$/.test(value), {
	message: 'Phone must be 10 digits starting with 09 or 14 characters starting with +251',
});

export const loginSchema = z.object({ identifier: z.string().trim().min(1), password: z.string().min(6) });
export const registerSchema = z.object({
	fullName: z.string().trim().min(2).max(120), phone, email: z.string().email().optional(),
	password: z.string().min(6).max(128), role: z.enum(['FARMER', 'EXTENSION_WORKER', 'EXPERT']),
	preferredLanguage: z.string().default('en'),
});
