import { Router } from "express";

import {
  getCrops,
  createCropHandler,
} from "./crop.controller";

const router = Router();

router.get("/", getCrops);
router.post("/", createCropHandler);

export default router;