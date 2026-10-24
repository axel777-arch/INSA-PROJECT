import { Router } from "express";
import {
  addCaseMessageHandler,
  assignCaseHandler,
  createCaseHandler,
  escalateCaseHandler,
  getCaseByIdHandler,
  listCasesHandler,
  requestInformationHandler,
  submitCaseResponseHandler,
  updateCaseStatusHandler,
} from "./case.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

router.use(requireAuth);

router.get("/", requirePermission("case:read"), listCasesHandler);
router.post("/", requirePermission("case:create"), createCaseHandler);
router.get("/:id", requirePermission("case:read"), getCaseByIdHandler);
router.post("/:id/responses", requirePermission("case:manage"), submitCaseResponseHandler);
router.post("/responses", requirePermission("case:manage"), submitCaseResponseHandler);
router.patch("/:id/assignment", requirePermission("case:manage"), assignCaseHandler);
router.post("/:id/escalate", requirePermission("case:manage"), escalateCaseHandler);
router.post("/:id/request-information", requirePermission("case:manage"), requestInformationHandler);
router.patch("/:id/status", requirePermission("case:manage"), updateCaseStatusHandler);
router.post("/:id/messages", requirePermission("case:message"), addCaseMessageHandler);

export default router;
