/**
 * Minimal structured logger — Member 3
 *
 * SECURITY RULE (B25): never log passwords, tokens, password hashes, or full
 * request bodies. Log metadata only (ids, roles, action names).
 */
const ts = () => new Date().toISOString();

export const logger = {
  info: (...args: unknown[]) => console.log(`[${ts()}] INFO `, ...args),
  warn: (...args: unknown[]) => console.warn(`[${ts()}] WARN `, ...args),
  error: (...args: unknown[]) => console.error(`[${ts()}] ERROR`, ...args),
};
