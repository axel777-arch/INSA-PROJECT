
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
  assignmentType: string = "PRIMARY",
  reason?: string,
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
    throw new Error(
      "The assigning user does not exist or is inactive",
    );
  }

  // Close the previous assignment and create the new one atomically.
  const now = new Date();

  return db.transaction(async (tx) => {
    // Lock this farmer's row to serialize concurrent assignments.
    const [lockedFarmer] = await tx
      .select({ id: farmers.id })
      .from(farmers)
      .where(eq(farmers.id, farmerId))
      .for("update");

    if (!lockedFarmer) {
      throw new Error("Farmer not found");
    }

    // Keep other workers' active assignments to support shared coverage.
    // Return the existing assignment if this worker is already assigned.
    const [existingAssignment] = await tx
      .select()
      .from(farmerWorkerAssignments)
      .where(
        and(
          eq(farmerWorkerAssignments.farmerId, farmerId),
          eq(farmerWorkerAssignments.workerId, workerId),
          isNull(farmerWorkerAssignments.effectiveTo),
          eq(farmerWorkerAssignments.status, "ACTIVE"),
        ),
      )
      .limit(1);

    if (existingAssignment) {
      return existingAssignment;
    }

    // Create a new assignment without ending other workers' assignments.
    const [assignment] = await tx
      .insert(farmerWorkerAssignments)
      .values({
        farmerId,
        workerId,
        assignedBy,
        note: note ?? reason ?? null,
        assignmentType,
        status: "ACTIVE",
        reason: reason ?? note ?? null,
        effectiveFrom: now,
        updatedAt: now,
      })
      .returning();

    return assignment;
  });
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
      assignmentType: farmerWorkerAssignments.assignmentType,
      status: farmerWorkerAssignments.status,
      reason: farmerWorkerAssignments.reason,
      updatedAt: farmerWorkerAssignments.updatedAt,
      createdAt: farmerWorkerAssignments.createdAt,
    })
    .from(farmerWorkerAssignments)
    .innerJoin(
      users,
      eq(farmerWorkerAssignments.workerId, users.id),
    )
    .where(eq(farmerWorkerAssignments.farmerId, farmerId));
}

/**
 * Checks whether a user can access a farmer's record.
 *
 * ADMIN: can access all farmer records.
 * FARMER: can access only their own linked profile.
 * EXTENSION_WORKER: can access only currently assigned farmers.
 */
export async function canAccessFarmer(
  farmerId: string,
  userId: string,
  role: string,
): Promise<boolean> {
  // Administrators can access all farmer records.
  if (role === "ADMIN") {
    return true;
  }

  // Farmers can access only their own linked profile.
  if (role === "FARMER") {
    const [farmer] = await db
      .select({ id: farmers.id })
      .from(farmers)
      .where(
        and(
          eq(farmers.id, farmerId),
          eq(farmers.userId, userId),
        ),
      )
      .limit(1);

    return Boolean(farmer);
  }

  // Extension workers can access currently assigned farmers only.
  if (role === "EXTENSION_WORKER") {
    const [assignment] = await db
      .select({ id: farmerWorkerAssignments.id })
      .from(farmerWorkerAssignments)
      .where(
        and(
          eq(farmerWorkerAssignments.farmerId, farmerId),
          eq(farmerWorkerAssignments.workerId, userId),
          isNull(farmerWorkerAssignments.effectiveTo),
          eq(farmerWorkerAssignments.status, "ACTIVE"),
        ),
      )
      .limit(1);

    return Boolean(assignment);
  }

  // Deny access to all other roles.
  return false;
}
