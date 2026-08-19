import express from "express";

import cropRoutes from "./modules/crops/crop.routes";
import farmerRoutes from "./modules/farmers/farmer.routes";

const app = express();

app.use(express.json());

app.get("/", (_req, res) => {
  res.json({
    message: "Agri-Insight Beacon API is running",
  });
});

app.use("/api/crops", cropRoutes);
app.use("/api/farmers", farmerRoutes);

export default app;