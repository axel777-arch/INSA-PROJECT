"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.crops = void 0;
const pg_core_1 = require("drizzle-orm/pg-core");
exports.crops = (0, pg_core_1.pgTable)("crops", {
    id: (0, pg_core_1.uuid)("id").defaultRandom().primaryKey(),
    name: (0, pg_core_1.text)("name").notNull(),
    description: (0, pg_core_1.text)("description"),
    active: (0, pg_core_1.boolean)("active").notNull().default(true),
});
