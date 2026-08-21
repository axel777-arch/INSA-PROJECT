"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = __importDefault(require("./app"));
const database_1 = require("./config/database");
const drizzle_orm_1 = require("drizzle-orm");
const PORT = Number(process.env.PORT) || 5000;
async function startServer() {
    try {
        const result = await database_1.db.execute((0, drizzle_orm_1.sql) `SELECT NOW() AS time`);
        console.log("DATABASE CONNECTED:", result.rows[0]);
        app_1.default.listen(PORT, () => {
            console.log(`AGRI-INSIGHT BEACON API RUNNING ON PORT ${PORT}`);
        });
    }
    catch (error) {
        console.error("DATABASE CONNECTION FAILED:", error);
        process.exit(1);
    }
}
startServer();
