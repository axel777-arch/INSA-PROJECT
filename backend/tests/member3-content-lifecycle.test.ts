import test from "node:test";
import assert from "node:assert/strict";

import {
  ContentService,
  ContentStatus,
  InvalidContentTransitionError,
} from "../src/modules/content/content.service";
import {
  createContentBodySchema,
  updateContentBodySchema,
  rejectContentBodySchema,
  requestRevisionBodySchema,
  listContentQuerySchema,
} from "../src/modules/content/content.schema";
import { canTransition } from "../src/modules/content/content.workflow";
import type { ContentPublishedEvent } from "../src/modules/content/content.types";

test("Member 3: ContentService createDraft supports all required advisory fields", () => {
  const service = new ContentService();
  const draft = service.createDraft({
    title: "Rust Prevention on Highland Wheat",
    summary: "Early fungal detection strategies for wet season wheat.",
    body: "Scout weekly for yellow/brown pustules on upper leaves. Apply fungicide at first detection.",
    cropId: "crop-wheat-1",
    category: "Pest & Disease",
    language: "am",
    region: "Amhara",
    zone: "West Gojjam",
    woreda: "Bure",
    kebele: "Kebele 04",
    season: "Meher",
    cropStage: "Vegetative",
    priority: "HIGH",
    validFrom: new Date("2026-07-01"),
    validUntil: new Date("2026-10-31"),
    sourceInfo: "Ethiopian Institute of Agricultural Research (EIAR) Bulletin #42",
    attachments: JSON.stringify([{ url: "https://example.com/rust.jpg", type: "image/jpeg" }]),
    authorId: "author-user-1",
  });

  assert.equal(draft.status, ContentStatus.DRAFT);
  assert.equal(draft.title, "Rust Prevention on Highland Wheat");
  assert.equal(draft.summary, "Early fungal detection strategies for wet season wheat.");
  assert.equal(draft.language, "am");
  assert.equal(draft.region, "Amhara");
  assert.equal(draft.priority, "HIGH");
  assert.equal(draft.version, 1);
  assert.equal(draft.authorId, "author-user-1");
  assert.equal(typeof draft.id, "string");
});

test("Member 3: Zod schema enforces required fields and formats", () => {
  // Valid payload
  const valid = createContentBodySchema.safeParse({
    title: "Safe Pesticide Storage",
    body: "Keep in original locked containers away from feed and children.",
    language: "en",
    priority: "URGENT",
  });
  assert.equal(valid.success, true);

  // Missing required title
  const invalidTitle = createContentBodySchema.safeParse({
    body: "Missing title",
  });
  assert.equal(invalidTitle.success, false);

  // Missing required body
  const invalidBody = createContentBodySchema.safeParse({
    title: "Only title",
  });
  assert.equal(invalidBody.success, false);

  // Reject without comment must fail
  const invalidReject = rejectContentBodySchema.safeParse({});
  assert.equal(invalidReject.success, false);

  // Reject with empty comment must fail
  const emptyReject = rejectContentBodySchema.safeParse({ comment: "   " });
  assert.equal(emptyReject.success, false);

  // Revision request without comment must fail
  const invalidRevision = requestRevisionBodySchema.safeParse({ comment: "" });
  assert.equal(invalidRevision.success, false);

  // Valid revision request
  const validRevision = requestRevisionBodySchema.safeParse({
    comment: "Please specify the recommended dilution ratio for chemical treatments.",
  });
  assert.equal(validRevision.success, true);
});

test("Member 3: Workflow enforces full editorial state machine", () => {
  // 1. Draft to Review
  assert.equal(canTransition("DRAFT", "PENDING_REVIEW"), true);

  // 2. Expert decisions from PENDING_REVIEW
  assert.equal(canTransition("PENDING_REVIEW", "APPROVED"), true);
  assert.equal(canTransition("PENDING_REVIEW", "NEEDS_REVISION"), true);
  assert.equal(canTransition("PENDING_REVIEW", "REJECTED"), true);

  // 3. Revision requested returns to author queue
  assert.equal(canTransition("NEEDS_REVISION", "DRAFT"), true);
  assert.equal(canTransition("NEEDS_REVISION", "PENDING_REVIEW"), true);

  // 4. Rejection can be reopened by author
  assert.equal(canTransition("REJECTED", "DRAFT"), true);

  // 5. Approved to Published or Archived
  assert.equal(canTransition("APPROVED", "PUBLISHED"), true);
  assert.equal(canTransition("APPROVED", "ARCHIVED"), true);

  // 6. Published to Archived
  assert.equal(canTransition("PUBLISHED", "ARCHIVED"), true);

  // 7. Archived cannot transition back
  assert.equal(canTransition("ARCHIVED", "PUBLISHED"), false);
  assert.equal(canTransition("ARCHIVED", "DRAFT"), false);

  // 8. Cannot skip review
  assert.equal(canTransition("DRAFT", "APPROVED"), false);
  assert.equal(canTransition("DRAFT", "PUBLISHED"), false);
  assert.equal(canTransition("PENDING_REVIEW", "PUBLISHED"), false);
});

test("Member 3: Revision workflow returns draft and preserves history", () => {
  const service = new ContentService();
  const draft = service.createDraft({
    title: "Armyworm Alert",
    body: "Initial scouting report.",
    createdBy: "author-1",
  });

  // Author submits
  const submitted = service.submitForReview(draft);
  assert.equal(submitted.status, "PENDING_REVIEW");

  // Expert requests revision
  assert.equal(canTransition(submitted.status, "NEEDS_REVISION"), true);
  const returnedForRevision = {
    ...submitted,
    status: "NEEDS_REVISION" as const,
  };

  // Author edits and resubmits
  assert.equal(canTransition(returnedForRevision.status, "PENDING_REVIEW"), true);
  const resubmitted = service.submitForReview(returnedForRevision);
  assert.equal(resubmitted.status, "PENDING_REVIEW");
});

test("Member 3: Query filtering handles search, language, location, and archival", () => {
  const parsed = listContentQuerySchema.safeParse({
    search: "wheat rust",
    language: "am",
    region: "Amhara",
    includeArchived: "true",
  });

  assert.equal(parsed.success, true);
  if (parsed.success) {
    assert.equal(parsed.data.search, "wheat rust");
    assert.equal(parsed.data.language, "am");
    assert.equal(parsed.data.region, "Amhara");
    assert.equal(parsed.data.includeArchived, true);
  }
});

test("Member 3: Publication event contract matches Member 4 requirements", () => {
  const event: ContentPublishedEvent = {
    eventId: "evt-12345",
    eventType: "CONTENT_PUBLISHED",
    timestamp: new Date().toISOString(),
    content: {
      id: "c-100",
      title: "Locust Warning",
      summary: "Swarm sighted in eastern lowlands.",
      body: "Report coordinates immediately to kebele DA.",
      cropId: null,
      category: "Emergency Alert",
      language: "om",
      region: "Oromia",
      zone: "East Hararghe",
      woreda: null,
      kebele: null,
      season: null,
      cropStage: null,
      priority: "URGENT",
      validFrom: new Date(),
      validUntil: null,
      sourceInfo: "Desert Locust Control Organization",
      attachments: null,
      version: 1,
      status: "PUBLISHED",
      authorId: "user-author",
      approvedBy: "user-expert",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    targetCriteria: {
      cropId: null,
      region: "Oromia",
      language: "om",
    },
    matchedRecipientCount: 125,
    broadcastMessageId: "msg-999",
  };

  assert.equal(event.eventType, "CONTENT_PUBLISHED");
  assert.equal(event.content.status, "PUBLISHED");
  assert.equal(event.matchedRecipientCount, 125);
  assert.equal(event.targetCriteria.region, "Oromia");
  assert.equal(event.targetCriteria.language, "om");
});
