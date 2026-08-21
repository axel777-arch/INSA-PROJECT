import express from "express";

import cropRoutes from "./modules/crops/crop.routes";
import farmerRoutes from "./modules/farmers/farmer.routes";
import authRoutes from "./modules/auth/auth.routes";
import messagingRoutes from './modules/messaging/messaging.routes';
import { matchFarmers } from './services/targeting/targeting.controller';
import { handleUssdCallback } from './services/ussd/ussd.controller';

const app = express();

app.use(express.json());

app.get("/", (_req, res) => {
  res.json({
    message: "Agri-Insight Beacon API is running",
  });
});

app.use("/api/crops", cropRoutes);
app.use("/api/farmers", farmerRoutes);
app.use("/api/auth", authRoutes);

app.post('/api/ussd', handleUssdCallback);
app.use('/api/messaging', messagingRoutes);
app.post('/api/targeting/match', matchFarmers);

export default app;
