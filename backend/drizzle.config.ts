import { defineConfig } from "drizzle-kit";
import "dotenv/config";

export default defineConfig({
  schema: "../database/schema/index.ts",
  out: "../database/migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
