"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createFarmer = createFarmer;
exports.listFarmers = listFarmers;
exports.getFarmerById = getFarmerById;
exports.updateFarmer = updateFarmer;
exports.addCropToFarmer = addCropToFarmer;
exports.getFarmerCrops = getFarmerCrops;
const drizzle_orm_1 = require("drizzle-orm");
const database_1 = require("../../config/database");
const farmers_1 = require("../../../../database/schema/farmers");
const crops_1 = require("../../../../database/schema/crops");
const farmerCrops_1 = require("../../../../database/schema/farmerCrops");
async function createFarmer(data) {
    const [farmer] = await database_1.db.insert(farmers_1.farmers).values(data).returning();
    return farmer;
}
async function listFarmers() {
    return database_1.db.select().from(farmers_1.farmers);
}
async function getFarmerById(id) {
    const [farmer] = await database_1.db
        .select()
        .from(farmers_1.farmers)
        .where((0, drizzle_orm_1.eq)(farmers_1.farmers.id, id));
    return farmer;
}
async function updateFarmer(id, data) {
    const [farmer] = await database_1.db
        .update(farmers_1.farmers)
        .set({
        ...data,
        updatedAt: new Date(),
    })
        .where((0, drizzle_orm_1.eq)(farmers_1.farmers.id, id))
        .returning();
    return farmer;
}
async function addCropToFarmer(farmerId, cropId) {
    const [relation] = await database_1.db
        .insert(farmerCrops_1.farmerCrops)
        .values({ farmerId, cropId })
        .returning();
    return relation;
}
async function getFarmerCrops(farmerId) {
    return database_1.db
        .select({
        farmerId: farmerCrops_1.farmerCrops.farmerId,
        cropId: farmerCrops_1.farmerCrops.cropId,
        cropName: crops_1.crops.name,
        cropDescription: crops_1.crops.description,
        cropActive: crops_1.crops.active,
    })
        .from(farmerCrops_1.farmerCrops)
        .innerJoin(crops_1.crops, (0, drizzle_orm_1.eq)(farmerCrops_1.farmerCrops.cropId, crops_1.crops.id))
        .where((0, drizzle_orm_1.eq)(farmerCrops_1.farmerCrops.farmerId, farmerId));
}
