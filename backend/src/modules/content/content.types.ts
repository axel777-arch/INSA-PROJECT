import type { Content, NewContent } from "../../../../database/schema/content";
import { contentStatusEnum } from "../../../../database/schema/content";

export type { Content, NewContent };

export type ContentStatus = (typeof contentStatusEnum.enumValues)[number];

export interface CreateContentInput {
  title: string;
  body: string;
  cropId?: string | null;
  language: string;
  location?: string | null;
  createdBy: string;
}
export interface UpdateContentInput {
  title?: string;
  body?: string;
  cropId?: string | null;
  language?: string;
  location?: string | null;
}

export interface SubmitForReviewInput {
  contentId: string;
  submittedBy: string;
}

export interface ApproveContentInput {
  contentId: string;
  approvedBy: string;
}
export interface RejectContentInput {
  contentId: string;
  rejectedBy: string;
  comment?: string;
}
export interface PublishContentInput {
  contentId: string;
  publishedBy?: string;
}
export interface ArchiveContentInput {
  contentId: string;
  archivedBy?: string;
}

export interface ContentFilter {
  status?: ContentStatus;
  cropId?: string;
  language?: string;
  location?: string;
}
export interface ContentTargetingCriteria {
  cropId?: string;
  language?: string;
  location?: string;
}