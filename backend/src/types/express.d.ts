/**
 * Express type augmentation — Member 3
 *
 * Makes `req.user` (attached by requireAuth) type-safe across ALL modules.
 * Members 4/5/6: after requireAuth you can safely read req.user!.id / .role.
 */
import type { UserRole } from '../config/constants.js';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: {
        id: string;
        role: UserRole;
      };
    }
  }
}

export {};
