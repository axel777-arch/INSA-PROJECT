import app from "./app";
import { db } from "./config/database";
import { sql } from "drizzle-orm";

const PORT = Number(process.env.PORT) || 5000;

async function startServer() {
  try {
    const result = await db.execute(sql`SELECT NOW() AS time`);

    console.log("DATABASE CONNECTED:", result.rows[0]);

    // Keep additive case-response fields available when an older database is used.
    await db.execute(sql`
      ALTER TABLE "field_observations"
        ADD COLUMN IF NOT EXISTS "diagnosis" text,
        ADD COLUMN IF NOT EXISTS "recommendation" text,
        ADD COLUMN IF NOT EXISTS "internal_notes" text,
        ADD COLUMN IF NOT EXISTS "photo_data" text[] NOT NULL DEFAULT '{}',
        ADD COLUMN IF NOT EXISTS "responded_by" uuid REFERENCES "users"("id"),
        ADD COLUMN IF NOT EXISTS "responded_at" timestamp with time zone
    `);
    console.log("FIELD CASE RESPONSE SCHEMA READY");

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`AGRI-INSIGHT BEACON API RUNNING ON PORT ${PORT}`);
    });
  } catch (error) {
    console.error("DATABASE CONNECTION FAILED:", error);
    process.exit(1);
  }
}

startServer();
