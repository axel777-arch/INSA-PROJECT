import { Router } from "express";
import * as contentController from "./content.controller";

const router = Router();

router.post("/", contentController.createContent);
router.get("/", contentController.listContent);
router.get("/:id", contentController.getContentById);
router.patch("/:id", contentController.updateContent);
router.post("/:id/submit-review", contentController.submitForReview);
router.post("/:id/approve", contentController.approveContent);
router.post("/:id/reject", contentController.rejectContent);
router.post("/:id/publish", contentController.publishContent);

export default router;