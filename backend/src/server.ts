import app from "./app";
import { db } from "./config/database";
import { sql } from "drizzle-orm";

const PORT = Number(process.env.PORT) || 5000;

async function startServer() {
  try {
    const result = await db.execute(sql`SELECT NOW() AS time`);

    console.log("DATABASE CONNECTED:", result.rows[0]);

    app.listen(PORT, () => {
      console.log(`AGRI-INSIGHT BEACON API RUNNING ON PORT ${PORT}`);
    });
  } catch (error) {
    console.error("DATABASE CONNECTION FAILED:", error);
    process.exit(1);
  }
}

startServer();
