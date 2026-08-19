import { Router } from "express";
import { getCrops } from "./crop.controller";

const router = Router();

router.get("/", getCrops);

export default router;
