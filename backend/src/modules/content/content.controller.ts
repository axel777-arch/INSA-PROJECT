import type { Request, Response, NextFunction } from "express";
import * as contentService from "./content.service";
import {
  createContentBodySchema,
  updateContentBodySchema,
  idParamSchema,
  listContentQuerySchema,
  submitForReviewBodySchema,
  approveContentBodySchema,
  rejectContentBodySchema,
  publishContentBodySchema,
} from "./content.schema";

export async function createContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const input = createContentBodySchema.parse(req.body);
    const created = await contentService.createContent(input);
    res.status(201).json(created);
  } catch (err) {
    next(err);
  }
}

export async function listContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = listContentQuerySchema.parse(req.query);
    const items = await contentService.listContent(filter);
    res.status(200).json(items);
  } catch (err) {
    next(err);
  }
}

export async function getContentById(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const item = await contentService.getContentById(id);
    res.status(200).json(item);
  } catch (err) {
    next(err);
  }
}

export async function updateContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const input = updateContentBodySchema.parse(req.body);
    const updated = await contentService.updateContent(id, input);
    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function submitForReview(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const { submittedBy } = submitForReviewBodySchema.parse(req.body);
    const updated = await contentService.submitForReview({
      contentId: id,
      submittedBy,
    });
    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function approveContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const { approvedBy } = approveContentBodySchema.parse(req.body);
    const updated = await contentService.approveContent({
      contentId: id,
      approvedBy,
    });
    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function rejectContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const { rejectedBy, comment } = rejectContentBodySchema.parse(req.body);
    const updated = await contentService.rejectContent({
      contentId: id,
      rejectedBy,
      comment,
    });
    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function publishContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const { publishedBy } = publishContentBodySchema.parse(req.body);
    const updated = await contentService.publishContent({
      contentId: id,
      publishedBy,
    });
    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}