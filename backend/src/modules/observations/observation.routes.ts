import { Router } from "express";
import {
  createObservationHandler,
  listObservationsHandler,
  getObservationByIdHandler,
  updateObservationHandler,
  escalateObservationHandler,
  addAttachmentHandler,
} from "./observation.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

router.use(requireAuth);

router.post("/", requirePermission("observation:create"), createObservationHandler);
router.get("/", requirePermission("observation:read"), listObservationsHandler);
router.get("/:id", requirePermission("observation:read"), getObservationByIdHandler);
router.patch("/:id", requirePermission("observation:edit"), updateObservationHandler);
router.post("/:id/escalate", requirePermission("observation:escalate"), escalateObservationHandler);
router.post("/:id/attachments", requirePermission("observation:create"), addAttachmentHandler);

export default router;
