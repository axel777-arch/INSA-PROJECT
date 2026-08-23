import express from "express";

import cropRoutes from "./modules/crops/crop.routes";
import farmerRoutes from "./modules/farmers/farmer.routes";
import authRoutes from "./modules/auth/auth.routes";
import messagingRoutes from "./modules/messaging/messaging.routes";
import { matchFarmers } from "./services/targeting/targeting.controller";
import { handleUssdCallback } from "./services/ussd/ussd.controller";
import adminRoutes from "./modules/admin/admin.routes";
import contentRoutes from "./modules/content/content.routes";
import fieldRoutes from "./modules/field/field.routes";

const app = express();

const allowedOrigins = (process.env.CORS_ORIGINS ?? "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use((req, res, next) => {
  const origin = req.headers.origin;
  const isLocalFlutterWebOrigin = origin
    ? /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)
    : false;
  if (origin && (allowedOrigins.includes(origin) || isLocalFlutterWebOrigin || process.env.NODE_ENV === "development")) {
    res.header("Access-Control-Allow-Origin", origin);
    res.header("Vary", "Origin");
  }
  res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
  res.header("Access-Control-Allow-Methods", "GET, POST, PATCH, DELETE, OPTIONS");
  if (req.method === "OPTIONS") return res.sendStatus(204);
  next();
});

// Field photos are sent as compressed Base64 strings in the observation payload.
app.use(express.json({ limit: "15mb" }));

app.get("/", (_req, res) => {
  res.json({
    message: "Agri-Insight Beacon API is running",
  });
});

app.use("/api/crops", cropRoutes);
app.use("/api/farmers", farmerRoutes);
app.use("/api/auth", authRoutes);

app.post("/api/ussd", handleUssdCallback);
app.use("/api/messaging", messagingRoutes);
app.post("/api/targeting/match", matchFarmers);
app.use("/api/admin", adminRoutes);
app.use("/api/content", contentRoutes);
app.use("/api/field", fieldRoutes);

export default app;
