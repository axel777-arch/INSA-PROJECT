import type { NextFunction, Request, Response } from "express";
import * as adminService from "./admin.service";

function actor(req: Request) {
  if (!req.user) throw new Error("Authenticated user is missing from request.");
  return req.user;
}

export async function overview(
  _req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    res.json(await adminService.getOverview());
  } catch (error) {
    next(error);
  }
}

export async function users(req: Request, res: Response, next: NextFunction) {
  try {
    const { search, role, status } = req.query;
    res.json(
      await adminService.listUsers({
        search: String(search ?? ""),
        role: String(role ?? "ALL"),
        status: String(status ?? "ALL"),
      }),
    );
  } catch (error) {
    next(error);
  }
}

export async function approve(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await adminService.changeUserStatus(
      actor(req),
      String(req.params.id),
      "APPROVED",
    );
    result
      ? res.json(result)
      : res.status(404).json({ error: { message: "User not found" } });
  } catch (error) {
    next(error);
  }
}

export async function reject(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await adminService.changeUserStatus(
      actor(req),
      String(req.params.id),
      "REJECTED",
    );
    result
      ? res.json(result)
      : res.status(404).json({ error: { message: "User not found" } });
  } catch (error) {
    next(error);
  }
}

export async function setActive(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    const result = await adminService.setUserActive(
      actor(req),
      String(req.params.id),
      req.body.active === true,
    );
    result
      ? res.json(result)
      : res.status(404).json({ error: { message: "User not found" } });
  } catch (error) {
    next(error);
  }
}

export async function deleteUser(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await adminService.deleteUser(actor(req), String(req.params.id));
    result ? res.json(result) : res.status(404).json({ error: { message: "User not found" } });
  } catch (error) {
    next(error);
  }
}

export async function auditLogs(
  _req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    res.json(await adminService.listAuditLogs());
  } catch (error) {
    next(error);
  }
}

export async function settings(
  _req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    res.json(await adminService.getSettings());
  } catch (error) {
    next(error);
  }
}

export async function updateSettings(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    res.json(await adminService.updateSettings(req.body));
  } catch (error) {
    next(error);
  }
}
