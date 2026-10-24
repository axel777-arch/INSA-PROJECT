import { Router } from "express";
import * as contentController from "./content.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";
import { submitCaseResponseHandler } from "../cases/case.controller";

const router = Router();

router.post(
  "/",
  requireAuth,
  requirePermission("content:create"),
  contentController.createContent
);

router.get(
  "/",
  requireAuth,
  requirePermission("content:read"),
  contentController.listContent
);

router.get(
  "/:id",
  requireAuth,
  requirePermission("content:read"),
  contentController.getContentById
);

router.patch(
  "/:id",
  requireAuth,
  requirePermission("content:edit"),
  contentController.updateContent
);

router.post(
  "/:id/submit-review",
  requireAuth,
  requirePermission("content:submit-review"),
  contentController.submitForReview
);

router.post(
  "/:id/submit",
  requireAuth,
  requirePermission("content:submit-review"),
  contentController.submitForReview
);

router.post(
  "/:id/approve",
  requireAuth,
  requirePermission("content:approve"),
  contentController.approveContent
);

router.post(
  "/:id/reject",
  requireAuth,
  requirePermission("content:reject"),
  contentController.rejectContent
);

router.post(
  "/:id/publish",
  requireAuth,
  requirePermission("content:publish"),
  contentController.publishContent
);

// Support POST /api/content/responses alongside /api/cases/:id/responses
router.post(
  "/responses",
  requireAuth,
  requirePermission("case:manage"),
  submitCaseResponseHandler
);

export default router;
