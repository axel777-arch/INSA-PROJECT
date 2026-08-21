import { relations } from "drizzle-orm/relations";
import { farmers, farmerCrops, crops } from "./schema";

export const farmerCropsRelations = relations(farmerCrops, ({one}) => ({
	farmer: one(farmers, {
		fields: [farmerCrops.farmerId],
		references: [farmers.id]
	}),
	crop: one(crops, {
		fields: [farmerCrops.cropId],
		references: [crops.id]
	}),
}));

export const farmersRelations = relations(farmers, ({many}) => ({
	farmerCrops: many(farmerCrops),
}));

export const cropsRelations = relations(crops, ({many}) => ({
	farmerCrops: many(farmerCrops),
}));