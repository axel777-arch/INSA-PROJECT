import { Router } from "express";
import { and, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { requireAuth } from "../../middleware/auth.middleware";
import { cropRecords } from "../../../../database/schema/cropRecords";
import { fieldObservations } from "../../../../database/schema/fieldObservations";

const router = Router();
const userId = (req: any) => req.user.id as string;

router.post("/crop-records", requireAuth, async (req, res) => {
  const { crop, plantingDate, areaHectares, growthStage, idempotencyKey } = req.body ?? {};
  if (!crop || !plantingDate || !growthStage || !Number.isFinite(Number(areaHectares)) || Number(areaHectares) <= 0 || !idempotencyKey) {
    return res.status(400).json({ error: { message: "Invalid crop record data" } });
  }
  const [existing] = await db.select().from(cropRecords).where(and(eq(cropRecords.createdBy, userId(req)), eq(cropRecords.idempotencyKey, idempotencyKey))).limit(1);
  if (existing) return res.status(200).json(existing);
  const [record] = await db.insert(cropRecords).values({ createdBy: userId(req), crop, plantingDate, areaHectares: String(areaHectares), growthStage, idempotencyKey }).returning();
  return res.status(201).json(record);
});

router.post("/observations", requireAuth, async (req, res) => {
  const { category, crop, notes, location, questions = "", photoData = [], idempotencyKey } = req.body ?? {};
  if (!category || !crop || !notes || !location || !idempotencyKey) {
    return res.status(400).json({ error: { message: "Invalid field observation data" } });
  }
  const [existing] = await db.select().from(fieldObservations).where(and(eq(fieldObservations.createdBy, userId(req)), eq(fieldObservations.idempotencyKey, idempotencyKey))).limit(1);
  if (existing) return res.status(200).json(existing);
  const photos = Array.isArray(photoData) ? photoData.filter((photo: unknown) => typeof photo === "string").slice(0, 5) : [];
  const [observation] = await db.insert(fieldObservations).values({ createdBy: userId(req), category, crop, notes, location, questions, photoData: photos, idempotencyKey }).returning();
  return res.status(201).json(observation);
});

router.get("/observations", requireAuth, async (req, res) => {
  const isExpert = req.user?.role === "EXPERT" || req.user?.role === "ADMIN";
  const observations = await db.select().from(fieldObservations)
    .where(isExpert ? undefined : eq(fieldObservations.createdBy, userId(req)))
    .orderBy(fieldObservations.createdAt);
  return res.status(200).json(observations.reverse());
});

router.patch("/observations/:id/response", requireAuth, async (req, res) => {
  if (req.user?.role !== "EXPERT" && req.user?.role !== "ADMIN") {
    return res.status(403).json({ error: { message: "Only experts can respond to cases" } });
  }
  const { diagnosis, recommendation, internalNotes = "" } = req.body ?? {};
  if (!diagnosis || !recommendation) {
    return res.status(400).json({ error: { message: "Diagnosis and recommendation are required" } });
  }
  const [updated] = await db.update(fieldObservations)
    .set({ diagnosis, recommendation, internalNotes, respondedBy: userId(req), respondedAt: new Date(), status: "RESOLVED" })
    .where(eq(fieldObservations.id, String(req.params.id)))
    .returning();
  if (!updated) return res.status(404).json({ error: { message: "Case not found" } });
  return res.status(200).json(updated);
});

export default router;