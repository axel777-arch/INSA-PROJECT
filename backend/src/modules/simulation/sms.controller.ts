import { Request, Response } from "express";
import * as smsService from "./sms.service";

export async function processSmsQueryHandler(req: Request, res: Response): Promise<Response> {
  try {
    const { senderPhone, phone, farmerId, messageText, message } = req.body ?? {};
    const text = messageText ?? message;

    if (!text || typeof text !== "string" || !text.trim()) {
      return res.status(400).json({ error: { code: "VALIDATION_ERROR", message: "messageText is required" } });
    }

    const result = await smsService.processTwoWaySmsQuery({
      senderPhone: senderPhone ?? phone,
      farmerId,
      messageText: text,
    });

    return res.status(200).json(result);
  } catch (error) {
    console.error("PROCESS SMS QUERY ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to process SMS query" } });
  }
}

export async function listSmsHistoryHandler(req: Request, res: Response): Promise<Response> {
  try {
    const limit = Number(req.query.limit) || 30;
    const history = await smsService.listSmsHistory(limit);
    return res.status(200).json({ history });
  } catch (error) {
    console.error("LIST SMS HISTORY ERROR:", error);
    return res.status(500).json({ error: { code: "INTERNAL_SERVER_ERROR", message: "Failed to fetch SMS history" } });
  }
}
