import { eq, and, isNull } from "drizzle-orm";
import { db } from "../../db/index";
import {
  farmers,
  users,
  farmerWorkerAssignments,
} from "../../../../database/schema";

export async function assignFarmerToWorker(
  farmerId: string,
  workerId: string,
  assignedBy: string,
  note?: string,
) {
  // Check that the farmer exists.
  const [farmer] = await db
    .select({ id: farmers.id })
    .from(farmers)
    .where(eq(farmers.id, farmerId))
    .limit(1);

  if (!farmer) {
    throw new Error("Farmer not found");
  }

  // Check that the worker exists, is active, and has the correct role.
  const [worker] = await db
    .select({
      id: users.id,
      role: users.role,
      active: users.active,
    })
    .from(users)
    .where(eq(users.id, workerId))
    .limit(1);

  if (!worker) {
    throw new Error("Extension worker not found");
  }

  if (worker.role !== "EXTENSION_WORKER") {
    throw new Error("The selected user is not an extension worker");
  }

  if (!worker.active) {
    throw new Error("The extension worker is inactive");
  }

  // Verify that the assigning user exists and is active.
  const [assigner] = await db
    .select({
      id: users.id,
      active: users.active,
    })
    .from(users)
    .where(eq(users.id, assignedBy))
    .limit(1);

  if (!assigner || !assigner.active) {
    throw new Error("The assigning user does not exist or is inactive");
  }

  // End any existing active assignment for this farmer.
  const now = new Date();

  await db
    .update(farmerWorkerAssignments)
    .set({ effectiveTo: now })
    .where(
      and(
        eq(farmerWorkerAssignments.farmerId, farmerId),
        isNull(farmerWorkerAssignments.effectiveTo),
      ),
    );

  // Create the new assignment.
  const [assignment] = await db
    .insert(farmerWorkerAssignments)
    .values({
      farmerId,
      workerId,
      assignedBy,
      note: note ?? null,
      effectiveFrom: now,
    })
    .returning();

  return assignment;
}

export async function getFarmerAssignments(farmerId: string) {
  return db
    .select({
      id: farmerWorkerAssignments.id,
      farmerId: farmerWorkerAssignments.farmerId,
      workerId: farmerWorkerAssignments.workerId,
      workerName: users.fullName,
      assignedBy: farmerWorkerAssignments.assignedBy,
      effectiveFrom: farmerWorkerAssignments.effectiveFrom,
      effectiveTo: farmerWorkerAssignments.effectiveTo,
      note: farmerWorkerAssignments.note,
      createdAt: farmerWorkerAssignments.createdAt,
    })
    .from(farmerWorkerAssignments)
    .innerJoin(
      users,
      eq(farmerWorkerAssignments.workerId, users.id),
    )
    .where(eq(farmerWorkerAssignments.farmerId, farmerId));
}