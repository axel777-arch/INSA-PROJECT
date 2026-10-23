import { Router } from "express";

import {
  createFarmerHandler,
  listFarmersHandler,
  getFarmerByIdHandler,
  getFarmerByUserIdHandler,
  updateFarmerHandler,
  addCropToFarmerHandler,
  getFarmerCropsHandler,
  assignFarmerHandler,
  getFarmerAssignmentsHandler,
} from "./farmer.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

// Protect ALL farmer routes with requireAuth
router.use(requireAuth);

// Farmer profile endpoints
router.post("/", requirePermission("farmer:create"), createFarmerHandler);
router.get("/", requirePermission("farmer:read"), listFarmersHandler);
router.get("/user/:userId", getFarmerByUserIdHandler);
router.get("/:id", getFarmerByIdHandler);
router.patch("/:id", requirePermission("farmer:edit"), updateFarmerHandler);

// Assignment endpoints
router.post("/:id/assign", requirePermission("farmer:assign"), assignFarmerHandler);
router.get("/:id/assignments", requirePermission("farmer:read"), getFarmerAssignmentsHandler);

// Farmer-crop relationship endpoints
router.post("/:id/crops", requirePermission("farmer:edit"), addCropToFarmerHandler);
router.get("/:id/crops", getFarmerCropsHandler);

export { router as farmerRouter };

export default router;
