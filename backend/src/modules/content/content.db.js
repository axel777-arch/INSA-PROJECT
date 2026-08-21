"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = void 0;
const pg_1 = require("pg");
const node_postgres_1 = require("drizzle-orm/node-postgres");
const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
    throw new Error("DATABASE_URL is not set. The content module requires a PostgreSQL " +
        "connection string to be provided via environment variables.");
}
const pool = new pg_1.Pool({ connectionString });
exports.db = (0, node_postgres_1.drizzle)(pool);
