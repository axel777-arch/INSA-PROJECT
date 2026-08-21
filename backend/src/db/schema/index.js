"use strict";
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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
// Member 3 — auth & security tables (COMPLETE):
__exportStar(require("./users.js"), exports);
__exportStar(require("./refresh-tokens.js"), exports);
__exportStar(require("./audit-logs.js"), exports);
