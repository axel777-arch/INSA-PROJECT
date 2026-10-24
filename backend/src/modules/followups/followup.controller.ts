import { Request, Response } from "express";
import {
  createFollowUp,
  listFollowUps,
  getFollowUpById,
  updateFollowUp,
} from "./followup.service";
import {
  createFollowUpSchema,
  updateFollowUpSchema,
  followUpIdSchema,
} from "./followup.schema";

// ── POST /api/follow-ups ──────────────────────────────────────────────────────
export async function createFollowUpHandler(req: Request, res: Response): Promise<Response> {
  const parsed = createFollowUpSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: { code: "VALIDATION_ERROR", message: "Invalid follow-up data", details: parsed.error.issues },
    });
  }
  try {
    const record = await createFollowUp({
      ...parsed.data,
      workerId: req.user!.id,
    });
    return res.status(201).json({ success: true, data: record });
  } catch (error) {
    console.error("CREATE FOLLOWUP ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to create follow-up", details: [] } });
  }
}

// ── GET /api/follow-ups ───────────────────────────────────────────────────────
export async function listFollowUpsHandler(req: Request, res: Response): Promise<Response> {
  try {
    const records = await listFollowUps({
      requestingUserId: req.user!.id,
      requestingUserRole: req.user!.role,
      farmerId: req.query.farmerId as string | undefined,
      status: req.query.status as string | undefined,
    });
    return res.status(200).json(records);
  } catch (error) {
    console.error("LIST FOLLOWUPS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve follow-ups", details: [] } });
  }
}

// ── GET /api/follow-ups/:id ───────────────────────────────────────────────────
export async function getFollowUpByIdHandler(req: Request, res: Response): Promise<Response> {
  const parsed = followUpIdSchema.safeParse(req.params);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid follow-up ID", details: parsed.error.issues } });
  }
  try {
    const record = await getFollowUpById(parsed.data.id);
    if (!record) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Follow-up record not found", details: [] } });
    }
    return res.status(200).json(record);
  } catch (error) {
    console.error("GET FOLLOWUP ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve follow-up", details: [] } });
  }
}

// ── PATCH /api/follow-ups/:id ─────────────────────────────────────────────────
export async function updateFollowUpHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = followUpIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid follow-up ID", details: idParsed.error.issues } });
  }
  const bodyParsed = updateFollowUpSchema.safeParse(req.body);
  if (!bodyParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid update data", details: bodyParsed.error.issues } });
  }
  try {
    const existing = await getFollowUpById(idParsed.data.id);
    if (!existing) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Follow-up record not found", details: [] } });
    }
    // Only the owning worker or admin can update
    if (req.user!.role === "EXTENSION_WORKER" && existing.worker_id !== req.user!.id) {
      return res.status(403).json({ error: { code: "FORBIDDEN", message: "You can only update your own follow-up records", details: [] } });
    }
    const updated = await updateFollowUp(idParsed.data.id, bodyParsed.data);
    return res.status(200).json({ success: true, data: updated });
  } catch (error) {
    console.error("UPDATE FOLLOWUP ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to update follow-up", details: [] } });
  }
}
