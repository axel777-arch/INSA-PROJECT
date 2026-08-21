"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.farmers = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
const users_1 = require("./users");
exports.farmers = (0, pg_core_1.pgTable)("farmers", {
    id: (0, pg_core_1.uuid)("id").defaultRandom().primaryKey(),
    userId: (0, pg_core_1.uuid)("user_id")
        .notNull()
        .references(() => users_1.users.id, { onDelete: "cascade" }),
    region: (0, pg_core_1.text)("region"),
    zone: (0, pg_core_1.text)("zone"),
    woreda: (0, pg_core_1.text)("woreda"),
    kebele: (0, pg_core_1.text)("kebele"),
    latitude: (0, pg_core_1.doublePrecision)("latitude"),
    longitude: (0, pg_core_1.doublePrecision)("longitude"),
    alertEnabled: (0, pg_core_1.boolean)("alert_enabled")
        .notNull()
        .default(true),
    createdAt: (0, pg_core_1.timestamp)("created_at", {
        withTimezone: true,
    })
        .notNull()
        .defaultNow(),
    updatedAt: (0, pg_core_1.timestamp)("updated_at", {
        withTimezone: true,
    })
        .notNull()
        .defaultNow(),
}, (table) => ({
    userIdUnique: (0, pg_core_1.uniqueIndex)("farmers_user_id_unique").on(table.userId),
}));
