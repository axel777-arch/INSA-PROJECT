import app from "./app";
import { db } from "./config/database";
import { sql } from "drizzle-orm";

// Default to 3000 so mobile/.env API_BASE_URL=http://localhost:3000/api works out of the box
const PORT = Number(process.env.PORT) || 3000;

async function startServer() {
  try {
    const result = await db.execute(sql`SELECT NOW() AS time`);
    console.log("[DATABASE] Connected:", (result.rows[0] as any).time);

    app.listen(PORT, () => {
      console.log(`[SERVER] Agri-Insight Beacon API running on http://localhost:${PORT}`);
      console.log(`[SERVER] Environment: ${process.env.NODE_ENV ?? 'development'}`);
    });
  } catch (error) {
    console.error("[SERVER] Database connection failed:", error);
    process.exit(1);
  }
}

startServer();
