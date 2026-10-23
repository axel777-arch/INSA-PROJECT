import type { ContentStatus } from "./content.types";

const allowedTransitions: Record<ContentStatus, readonly ContentStatus[]> = {
  DRAFT: ["PENDING_REVIEW"],
  PENDING_REVIEW: ["APPROVED", "NEEDS_REVISION", "REJECTED"],
  NEEDS_REVISION: ["DRAFT", "PENDING_REVIEW"],
  APPROVED: ["PUBLISHED", "ARCHIVED"],
  REJECTED: ["DRAFT", "PENDING_REVIEW"],
  PUBLISHED: ["ARCHIVED"],
  ARCHIVED: [],
};

function normalizeStatus(status: string): ContentStatus {
  const upper = status.trim().toUpperCase().replace(/-/g, "_");
  if (upper === "IN_REVIEW") return "PENDING_REVIEW";
  if (upper === "REVISION_REQUESTED" || upper === "REVISION_NEEDED") return "NEEDS_REVISION";
  return upper as ContentStatus;
}

export function canTransition(
  from: string,
  to: string
): boolean {
  const normFrom = normalizeStatus(from);
  const normTo = normalizeStatus(to);
  return allowedTransitions[normFrom]?.includes(normTo) ?? false;
}

export function assertTransition(
  from: string,
  to: string
): void {
  if (!canTransition(from, to)) {
    throw new Error(
      `Invalid content status transition: ${from} -> ${to}`
    );
  }
}