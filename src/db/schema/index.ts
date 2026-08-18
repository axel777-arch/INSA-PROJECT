/**
 * Schema barrel — re-exports every Drizzle table so `drizzle-kit` and the
 * runtime `db` client see the full schema from one place.
 *
 * ── TEAMMATE PLACEHOLDERS ──────────────────────────────────────────────────
 * Add your schema files in this folder and re-export them below.
 * DO NOT modify the auth tables without coordinating with Member 3.
 *
 * Member 4 (Database, Farmers & Crops):
 *   export * from './farmers.js';        // farmers table (references users.id, ON DELETE CASCADE)
 *   export * from './crops.js';          // crops table
 *   export * from './farmer-crops.js';   // farmer_crops join table
 *
 * Member 5 (Content, Review & Targeting):
 *   export * from './content.js';        // content table (status enum from src/config/constants.ts)
 *   export * from './content-reviews.js';
 *
 * Member 6 (Messaging Simulation):
 *   export * from './messages.js';
 *   export * from './message-recipients.js';
 * ───────────────────────────────────────────────────────────────────────────
 */

// Member 3 — auth & security tables (COMPLETE):
export * from './users.js';
export * from './refresh-tokens.js';
export * from './audit-logs.js';
