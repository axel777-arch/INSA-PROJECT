import type { Request, Response, NextFunction } from "express";
import * as contentService from "./content.service";
import {
  createContentBodySchema,
  updateContentBodySchema,
  idParamSchema,
  listContentQuerySchema,
  rejectContentBodySchema,
 } from "./content.schema";

function getAuthenticatedUserId(req: Request): string {
  if (!req.user) {
    throw new Error("Authenticated user is missing from request.");
  }

  return req.user.id;
}
export async function createContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const body = createContentBodySchema.parse(req.body);

const created = await contentService.createContent({
  ...body,
  createdBy: getAuthenticatedUserId(req),
});
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

    const updated = await contentService.submitForReview({
      contentId: id,
      submittedBy: getAuthenticatedUserId(req),
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

    const updated = await contentService.approveContent({
      contentId: id,
      approvedBy: getAuthenticatedUserId(req),
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
    const { comment } = rejectContentBodySchema.parse(req.body);

    const updated = await contentService.rejectContent({
      contentId: id,
      rejectedBy: getAuthenticatedUserId(req),
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

    const updated = await contentService.publishContent({
      contentId: id,
      publishedBy: getAuthenticatedUserId(req),
    });

    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function archiveContent(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);

    const updated = await contentService.archiveContent({
      contentId: id,
      archivedBy: getAuthenticatedUserId(req),
    });

    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}