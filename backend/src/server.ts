import app from "./app";
import { db } from "./db/index";
import { sql } from "drizzle-orm";

// Use a separate local port to avoid conflicts with other development servers.
const PORT = Number(process.env.PORT) || 3001;

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
