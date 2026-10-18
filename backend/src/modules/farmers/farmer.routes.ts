import { Router } from "express";
import type { RequestHandler } from "express";
import { eq } from "drizzle-orm";
import { farmers } from "../../../../database/schema/farmers";
import { db } from "../../db";
import { hasPermission } from "../../config/permissions";
import { ForbiddenError, UnauthorizedError } from "../../utils/errors";
import { farmerIdSchema } from "./farmer.schema";

import {
  createFarmerHandler,
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

const requireFarmerReadById: RequestHandler = async (req, res, next) => {
  const user = req.user;
  if (!user) return next(new UnauthorizedError());
  if (hasPermission(user.role, "farmer:read")) return next();
  if (user.role !== "FARMER") {
    return next(new ForbiddenError("Missing required permission: farmer:read"));
  }

  const parsed = farmerIdSchema.safeParse(req.params);
  if (!parsed.success) return next();

  try {
    const [farmer] = await db
      .select({ userId: farmers.userId })
      .from(farmers)
      .where(eq(farmers.id, parsed.data.id))
      .limit(1);
    if (farmer && farmer.userId !== user.id) {
      return res.status(404).json({
        error: { code: "NOT_FOUND", message: "Farmer not found", details: [] },
      });
    }
    return next();
  } catch (error) {
    return next(error);
  }
};

const requireFarmerReadByUserId: RequestHandler = (req, _res, next) => {
  const user = req.user;
  if (!user) return next(new UnauthorizedError());
  if (hasPermission(user.role, "farmer:read")) return next();
  if (user.role === "FARMER" && req.params.userId === user.id) return next();
  return next(new ForbiddenError("Missing required permission: farmer:read"));
};

// Protect ALL farmer routes with requireAuth
router.use(requireAuth);

// Farmer profile endpoints
router.post("/", requirePermission("farmer:create"), createFarmerHandler);
router.get("/", requirePermission("farmer:read"), listFarmersHandler);
router.get("/user/:userId", requireFarmerReadByUserId, getFarmerByUserIdHandler);
router.get("/:id", requireFarmerReadById, getFarmerByIdHandler);
router.patch("/:id", requirePermission("farmer:edit"), updateFarmerHandler);

// Farmer-crop relationship endpoints
router.post("/:id/crops", requirePermission("farmer:edit"), addCropToFarmerHandler);
router.get("/:id/crops", requireFarmerReadById, getFarmerCropsHandler);

export { router as farmerRouter };

export default router;