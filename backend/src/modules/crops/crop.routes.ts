import { Router } from "express";

import {
  getCrops,
  createCropHandler,
} from "./crop.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

// Protect ALL crop routes with requireAuth
router.use(requireAuth);

router.get("/", getCrops);
router.post("/", requirePermission("crop:manage"), createCropHandler);

export default router;