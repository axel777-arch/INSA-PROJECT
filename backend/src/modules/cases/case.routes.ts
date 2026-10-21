import { Router } from "express";
import {
  listCasesHandler,
  getCaseByIdHandler,
  createCaseHandler,
  submitCaseResponseHandler,
} from "./case.controller";
import { requireAuth } from "../../middleware/auth.middleware";

const router = Router();

router.use(requireAuth);

router.get("/", listCasesHandler);
router.post("/", createCaseHandler);
router.get("/:id", getCaseByIdHandler);
router.post("/:id/responses", submitCaseResponseHandler);
router.post("/responses", submitCaseResponseHandler);

export default router;
