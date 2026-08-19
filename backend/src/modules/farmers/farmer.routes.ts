import { Router } from "express";
import {
  createFarmerHandler,
  listFarmersHandler,
  getFarmerByIdHandler,
  updateFarmerHandler,
  addCropToFarmerHandler,
  getFarmerCropsHandler,
} from "./farmer.controller";

const router = Router();

// Farmer profile endpoints
router.post("/", createFarmerHandler);
router.get("/", listFarmersHandler);
router.get("/:id", getFarmerByIdHandler);
router.put("/:id", updateFarmerHandler);

// Farmer crop relationship endpoints
router.post("/:id/crops", addCropToFarmerHandler);
router.get("/:id/crops", getFarmerCropsHandler);

export { router as farmerRouter };
export default router;