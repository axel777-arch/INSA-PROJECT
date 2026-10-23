import { Router } from "express";
import * as contentController from "./content.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

// ── Advisory CRUD & Discovery ────────────────────────────────────────────────
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

// ── Submission Workflow ──────────────────────────────────────────────────────
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

// ── Expert Review Actions ────────────────────────────────────────────────────
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
  "/:id/request-revision",
  requireAuth,
  requirePermission("content:approve"),
  contentController.requestRevision
);

// ── Publication & Archival ───────────────────────────────────────────────────
router.post(
  "/:id/publish",
  requireAuth,
  requirePermission("content:publish"),
  contentController.publishContent
);

router.post(
  "/:id/archive",
  requireAuth,
  requirePermission("content:archive"),
  contentController.archiveContent
);

// ── Version History & Audit Trail ────────────────────────────────────────────
router.get(
  "/:id/versions",
  requireAuth,
  requirePermission("content:read"),
  contentController.getContentVersions
);

router.get(
  "/:id/versions/:versionId",
  requireAuth,
  requirePermission("content:read"),
  contentController.getContentVersionById
);

router.get(
  "/:id/reviews",
  requireAuth,
  requirePermission("content:read"),
  contentController.getContentReviews
);

export default router;