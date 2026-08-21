import type { ContentStatus } from "./content.types";

const allowedTransitions: Record<
  ContentStatus,
  readonly ContentStatus[]
> = {
  DRAFT: ["IN_REVIEW"],
  IN_REVIEW: ["APPROVED", "REJECTED"],
  APPROVED: ["PUBLISHED"],
  REJECTED: ["DRAFT", "IN_REVIEW"],
  PUBLISHED: ["ARCHIVED"],
  ARCHIVED: [],
};

export function canTransition(
  from: ContentStatus,
  to: ContentStatus
): boolean {
  return allowedTransitions[from].includes(to);
}

export function assertTransition(
  from: ContentStatus,
  to: ContentStatus
): void {
  if (!canTransition(from, to)) {
    throw new Error(
      `Invalid content status transition: ${from} -> ${to}`
    );
  }
}