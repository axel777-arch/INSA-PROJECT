import type { Content, NewContent } from "../../../../database/schema/content";
import type { ContentVersion, NewContentVersion } from "../../../../database/schema/contentVersions";
import type { ContentReview, NewContentReview } from "../../../../database/schema/contentReviews";
import { contentStatusEnum } from "../../../../database/schema/content";

export type { Content, NewContent, ContentVersion, NewContentVersion, ContentReview, NewContentReview };

export type ContentStatus = (typeof contentStatusEnum.enumValues)[number];

export interface CreateContentInput {
  title: string;
  summary?: string | null;
  body: string;
  cropId?: string | null;
  category?: string | null;
  language?: string;
  region?: string | null;
  zone?: string | null;
  woreda?: string | null;
  kebele?: string | null;
  season?: string | null;
  cropStage?: string | null;
  priority?: string;
  validFrom?: Date | string | null;
  validUntil?: Date | string | null;
  sourceInfo?: string | null;
  attachments?: string | null;
  authorId?: string;
  createdBy?: string;
}

export interface UpdateContentInput {
  title?: string;
  summary?: string | null;
  body?: string;
  cropId?: string | null;
  category?: string | null;
  language?: string;
  region?: string | null;
  zone?: string | null;
  woreda?: string | null;
  kebele?: string | null;
  season?: string | null;
  cropStage?: string | null;
  priority?: string;
  validFrom?: Date | string | null;
  validUntil?: Date | string | null;
  sourceInfo?: string | null;
  attachments?: string | null;
  changeSummary?: string;
}

export interface SubmitForReviewInput {
  contentId: string;
  submittedBy: string;
}

export interface ApproveContentInput {
  contentId: string;
  approvedBy: string;
  comment?: string;
}

export interface RejectContentInput {
  contentId: string;
  rejectedBy: string;
  comment: string;
}

export interface RequestRevisionInput {
  contentId: string;
  reviewerId: string;
  comment: string;
}

export interface PublishContentInput {
  contentId: string;
  publishedBy?: string;
}

export interface ArchiveContentInput {
  contentId: string;
  archivedBy: string;
  reason?: string;
}

export interface ContentFilter {
  status?: ContentStatus;
  cropId?: string;
  category?: string;
  authorId?: string;
  reviewerId?: string;
  language?: string;
  region?: string;
  zone?: string;
  woreda?: string;
  search?: string;
  dateFrom?: string | Date;
  dateTo?: string | Date;
  includeArchived?: boolean;
}

export interface ContentTargetingCriteria {
  cropId?: string | null;
  region?: string | null;
  language?: string | null;
}

/**
 * Service Contract for Member 4:
 * Documented event shape emitted or returned upon successful advisory publication.
 */
export interface ContentPublishedEvent {
  eventId: string;
  eventType: "CONTENT_PUBLISHED";
  timestamp: string;
  content: Content;
  targetCriteria: ContentTargetingCriteria;
  matchedRecipientCount: number;
  broadcastMessageId?: string;
}