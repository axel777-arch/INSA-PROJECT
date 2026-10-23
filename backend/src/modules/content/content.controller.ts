import type { Request, Response, NextFunction } from "express";
import * as contentService from "./content.service";
import {
  createContentBodySchema,
  updateContentBodySchema,
  idParamSchema,
  versionIdParamSchema,
  listContentQuerySchema,
  rejectContentBodySchema,
  requestRevisionBodySchema,
  approveContentBodySchema,
  archiveContentBodySchema,
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
      authorId: getAuthenticatedUserId(req),
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
    const userId = getAuthenticatedUserId(req);
    const userRole = req.user?.role;

    const updated = await contentService.updateContent(id, input, userId, userRole);
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
    const userId = getAuthenticatedUserId(req);
    const userRole = req.user?.role;

    const updated = await contentService.submitForReview(
      {
        contentId: id,
        submittedBy: userId,
      },
      userRole
    );

    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function requestRevision(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const { comment } = requestRevisionBodySchema.parse(req.body);

    const updated = await contentService.requestRevision({
      contentId: id,
      reviewerId: getAuthenticatedUserId(req),
      comment,
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
    const body = approveContentBodySchema.parse(req.body);

    const updated = await contentService.approveContent({
      contentId: id,
      approvedBy: getAuthenticatedUserId(req),
      comment: body.comment,
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

    const result = await contentService.publishContent({
      contentId: id,
      publishedBy: getAuthenticatedUserId(req),
    });

    // Return published content with event metadata for Member 4 integration
    res.status(200).json({
      ...result.content,
      _event: result.event,
    });
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
    const { reason } = archiveContentBodySchema.parse(req.body);

    const updated = await contentService.archiveContent({
      contentId: id,
      archivedBy: getAuthenticatedUserId(req),
      reason,
    });

    res.status(200).json(updated);
  } catch (err) {
    next(err);
  }
}

export async function getContentVersions(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const versions = await contentService.getContentVersions(id);
    res.status(200).json(versions);
  } catch (err) {
    next(err);
  }
}

export async function getContentVersionById(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id, versionId } = versionIdParamSchema.parse(req.params);
    const version = await contentService.getContentVersionById(id, versionId);
    res.status(200).json(version);
  } catch (err) {
    next(err);
  }
}

export async function getContentReviews(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const { id } = idParamSchema.parse(req.params);
    const reviews = await contentService.getContentReviews(id);
    res.status(200).json(reviews);
  } catch (err) {
    next(err);
  }
}