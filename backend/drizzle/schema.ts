import { pgTable, uuid, text, doublePrecision, boolean, timestamp, foreignKey, primaryKey } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"



export const farmers = pgTable("farmers", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id").notNull(),
	region: text(),
	zone: text(),
	woreda: text(),
	kebele: text(),
	latitude: doublePrecision(),
	longitude: doublePrecision(),
	alertEnabled: boolean("alert_enabled").default(true).notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
});

export const crops = pgTable("crops", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	name: text().notNull(),
	description: text(),
	active: boolean().default(true).notNull(),
});

export const farmerCrops = pgTable("farmer_crops", {
	farmerId: uuid("farmer_id").notNull(),
	cropId: uuid("crop_id").notNull(),
}, (table) => [
	foreignKey({
			columns: [table.farmerId],
			foreignColumns: [farmers.id],
			name: "farmer_crops_farmer_id_farmers_id_fk"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.cropId],
			foreignColumns: [crops.id],
			name: "farmer_crops_crop_id_crops_id_fk"
		}).onDelete("cascade"),
	primaryKey({ columns: [table.farmerId, table.cropId], name: "farmer_crops_farmer_id_crop_id_pk"}),
]);
