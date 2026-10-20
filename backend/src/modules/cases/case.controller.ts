import { Request, Response } from "express";
import * as caseService from "./case.service";

export async function listCasesHandler(req: Request, res: Response): Promise<Response> {
  try {
    const status = typeof req.query.status === "string" ? req.query.status : undefined;
    const farmerId = typeof req.query.farmerId === "string" ? req.query.farmerId : undefined;
    const casesList = await caseService.listCases({ status, farmerId });
    return res.status(200).json(casesList);
  } catch (error) {
    console.error("LIST CASES ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to list cases" } });
  }
}

export async function getCaseByIdHandler(req: Request, res: Response): Promise<Response> {
  try {
    const rawId = req.params.id;
    const id = Array.isArray(rawId) ? rawId[0] : rawId;
    const foundCase = await caseService.getCaseById(id);
    if (!foundCase) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Case not found" } });
    }
    return res.status(200).json(foundCase);
  } catch (error) {
    console.error("GET CASE ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to get case" } });
  }
}

export async function createCaseHandler(req: Request, res: Response): Promise<Response> {
  try {
    const { farmerId, cropId, title, description, location, images } = req.body ?? {};
    if (!title || !description) {
      return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Title and description are required" } });
    }
    const created = await caseService.createCase({ farmerId, cropId, title, description, location, images });
    return res.status(201).json(created);
  } catch (error) {
    console.error("CREATE CASE ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to create case" } });
  }
}

export async function submitCaseResponseHandler(req: Request, res: Response): Promise<Response> {
  try {
    const rawId = req.params.id ?? req.body.caseId;
    const caseId = Array.isArray(rawId) ? rawId[0] : rawId;
    const user = (req as any).user;
    const expertUserId = user?.userId ?? user?.id ?? "00000000-0000-0000-0000-000000000000";

    const { diagnosis, recommendation, internalNotes, internal_notes, images } = req.body ?? {};

    if (!caseId) {
      return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "Case ID is required" } });
    }

    if (!diagnosis || !recommendation) {
      return res.status(400).json({
        error: { code: "VALIDATION_ERROR", message: "Diagnosis and recommendation are required" },
      });
    }

    const result = await caseService.submitCaseResponse(caseId, expertUserId, {
      diagnosis,
      recommendation,
      internalNotes: internalNotes ?? internal_notes,
      images: Array.isArray(images) ? images.join(",") : images,
    });

    return res.status(201).json({
      message: "Case response submitted and case status updated to RESOLVED",
      data: result,
    });
  } catch (error) {
    console.error("SUBMIT CASE RESPONSE ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to submit case response" } });
  }
}
