import { eq, desc, inArray } from "drizzle-orm";
import { db } from "../../db/index";
import { users } from "../../../../database/schema/users";
import { cases, caseResponses } from "../../../../database/schema/cases";
import { content } from "../../../../database/schema/content";
import { auditLogs } from "../../../../database/schema/auditLogs";
import { farmers } from "../../../../database/schema/farmers";

export interface NotificationItem {
  id: string;
  title: string;
  body: string;
  type: string;
  resourceType: "USER" | "CASE" | "CONTENT" | "MESSAGE" | "SYSTEM";
  resourceId: string;
  route: string;
  read: boolean;
  createdAt: string;
}

// In-memory set of read notification IDs for active sessions
const readNotificationIds = new Set<string>();

export async function markNotificationAsRead(id: string): Promise<boolean> {
  readNotificationIds.add(id);
  return true;
}

export async function getNotificationsForUser(user: { id: string; role: string }): Promise<NotificationItem[]> {
  const role = (user.role ?? "").toUpperCase();
  const notifs: NotificationItem[] = [];

  // 1. Admin notifications: Pending user approvals
  if (role === "ADMIN" || role === "SUPER_ADMIN") {
    const pendingUsers = await db
      .select({
        id: users.id,
        fullName: users.fullName,
        role: users.role,
        createdAt: users.createdAt,
      })
      .from(users)
      .where(eq(users.status, "PENDING_APPROVAL"))
      .orderBy(desc(users.createdAt))
      .limit(10);

    for (const u of pendingUsers) {
      notifs.push({
        id: `user-pending-${u.id}`,
        title: "Pending Registration Approval",
        body: `${u.fullName} registered as ${u.role} and awaits verification of credentials.`,
        type: "PENDING_USER_APPROVAL",
        resourceType: "USER",
        resourceId: u.id,
        route: "/admin/approvals",
        read: readNotificationIds.has(`user-pending-${u.id}`),
        createdAt: u.createdAt.toISOString(),
      });
    }

    // Recent critical audit events
    const logs = await db
      .select()
      .from(auditLogs)
      .orderBy(desc(auditLogs.createdAt))
      .limit(5);

    for (const l of logs) {
      notifs.push({
        id: `audit-${l.id}`,
        title: `Audit: ${l.action}`,
        body: l.details ? (() => {
          try {
            const parsed = JSON.parse(l.details!);
            return `${parsed.actorName} (${parsed.actorRole}): ${parsed.target}`;
          } catch {
            return l.details!;
          }
        })() : `System action ${l.action}`,
        type: "AUDIT_EVENT",
        resourceType: "SYSTEM",
        resourceId: l.id,
        route: "/admin/audit-logs",
        read: readNotificationIds.has(`audit-${l.id}`),
        createdAt: l.createdAt.toISOString(),
      });
    }
  }

  // 2. Expert notifications: Open/In-review cases & Content pending review
  if (role === "EXPERT" || role === "ADMIN") {
    const openCases = await db
      .select({
        id: cases.id,
        title: cases.title,
        description: cases.description,
        location: cases.location,
        createdAt: cases.createdAt,
      })
      .from(cases)
      .where(inArray(cases.status, ["OPEN", "IN_REVIEW"]))
      .orderBy(desc(cases.createdAt))
      .limit(10);

    for (const c of openCases) {
      notifs.push({
        id: `case-${c.id}`,
        title: "Field Case Escalation",
        body: `Case "${c.title}" at ${c.location ?? "field site"} requires expert diagnosis.`,
        type: "FIELD_CASE_ASSIGNED",
        resourceType: "CASE",
        resourceId: c.id,
        route: "/expert/case/detail",
        read: readNotificationIds.has(`case-${c.id}`),
        createdAt: c.createdAt.toISOString(),
      });
    }

    const pendingContent = await db
      .select({
        id: content.id,
        title: content.title,
        createdAt: content.createdAt,
      })
      .from(content)
      .where(eq(content.status, "PENDING_REVIEW"))
      .orderBy(desc(content.createdAt))
      .limit(10);

    for (const cnt of pendingContent) {
      notifs.push({
        id: `content-review-${cnt.id}`,
        title: "Advisory Review Required",
        body: `Advisory "${cnt.title}" has been submitted for technical agronomy review.`,
        type: "CONTENT_REVIEW_REQUIRED",
        resourceType: "CONTENT",
        resourceId: cnt.id,
        route: "/expert/reviews",
        read: readNotificationIds.has(`content-review-${cnt.id}`),
        createdAt: cnt.createdAt.toISOString(),
      });
    }
  }

  // 3. Extension Worker notifications: Published advisories & open field cases
  if (role === "EXTENSION_WORKER" || role === "ADMIN") {
    const publishedAdvisories = await db
      .select({
        id: content.id,
        title: content.title,
        body: content.body,
        createdAt: content.createdAt,
      })
      .from(content)
      .where(eq(content.status, "PUBLISHED"))
      .orderBy(desc(content.createdAt))
      .limit(10);

    for (const a of publishedAdvisories) {
      notifs.push({
        id: `adv-pub-${a.id}`,
        title: "New Advisory Published",
        body: a.body ? `${a.body.slice(0, 100)}...` : `"${a.title}" is ready for farmer field dissemination.`,
        type: "ADVISORY_PUBLISHED",
        resourceType: "CONTENT",
        resourceId: a.id,
        route: "/content/detail",
        read: readNotificationIds.has(`adv-pub-${a.id}`),
        createdAt: a.createdAt.toISOString(),
      });
    }
  }

  // 4. Farmer notifications: Latest advisories & case resolutions
  if (role === "FARMER" || role === "ADMIN") {
    const latestAdvisories = await db
      .select({
        id: content.id,
        title: content.title,
        body: content.body,
        createdAt: content.createdAt,
      })
      .from(content)
      .where(eq(content.status, "PUBLISHED"))
      .orderBy(desc(content.createdAt))
      .limit(5);

    for (const a of latestAdvisories) {
      notifs.push({
        id: `farmer-adv-${a.id}`,
        title: `Alert: ${a.title}`,
        body: a.body ? `${a.body.slice(0, 100)}...` : `New agricultural advisory issued for your region.`,
        type: "ADVISORY_ALERT",
        resourceType: "CONTENT",
        resourceId: a.id,
        route: "/farmer/advisories",
        read: readNotificationIds.has(`farmer-adv-${a.id}`),
        createdAt: a.createdAt.toISOString(),
      });
    }

    // Check resolved cases
    const resolvedCases = await db
      .select({
        id: cases.id,
        title: cases.title,
        updatedAt: cases.updatedAt,
      })
      .from(cases)
      .where(eq(cases.status, "RESOLVED"))
      .orderBy(desc(cases.updatedAt))
      .limit(5);

    for (const rc of resolvedCases) {
      notifs.push({
        id: `case-resolved-${rc.id}`,
        title: "Diagnosis Response Available",
        body: `Expert has diagnosed your crop case: "${rc.title}". Tap to view treatment instructions.`,
        type: "CASE_RESOLVED",
        resourceType: "CASE",
        resourceId: rc.id,
        route: "/farmer/cases",
        read: readNotificationIds.has(`case-resolved-${rc.id}`),
        createdAt: rc.updatedAt.toISOString(),
      });
    }
  }

  // Sort newest first
  return notifs.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
}
