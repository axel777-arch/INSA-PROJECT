import { Request, Response } from "express";
import path from "path";
import fs from "fs";

import {
  createObservation,
  listObservations,
  getObservationById,
  updateObservation,
  escalateObservation,
  addObservationAttachment,
  InvalidExpertError,
  NoAvailableExpertError,
} from "./observation.service";

import {
  createObservationSchema,
  updateObservationSchema,
  escalateObservationSchema,
  observationIdSchema,
} from "./observation.schema";

// ── POST /api/observations ────────────────────────────────────────────────────
export async function createObservationHandler(req: Request, res: Response): Promise<Response> {
  const parsed = createObservationSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: { code: "VALIDATION_ERROR", message: "Invalid observation data", details: parsed.error.issues },
    });
  }
  try {
    const obs = await createObservation({
      ...parsed.data,
      workerId: req.user!.id,
    });
    return res.status(201).json({ success: true, data: obs });
  } catch (error) {
    console.error("CREATE OBSERVATION ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to create observation", details: [] } });
  }
}

// ── GET /api/observations ─────────────────────────────────────────────────────
export async function listObservationsHandler(req: Request, res: Response): Promise<Response> {
  try {
    const observations = await listObservations({
      requestingUserId: req.user!.id,
      requestingUserRole: req.user!.role,
      farmerId: req.query.farmerId as string | undefined,
    });
    return res.status(200).json(observations);
  } catch (error) {
    console.error("LIST OBSERVATIONS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve observations", details: [] } });
  }
}

// ── GET /api/observations/:id ─────────────────────────────────────────────────
export async function getObservationByIdHandler(req: Request, res: Response): Promise<Response> {
  const parsed = observationIdSchema.safeParse(req.params);
  if (!parsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid observation ID", details: parsed.error.issues } });
  }
  try {
    const obs = await getObservationById(parsed.data.id);
    if (!obs) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Observation not found", details: [] } });
    }
    return res.status(200).json(obs);
  } catch (error) {
    console.error("GET OBSERVATION ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve observation", details: [] } });
  }
}

// ── PATCH /api/observations/:id ───────────────────────────────────────────────
export async function updateObservationHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = observationIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid observation ID", details: idParsed.error.issues } });
  }
  const bodyParsed = updateObservationSchema.safeParse(req.body);
  if (!bodyParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid update data", details: bodyParsed.error.issues } });
  }
  try {
    const obs = await getObservationById(idParsed.data.id);
    if (!obs) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Observation not found", details: [] } });
    }
    // Only the creating worker or admin can edit
    if (req.user!.role === "EXTENSION_WORKER" && obs.worker_id !== req.user!.id) {
      return res.status(403).json({ error: { code: "FORBIDDEN", message: "You can only edit your own observations", details: [] } });
    }
    const updated = await updateObservation(idParsed.data.id, bodyParsed.data);
    return res.status(200).json({ success: true, data: updated });
  } catch (error) {
    console.error("UPDATE OBSERVATION ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to update observation", details: [] } });
  }
}

// ── POST /api/observations/:id/escalate ───────────────────────────────────────
export async function escalateObservationHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = observationIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid observation ID", details: idParsed.error.issues } });
  }
  const bodyParsed = escalateObservationSchema.safeParse(req.body ?? {});
  if (!bodyParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid expert identifier", details: bodyParsed.error.issues } });
  }
  try {
    const obs = await getObservationById(idParsed.data.id);
    if (!obs) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Observation not found", details: [] } });
    }
    if (obs.is_escalated) {
      return res.status(409).json({ error: { code: "ALREADY_ESCALATED", message: "Observation is already escalated", details: [] } });
    }
    const updated = await escalateObservation(idParsed.data.id, bodyParsed.data.escalatedToId);
    return res.status(200).json({ success: true, data: updated });
  } catch (error) {
    if (error instanceof InvalidExpertError) {
      return res.status(400).json({ error: { code: "INVALID_EXPERT", message: error.message, details: [] } });
    }
    if (error instanceof NoAvailableExpertError) {
      return res.status(409).json({ error: { code: "NO_AVAILABLE_EXPERT", message: error.message, details: [] } });
    }
    console.error("ESCALATE OBSERVATION ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to escalate observation", details: [] } });
  }
}

// ── POST /api/observations/:id/attachments (base64 inline) ────────────────────
export async function addAttachmentHandler(req: Request, res: Response): Promise<Response> {
  const idParsed = observationIdSchema.safeParse(req.params);
  if (!idParsed.success) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Invalid observation ID", details: idParsed.error.issues } });
  }

  const { fileUrl, fileType, fileName } = req.body;
  if (!fileUrl || !fileType) {
    return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "fileUrl and fileType are required", details: [] } });
  }

  try {
    const obs = await getObservationById(idParsed.data.id);
    if (!obs) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Observation not found", details: [] } });
    }
    const attachment = await addObservationAttachment({
      observationId: idParsed.data.id,
      fileUrl,
      fileType,
      fileName,
    });
    return res.status(201).json({ success: true, data: attachment });
  } catch (error) {
    console.error("ADD ATTACHMENT ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to add attachment", details: [] } });
  }
}
