"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.farmerCrops = exports.crops = exports.farmers = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
exports.farmers = (0, pg_core_1.pgTable)("farmers", {
    id: (0, pg_core_1.uuid)().defaultRandom().primaryKey().notNull(),
    userId: (0, pg_core_1.uuid)("user_id").notNull(),
    region: (0, pg_core_1.text)(),
    zone: (0, pg_core_1.text)(),
    woreda: (0, pg_core_1.text)(),
    kebele: (0, pg_core_1.text)(),
    latitude: (0, pg_core_1.doublePrecision)(),
    longitude: (0, pg_core_1.doublePrecision)(),
    alertEnabled: (0, pg_core_1.boolean)("alert_enabled").default(true).notNull(),
    createdAt: (0, pg_core_1.timestamp)("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
    updatedAt: (0, pg_core_1.timestamp)("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
});
exports.crops = (0, pg_core_1.pgTable)("crops", {
    id: (0, pg_core_1.uuid)().defaultRandom().primaryKey().notNull(),
    name: (0, pg_core_1.text)().notNull(),
    description: (0, pg_core_1.text)(),
    active: (0, pg_core_1.boolean)().default(true).notNull(),
});
exports.farmerCrops = (0, pg_core_1.pgTable)("farmer_crops", {
    farmerId: (0, pg_core_1.uuid)("farmer_id").notNull(),
    cropId: (0, pg_core_1.uuid)("crop_id").notNull(),
}, (table) => [
    (0, pg_core_1.foreignKey)({
        columns: [table.farmerId],
        foreignColumns: [exports.farmers.id],
        name: "farmer_crops_farmer_id_farmers_id_fk"
    }).onDelete("cascade"),
    (0, pg_core_1.foreignKey)({
        columns: [table.cropId],
        foreignColumns: [exports.crops.id],
        name: "farmer_crops_crop_id_crops_id_fk"
    }).onDelete("cascade"),
    (0, pg_core_1.primaryKey)({ columns: [table.farmerId, table.cropId], name: "farmer_crops_farmer_id_crop_id_pk" }),
]);
