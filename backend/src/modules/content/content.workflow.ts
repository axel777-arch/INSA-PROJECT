import type { ContentStatus } from "./content.types";

const allowedTransitions: Record<ContentStatus, readonly ContentStatus[]> = {
  DRAFT: ["PENDING_REVIEW"],
  PENDING_REVIEW: ["APPROVED", "REJECTED"],
  APPROVED: ["PUBLISHED"],
  REJECTED: ["DRAFT", "PENDING_REVIEW"],
  PUBLISHED: [],
};

function normalizeStatus(status: string): ContentStatus {
  if (status === "IN_REVIEW") return "PENDING_REVIEW";
  return status as ContentStatus;
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