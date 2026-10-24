import type { Content, NewContent } from "../../../../database/schema/content";
import { contentStatusEnum } from "../../../../database/schema/content";

export type { Content, NewContent };

export type ContentStatus = (typeof contentStatusEnum.enumValues)[number];

export interface CreateContentInput {
  title: string;
  body: string;
  cropId?: string | null;
  category?: string | null;
  authorId?: string;
  createdBy?: string;
}

export interface UpdateContentInput {
  title?: string;
  body?: string;
  cropId?: string | null;
  category?: string | null;
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

export interface ContentFilter {
  status?: ContentStatus;
  cropId?: string;
  category?: string;
  authorId?: string;
}

export interface ContentTargetingCriteria {
  cropId?: string;
  category?: string;
}