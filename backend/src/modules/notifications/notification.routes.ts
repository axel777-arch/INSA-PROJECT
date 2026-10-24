import { Router } from "express";
import { listNotificationsHandler, markAsReadHandler } from "./notification.controller";
import { requireAuth } from "../../middleware/auth.middleware";

const router = Router();

router.use(requireAuth);

router.get("/", listNotificationsHandler);
router.patch("/:id/read", markAsReadHandler);

export default router;
