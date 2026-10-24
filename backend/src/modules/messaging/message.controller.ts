import type { NextFunction, Request, Response } from "express";
import { eq } from "drizzle-orm";
import { db } from "../../db/index";
import { content } from "../../../../database/schema/content";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";
import { NotFoundError, ValidationError } from "../../utils/errors";
import { targetingService } from "../../services/targeting/targeting.service";
import { messageService } from "./message.service";

export async function createSmsMessage(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw new ValidationError("Authentication required");
    const contentId = req.body?.contentId;
    if (typeof contentId !== "string" || !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(contentId)) {
      throw new ValidationError("A valid contentId is required");
    }

    const [advisory] = await db.select().from(content).where(eq(content.id, contentId)).limit(1);
    if (!advisory || advisory.status !== "PUBLISHED") {
      throw new NotFoundError("Published advisory");
    }

    const eligibleFarmers = await targetingService.findTargetFarmersForContent({
      cropId: advisory.cropId,
      region: advisory.targetRegion,
      zone: advisory.targetZone,
      woreda: advisory.targetWoreda,
      kebele: advisory.targetKebele,
      language: advisory.targetLanguage,
    });
    const recipientPhone = typeof req.body?.recipient === "string" ? req.body.recipient.trim() : "";
    const eligible = recipientPhone
      ? eligibleFarmers.filter((farmer) => farmer.phone === recipientPhone)
      : eligibleFarmers;
    if (eligible.length === 0) {
      res.status(200).json({
        status: "NO_ELIGIBLE_RECIPIENTS",
        message: "No eligible recipients matched the published advisory targeting rules.",
        recipients: [],
      });
      return;
    }

    const result = await messageService.dispatchBroadcast({
      title: advisory.title,
      body: `${advisory.title}: ${advisory.body}`,
      channel: "SMS",
      createdBy: req.user.id,
      contentId: advisory.id,
      farmerIds: eligible.map((farmer) => farmer.id),
    });
    res.status(201).json({
      message: result.message,
      recipients: result.recipients,
      status: "SIMULATED",
      deliveryNotice: "This is a simulator outcome, not telecom-provider delivery confirmation.",
    });
  } catch (error) {
    next(error);
  }
}
