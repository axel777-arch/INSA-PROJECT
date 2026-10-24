import type { Request, Response, NextFunction } from "express";

import {
  assignFarmerToWorker,
  getFarmerAssignments,
  canAccessFarmer,
} from "./farmer-assignment.service";

export async function assignFarmerHandler(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    const farmerId = req.params.farmerId;
    const { workerId, note, assignmentType, reason } = req.body;

    if (typeof farmerId !== "string" || farmerId.trim() === "") {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "A valid farmer ID is required",
        },
      });
    }

    if (typeof workerId !== "string" || workerId.trim() === "") {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "A valid worker ID is required",
        },
      });
    }

    if (note !== undefined && typeof note !== "string") {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "Note must be text",
        },
      });
    }

    const validAssignmentTypes = [
      "PRIMARY",
      "TEMPORARY_COVERAGE",
      "COLLABORATOR",
    ];

    if (
      assignmentType !== undefined &&
      !validAssignmentTypes.includes(assignmentType)
    ) {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "Invalid assignment type",
        },
      });
    }

    if (reason !== undefined && typeof reason !== "string") {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "Reason must be text",
        },
      });
    }

    if (!req.user?.id) {
      return res.status(401).json({
        error: {
          code: "UNAUTHENTICATED",
          message: "Authentication required",
        },
      });
    }

    // The route's requirePermission("farmer:edit") middleware
    // checks whether the user has permission to perform this action.

    const assignment = await assignFarmerToWorker(
      farmerId,
      workerId,
      req.user.id,
      note,
      assignmentType ?? "PRIMARY",
      reason,
    );

    return res.status(201).json({ data: assignment });
  } catch (error) {
    const message = error instanceof Error ? error.message : "";

    if (
      message === "Farmer not found" ||
      message === "Extension worker not found"
    ) {
      return res.status(404).json({
        error: { code: "NOT_FOUND", message },
      });
    }

    if (
      message === "The selected user is not an extension worker" ||
      message === "The extension worker is inactive" ||
      message === "The assigning user does not exist or is inactive"
    ) {
      return res.status(400).json({
        error: { code: "INVALID_ASSIGNMENT", message },
      });
    }

    return next(error);
  }
}

export async function getFarmerAssignmentsHandler(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    const farmerId = req.params.farmerId;

    if (typeof farmerId !== "string" || farmerId.trim() === "") {
      return res.status(400).json({
        error: {
          code: "VALIDATION_ERROR",
          message: "A valid farmer ID is required",
        },
      });
    }

    if (!req.user?.id) {
      return res.status(401).json({
        error: {
          code: "UNAUTHENTICATED",
          message: "Authentication required",
        },
      });
    }

    const allowed = await canAccessFarmer(
      farmerId,
      req.user.id,
      req.user.role,
    );

    if (!allowed) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "You are not allowed to access this farmer's assignments",
        },
      });
    }

    const assignments = await getFarmerAssignments(farmerId);

    return res.status(200).json({ data: assignments });
  } catch (error) {
    return next(error);
  }
}