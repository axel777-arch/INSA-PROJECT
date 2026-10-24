import { Request, Response } from "express";
import { eq } from "drizzle-orm";
import { db } from "../../db/index";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import * as smsService from "./sms.service";

export async function processSmsQueryHandler(req: Request, res: Response): Promise<Response> {
  try {
    if (!req.user) {
      return res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Authentication required" } });
    }
    const { senderPhone, phone, messageText, message, text: requestText } = req.body ?? {};
    const text = messageText ?? message ?? requestText;

    if (!text || typeof text !== "string" || !text.trim()) {
      return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "messageText is required" } });
    }
    let phoneValue: string = typeof (senderPhone ?? phone) === "string" ? senderPhone ?? phone : "";
    let farmerId: string | undefined;
    if (req.user.role === "FARMER") {
      const [profile] = await db
        .select({ id: farmers.id, phone: users.phone })
        .from(farmers)
        .innerJoin(users, eq(users.id, farmers.userId))
        .where(eq(farmers.userId, req.user.id))
        .limit(1);
      if (!profile) {
        return res.status(403).json({ error: { code: "FORBIDDEN", message: "Farmer profile not found" } });
      }
      farmerId = profile.id;
      phoneValue = profile.phone ?? "";
    }
    if (!/^\+?[0-9]{7,15}$/.test(phoneValue)) {
      return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "A valid senderPhone is required" } });
    }

    const result = await smsService.processTwoWaySmsQuery({
      senderPhone: phoneValue,
      farmerId,
      messageText: text,
      createdBy: req.user.id,
    });

    return res.status(200).json({
      ...result,
      status: "SIMULATED",
      outbound: {
        id: result.outboundMessageId,
        body: result.reply,
        createdAt: result.timestamp,
      },
      deliveryNotice: "Simulated response only; no telecom provider delivery is performed.",
    });
  } catch (error) {
    console.error("PROCESS SMS QUERY ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to process SMS query" } });
  }
}

export async function listSmsHistoryHandler(req: Request, res: Response): Promise<Response> {
  try {
    if (!req.user) {
      return res.status(401).json({ error: { code: "UNAUTHENTICATED", message: "Authentication required" } });
    }
    const limit = Number(req.query.limit) || 30;
    const history = await smsService.listSmsHistory(limit, req.user.id);
    return res.status(200).json({
      history,
      messages: history.map((item) => ({
        id: item.id,
        direction: item.isUser ? "INBOUND" : "OUTBOUND",
        body: item.text,
        createdAt: item.timestamp,
      })),
    });
  } catch (error) {
    console.error("LIST SMS HISTORY ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to fetch SMS history" } });
  }
}
