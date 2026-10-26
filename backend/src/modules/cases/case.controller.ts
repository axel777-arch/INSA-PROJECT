import type { Request, Response, NextFunction } from "express";
import * as caseService from "./case.service";
import { ValidationError } from "../../utils/errors";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const urgencyLevels = ["LOW", "NORMAL", "HIGH", "URGENT"];
const caseStatuses = ["OPEN", "ASSIGNED", "IN_PROGRESS", "WAITING_FOR_INFORMATION", "ESCALATED", "RESOLVED", "CLOSED"] as const;

function actor(req: Request): caseService.CaseActor {
  if (!req.user) throw new ValidationError("Authentication required");
  return { id: req.user.id, role: req.user.role };
}

function caseId(req: Request): string {
  const raw = req.params.id;
  const id = (Array.isArray(raw) ? raw[0] : raw) ?? req.body?.caseId;
  if (!id || !uuidPattern.test(id)) throw new ValidationError("A valid case ID is required");
  return id;
}

function attachmentValue(value: unknown): string | undefined {
  if (value === undefined || value === null || value === "") return undefined;
  const serialized = typeof value === "string" ? value : JSON.stringify(value);
  if (serialized.length > 7_000_000) throw new ValidationError("Attachments exceed the 5 MB limit");
  try {
    const parsed: unknown = JSON.parse(serialized);
    if (!Array.isArray(parsed) || parsed.length > 5) throw new Error();
    return serialized;
  } catch {
    throw new ValidationError("Attachments must be a JSON array of at most five files");
  }
}

export async function listCasesHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const status = typeof req.query.status === "string" ? req.query.status : undefined;
    res.status(200).json(await caseService.listCases(actor(req), { status }));
  } catch (error) {
    next(error);
  }
}

export async function getCaseByIdHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const foundCase = await caseService.getCaseById(caseId(req), actor(req));
    if (!foundCase) {
      res.status(404).json({ error: { code: "NOT_FOUND", message: "Case not found" } });
      return;
    }
    res.status(200).json(foundCase);
  } catch (error) {
    next(error);
  }
}

export async function createCaseHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const body = req.body ?? {};
    if (typeof body.title !== "string" || !body.title.trim() || typeof body.description !== "string" || !body.description.trim()) {
      throw new ValidationError("Title and description are required");
    }
    if (body.farmerId !== undefined && !uuidPattern.test(body.farmerId)) {
      throw new ValidationError("Farmer ID must be a valid identifier");
    }
    if (body.cropId !== undefined && body.cropId !== null && !uuidPattern.test(body.cropId)) {
      throw new ValidationError("Crop ID must be a valid identifier");
    }
    const priority = body.priority === undefined ? "NORMAL" : String(body.priority).toUpperCase();
    if (!urgencyLevels.includes(priority)) throw new ValidationError("Priority must be LOW, NORMAL, HIGH, or URGENT");
    if (body.observationDate && !/^\d{4}-\d{2}-\d{2}$/.test(body.observationDate)) {
      throw new ValidationError("Observation date must use YYYY-MM-DD");
    }
    const created = await caseService.createCase(actor(req), {
      farmerId: body.farmerId,
      cropId: body.cropId ?? undefined,
      title: body.title.trim(),
      description: body.description.trim(),
      location: typeof body.location === "string" ? body.location.trim() : undefined,
      category: typeof body.category === "string" ? body.category.trim() : undefined,
      priority,
      source: typeof body.source === "string" ? body.source : undefined,
      observationDate: body.observationDate,
      preferredResponseLanguage: typeof body.preferredResponseLanguage === "string"
        ? body.preferredResponseLanguage
        : undefined,
      attachments: attachmentValue(body.attachments),
    });
    res.status(201).json(created);
  } catch (error) {
    next(error);
  }
}

export async function assignCaseHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const assignedTo = req.body?.assignedTo;
    if (typeof assignedTo !== "string" || !uuidPattern.test(assignedTo)) {
      throw new ValidationError("assignedTo must be a valid user ID");
    }
    res.status(200).json(await caseService.assignCase(caseId(req), actor(req), assignedTo));
  } catch (error) {
    next(error);
  }
}

export async function updateCaseStatusHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const status = String(req.body?.status ?? "").toUpperCase();
    if (!caseStatuses.includes(status as typeof caseStatuses[number])) {
      throw new ValidationError("Unsupported case status");
    }
    const summary = typeof req.body?.summary === "string"
      ? req.body.summary.trim()
      : typeof req.body?.details === "string"
        ? req.body.details.trim()
        : undefined;
    if (status === "RESOLVED" && !summary) {
      throw new ValidationError("A resolution summary is required to resolve a case");
    }
    res.status(200).json(await caseService.changeCaseStatus(caseId(req), actor(req), status as typeof caseStatuses[number], summary));
  } catch (error) {
    next(error);
  }
}

export async function escalateCaseHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const reason = typeof req.body?.reason === "string" ? req.body.reason.trim() : undefined;
    res.status(200).json(await caseService.changeCaseStatus(caseId(req), actor(req), "ESCALATED", reason));
  } catch (error) {
    next(error);
  }
}

export async function requestInformationHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const message = typeof req.body?.message === "string" ? req.body.message.trim() : "";
    if (!message) throw new ValidationError("A request message is required");
    const id = caseId(req);
    const current = await caseService.changeCaseStatus(id, actor(req), "WAITING_FOR_INFORMATION", message);
    await caseService.addCaseMessage(id, actor(req), message, "FARMER", undefined, false);
    res.status(200).json(current);
  } catch (error) {
    next(error);
  }
}

export async function addCaseMessageHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const body = typeof req.body?.body === "string" ? req.body.body.trim() : "";
    if (!body) throw new ValidationError("Message body is required");
    const visibility = req.body?.visibility === "FARMER" ? "FARMER" : "INTERNAL";
    const message = await caseService.addCaseMessage(
      caseId(req),
      actor(req),
      body,
      visibility,
      attachmentValue(req.body?.attachments),
    );
    res.status(201).json(message);
  } catch (error) {
    next(error);
  }
}

export async function submitCaseResponseHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const body = req.body ?? {};
    if (typeof body.diagnosis !== "string" || !body.diagnosis.trim()
      || typeof body.recommendation !== "string" || !body.recommendation.trim()) {
      throw new ValidationError("Diagnosis and recommendation are required");
    }
    const result = await caseService.submitCaseResponse(caseId(req), actor(req), {
      diagnosis: body.diagnosis.trim(),
      recommendation: body.recommendation.trim(),
      internalNotes: typeof body.internalNotes === "string" ? body.internalNotes : undefined,
      images: typeof body.images === "string" ? body.images : undefined,
    });
    res.status(201).json({ message: "Case response submitted", data: result });
  } catch (error) {
    next(error);
  }
}
