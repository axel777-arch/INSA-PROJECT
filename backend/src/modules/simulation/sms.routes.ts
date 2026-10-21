import { Router } from "express";
import { processSmsQueryHandler, listSmsHistoryHandler } from "./sms.controller";

const router = Router();

router.post("/query", processSmsQueryHandler);
router.get("/history", listSmsHistoryHandler);

export default router;
