import { Router } from "express";
import { processSmsQueryHandler, listSmsHistoryHandler } from "./sms.controller";
import { requireAuth } from "../../middleware/auth.middleware";
import { requirePermission } from "../../middleware/role.middleware";

const router = Router();

router.use(requireAuth, requirePermission("simulator:use"));
router.post("/query", processSmsQueryHandler);
router.get("/history", listSmsHistoryHandler);

export default router;
