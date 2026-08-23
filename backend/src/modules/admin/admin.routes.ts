import { Router } from "express";
import { requireAuth } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";
import * as controller from "./admin.controller";

const router = Router();
router.use(requireAuth, requireRole("ADMIN"));
router.get("/overview", controller.overview);
router.get("/users", controller.users);
router.post("/users/:id/approve", controller.approve);
router.post("/users/:id/reject", controller.reject);
router.patch("/users/:id/status", controller.setActive);
router.delete("/users/:id", controller.deleteUser);
router.get("/audit-logs", controller.auditLogs);
router.get("/settings", controller.settings);
router.patch("/settings", controller.updateSettings);

export default router;
