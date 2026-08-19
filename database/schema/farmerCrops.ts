import { primaryKey, uuid, pgTable } from "drizzle-orm/pg-core";
import { farmers } from "./farmers";
import { crops } from "./crops";

export const farmerCrops = pgTable(
  "farmer_crops",
  {
    farmerId: uuid("farmer_id")
      .notNull()
      .references(() => farmers.id, { onDelete: "cascade" }),

    cropId: uuid("crop_id")
      .notNull()
      .references(() => crops.id, { onDelete: "cascade" }),
  },
  (table) => ({
    pk: primaryKey({ columns: [table.farmerId, table.cropId] }),
  }),
);
