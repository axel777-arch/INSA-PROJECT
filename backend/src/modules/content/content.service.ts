export enum ContentStatus {
  DRAFT = "DRAFT",
  IN_REVIEW = "IN_REVIEW",
  APPROVED = "APPROVED",
  REJECTED = "REJECTED",
  PUBLISHED = "PUBLISHED",
  ARCHIVED = "ARCHIVED",
}

export type ContentItem = {
  id: string;
  title: string;
  body: string;
  category: string;
  status: ContentStatus;
  createdBy: string;
  reviewedBy?: string;
  rejectionReason?: string;
  createdAt: Date;
  updatedAt: Date;
  publishedAt?: Date;
};

export class ContentService {
  private readonly validTransitions: Record<ContentStatus, ContentStatus[]> = {
    [ContentStatus.DRAFT]: [ContentStatus.IN_REVIEW],
    [ContentStatus.IN_REVIEW]: [ContentStatus.APPROVED, ContentStatus.REJECTED],
    [ContentStatus.APPROVED]: [ContentStatus.PUBLISHED],
    [ContentStatus.REJECTED]: [ContentStatus.DRAFT],
    [ContentStatus.PUBLISHED]: [ContentStatus.ARCHIVED],
    [ContentStatus.ARCHIVED]: [],
  };

  canTransition(from: ContentStatus, to: ContentStatus): boolean {
    return this.validTransitions[from]?.includes(to) ?? false;
  }

  createDraft(input: { title: string; body: string; category?: string; createdBy: string }): ContentItem {
    const now = new Date();

    return {
      id: this.makeId(),
      title: input.title.trim(),
      body: input.body.trim(),
      category: input.category ?? "general",
      status: ContentStatus.DRAFT,
      createdBy: input.createdBy,
      createdAt: now,
      updatedAt: now,
    };
  }

  updateContent(content: ContentItem, changes: Partial<Pick<ContentItem, "title" | "body" | "category">>): ContentItem {
    if (content.status !== ContentStatus.DRAFT) {
      throw new Error("Only draft content can be edited.");
    }

    return {
      ...content,
      title: changes.title?.trim() ?? content.title,
      body: changes.body?.trim() ?? content.body,
      category: changes.category ?? content.category,
      updatedAt: new Date(),
    };
  }

  submitForReview(content: ContentItem): ContentItem {
    if (!this.canTransition(content.status, ContentStatus.IN_REVIEW)) {
      throw new Error(`Content cannot move from ${content.status} to ${ContentStatus.IN_REVIEW}.`);
    }

    return {
      ...content,
      status: ContentStatus.IN_REVIEW,
      updatedAt: new Date(),
      rejectionReason: undefined,
    };
  }

  approve(content: ContentItem, reviewerId: string): ContentItem {
    if (!this.canTransition(content.status, ContentStatus.APPROVED)) {
      throw new Error(`Only content in review can be approved.`);
    }

    return {
      ...content,
      status: ContentStatus.APPROVED,
      reviewedBy: reviewerId,
      updatedAt: new Date(),
      rejectionReason: undefined,
    };
  }

  reject(content: ContentItem, reviewerId: string, reason: string): ContentItem {
    if (!this.canTransition(content.status, ContentStatus.REJECTED)) {
      throw new Error(`Only content in review can be rejected.`);
    }

    return {
      ...content,
      status: ContentStatus.REJECTED,
      reviewedBy: reviewerId,
      rejectionReason: reason,
      updatedAt: new Date(),
    };
  }

  publish(content: ContentItem): ContentItem {
    if (!this.canTransition(content.status, ContentStatus.PUBLISHED)) {
      throw new Error(`Only approved content can be published.`);
    }

    return {
      ...content,
      status: ContentStatus.PUBLISHED,
      publishedAt: new Date(),
      updatedAt: new Date(),
    };
  }

  archive(content: ContentItem): ContentItem {
    if (!this.canTransition(content.status, ContentStatus.ARCHIVED)) {
      throw new Error(`Only published content can be archived.`);
    }

    return {
      ...content,
      status: ContentStatus.ARCHIVED,
      updatedAt: new Date(),
    };
  }

  private makeId(): string {
    return `content_${Math.random().toString(36).slice(2, 10)}`;
  }
}
