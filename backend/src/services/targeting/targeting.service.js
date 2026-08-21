"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TargetingService = void 0;
const drizzle_orm_1 = require("drizzle-orm");
const crops_1 = require("../../../../database/schema/crops");
const farmerCrops_1 = require("../../../../database/schema/farmerCrops");
const farmers_1 = require("../../../../database/schema/farmers");
const cropTargeting_1 = require("./cropTargeting");
const languageTargeting_1 = require("./languageTargeting");
const locationTargeting_1 = require("./locationTargeting");
class TargetingService {
    findTargetFarmers({ cropName, location, language, farmers }) {
        const seen = new Set();
        return farmers.filter((farmer) => {
            const matches = farmer.alertEnabled &&
                (0, cropTargeting_1.matchesCrop)(farmer, cropName) &&
                (0, locationTargeting_1.matchesLocation)(farmer, location) &&
                (0, languageTargeting_1.matchesLanguage)(farmer, language);
            if (!matches || seen.has(farmer.id)) {
                return false;
            }
            seen.add(farmer.id);
            return true;
        });
    }
    async findTargetFarmersFromDb({ cropName, location, language, db, }) {
        if (!db) {
            return [];
        }
        const cropRecords = await db.select().from(crops_1.crops).where((0, drizzle_orm_1.ilike)(crops_1.crops.name, cropName)).limit(1);
        if (!cropRecords.length) {
            return [];
        }
        const cropId = cropRecords[0].id;
        const matchedRows = await db
            .select({
            id: farmers_1.farmers.id,
            preferredLanguage: farmers_1.farmers.preferredLanguage,
            region: farmers_1.farmers.region,
            zone: farmers_1.farmers.zone,
            alertEnabled: farmers_1.farmers.alertEnabled,
        })
            .from(farmers_1.farmers)
            .leftJoin(farmerCrops_1.farmerCrops, (0, drizzle_orm_1.eq)(farmerCrops_1.farmerCrops.farmerId, farmers_1.farmers.id))
            .where((0, drizzle_orm_1.and)((0, drizzle_orm_1.eq)(farmers_1.farmers.alertEnabled, true), (0, drizzle_orm_1.eq)(farmers_1.farmers.preferredLanguage, language), (0, drizzle_orm_1.eq)(farmerCrops_1.farmerCrops.cropId, cropId), (0, drizzle_orm_1.or)((0, drizzle_orm_1.eq)(farmers_1.farmers.region, location), (0, drizzle_orm_1.eq)(farmers_1.farmers.zone, location))));
        const normalized = matchedRows.map((row) => ({
            id: row.id,
            preferredLanguage: row.preferredLanguage,
            region: row.region,
            zone: row.zone ?? undefined,
            alertEnabled: row.alertEnabled,
            cropNames: [cropName],
        }));
        return [...new Map(normalized.map((item) => [item.id, item])).values()];
    }
}
exports.TargetingService = TargetingService;
