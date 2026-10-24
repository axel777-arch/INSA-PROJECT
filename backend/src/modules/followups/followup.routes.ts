import { Router } from "express";
import {
  createFollowUpHandler,
  listFollowUpsHandler,
  getFollowUpByIdHandler,
  updateFollowUpHandler,
} from "./followup.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

router.use(requireAuth);

router.post("/", requirePermission("followup:create"), createFollowUpHandler);
router.get("/", requirePermission("followup:read"), listFollowUpsHandler);
router.get("/:id", requirePermission("followup:read"), getFollowUpByIdHandler);
router.patch("/:id", requirePermission("followup:edit"), updateFollowUpHandler);

export default router;
