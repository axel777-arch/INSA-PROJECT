import { Router } from "express";

import {
  createFarmerHandler,
  createManagedFarmerHandler,
  updateManagedFarmerHandler,
  deleteManagedFarmerHandler,
  listFarmersHandler,
  getFarmerByIdHandler,
  getFarmerByUserIdHandler,
  updateFarmerHandler,
  addCropToFarmerHandler,
  getFarmerCropsHandler,
} from "./farmer.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

// Farmer profile endpoints
router.post("/", createFarmerHandler);
router.post(
  "/managed",
  requireAuth,
  requirePermission("farmer:create"),
  createManagedFarmerHandler,
);
router.patch(
  "/:id/managed",
  requireAuth,
  requirePermission("farmer:edit"),
  updateManagedFarmerHandler,
);
router.delete(
  "/:id/managed",
  requireAuth,
  requirePermission("farmer:edit"),
  deleteManagedFarmerHandler,
);
router.get("/", listFarmersHandler);
router.get("/user/:userId", getFarmerByUserIdHandler);
router.get("/:id", getFarmerByIdHandler);
router.patch("/:id", updateFarmerHandler);

// Farmer-crop relationship endpoints
router.post("/:id/crops", addCropToFarmerHandler);
router.get("/:id/crops", getFarmerCropsHandler);

export { router as farmerRouter };

export default router;
