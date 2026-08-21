"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.farmerCrops = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
const farmers_1 = require("./farmers");
const crops_1 = require("./crops");
exports.farmerCrops = (0, pg_core_1.pgTable)("farmer_crops", {
    farmerId: (0, pg_core_1.uuid)("farmer_id")
        .notNull()
        .references(() => farmers_1.farmers.id, { onDelete: "cascade" }),
    cropId: (0, pg_core_1.uuid)("crop_id")
        .notNull()
        .references(() => crops_1.crops.id, { onDelete: "cascade" }),
}, (table) => ({
    pk: (0, pg_core_1.primaryKey)({ columns: [table.farmerId, table.cropId] }),
}));
