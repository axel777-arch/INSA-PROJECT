"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllCrops = getAllCrops;
exports.createCrop = createCrop;
const drizzle_orm_1 = require("drizzle-orm");
const database_1 = require("../../config/database");
const schema_1 = require("../../../../database/schema");
async function getAllCrops() {
    return database_1.db.select().from(schema_1.crops);
}
async function createCrop(data) {
    const existing = await database_1.db
        .select()
        .from(schema_1.crops)
        .where((0, drizzle_orm_1.eq)(schema_1.crops.name, data.name))
        .limit(1);
    if (existing.length > 0) {
        const error = new Error("Crop with this name already exists");
        error.code = "CONFLICT";
        throw error;
    }
    const [crop] = await database_1.db
        .insert(schema_1.crops)
        .values(data)
        .returning();
    return crop;
}
