import { Request, Response } from "express";
import * as notificationService from "./notification.service";

export async function listNotificationsHandler(req: Request, res: Response): Promise<Response> {
  try {
    if (!req.user) {
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Authentication required" } });
    }
    const notifs = await notificationService.getNotificationsForUser(req.user.id);
    return res.status(200).json({
      notifications: notifs,
      unreadCount: notifs.filter((n) => !n.read).length,
    });
  } catch (error) {
    console.error("LIST NOTIFICATIONS ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to retrieve notifications" } });
  }
}

export async function markAsReadHandler(req: Request, res: Response): Promise<Response> {
  try {
    const rawId = req.params.id;
    const id = Array.isArray(rawId) ? rawId[0] : rawId;
    if (!req.user) {
      return res.status(401).json({ error: { code: "UNAUTHORIZED", message: "Authentication required" } });
    }
    const updated = await notificationService.markNotificationAsRead(id, req.user.id);
    if (!updated) {
      return res.status(404).json({ error: { code: "NOT_FOUND", message: "Notification not found" } });
    }
    return res.status(200).json({ success: true, id });
  } catch (error) {
    console.error("MARK NOTIFICATION READ ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to mark notification as read" } });
  }
}
