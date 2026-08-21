"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cropsRelations = exports.farmersRelations = exports.farmerCropsRelations = void 0;
const relations_1 = require("drizzle-orm/relations");
const schema_1 = require("./schema");
exports.farmerCropsRelations = (0, relations_1.relations)(schema_1.farmerCrops, ({ one }) => ({
    farmer: one(schema_1.farmers, {
        fields: [schema_1.farmerCrops.farmerId],
        references: [schema_1.farmers.id]
    }),
    crop: one(schema_1.crops, {
        fields: [schema_1.farmerCrops.cropId],
        references: [schema_1.crops.id]
    }),
}));
exports.farmersRelations = (0, relations_1.relations)(schema_1.farmers, ({ many }) => ({
    farmerCrops: many(schema_1.farmerCrops),
}));
exports.cropsRelations = (0, relations_1.relations)(schema_1.crops, ({ many }) => ({
    farmerCrops: many(schema_1.farmerCrops),
}));
