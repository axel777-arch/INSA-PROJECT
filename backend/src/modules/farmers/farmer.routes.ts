
import { Router } from "express";

import {
  createFarmerHandler,
  listFarmersHandler,
  getFarmerByIdHandler,
  getFarmerByUserIdHandler,
  updateFarmerHandler,
  addCropToFarmerHandler,
  getFarmerCropsHandler,
} from "./farmer.controller";

import {
  assignFarmerHandler,
  getFarmerAssignmentsHandler,
} from "./farmer-assignment.controller";

import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

// Protect ALL farmer routes with authentication.
router.use(requireAuth);

// Farmer profile endpoints.
router.post("/", requirePermission("farmer:create"), createFarmerHandler);
router.get("/", requirePermission("farmer:read"), listFarmersHandler);
router.get("/user/:userId", getFarmerByUserIdHandler);

// Farmer-worker assignment endpoints.
router.post(
  "/:farmerId/assignments",
  requirePermission("farmer:assign"),
  assignFarmerHandler,
);

router.get(
  "/:farmerId/assignments",
  requirePermission("farmer:read"),
  getFarmerAssignmentsHandler,
);

// Individual farmer endpoints.
router.get("/:id", getFarmerByIdHandler);
router.patch("/:id", requirePermission("farmer:edit"), updateFarmerHandler);

// Farmer-crop relationship endpoints.
router.post(
  "/:id/crops",
  requirePermission("farmer:edit"),
  addCropToFarmerHandler,
);

router.get("/:id/crops", getFarmerCropsHandler);
export { router as farmerRouter };
export default router;