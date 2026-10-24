import { and, eq, desc, ilike } from "drizzle-orm";
import { db } from "../../db/index";
import { messages } from "../../../../database/schema/messages";
import { messageRecipients } from "../../../../database/schema/messageRecipients";
import { content } from "../../../../database/schema/content";
import { crops } from "../../../../database/schema/crops";
import { farmers } from "../../../../database/schema/farmers";
import { users } from "../../../../database/schema/users";

export interface SmsQueryInput {
  senderPhone?: string;
  farmerId?: string;
  messageText: string;
  createdBy: string;
}

export interface SmsQueryResponse {
  query: string;
  reply: string;
  timestamp: string;
  inboundMessageId: string;
  outboundMessageId: string;
}

const ETHIOPIAN_CROPS = [
  { name: "TEFF", scientific: "Eragrostis tef", key: "teff" },
  { name: "MAIZE", scientific: "Zea mays", key: "maize" },
  { name: "WHEAT", scientific: "Triticum", key: "wheat" },
  { name: "COFFEE", scientific: "Coffea arabica", key: "coffee" },
  { name: "BARLEY", scientific: "Hordeum vulgare", key: "barley" },
  { name: "SORGHUM", scientific: "Sorghum bicolor", key: "sorghum" },
  { name: "SESAME", scientific: "Sesamum indicum", key: "sesame" },
];
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function processTwoWaySmsQuery(input: SmsQueryInput): Promise<SmsQueryResponse> {
  const text = (input.messageText || "").trim();
  const upper = text.toUpperCase();
  const phone = input.senderPhone;
  if (!phone || !UUID_REGEX.test(input.createdBy) || text.length > 1000) {
    throw new Error("SMS simulation requires an authenticated user, sender phone, and message under 1000 characters");
  }

  let farmerRecord: { id: string } | undefined;
  if (input.farmerId && UUID_REGEX.test(input.farmerId)) {
    const [f] = await db.select({ id: farmers.id }).from(farmers).where(eq(farmers.id, input.farmerId)).limit(1);
    farmerRecord = f;
  } else {
    const [f] = await db
      .select({ id: farmers.id })
      .from(farmers)
      .innerJoin(users, eq(users.id, farmers.userId))
      .where(eq(users.phone, phone))
      .limit(1);
    farmerRecord = f;
  }

  // Responses describe simulator behavior and never claim live weather, market, or provider data.
  let reply = "";

  if (upper.includes("WEATHER")) {
    reply = "[SIMULATION ONLY] No live weather provider is configured. Check local forecasts before field operations or contact your extension worker.";
  } else if (upper.includes("PRICE") || upper.includes("MARKET") || upper.includes("ECX")) {
    reply = "[SIMULATION ONLY] No live market-price provider is configured. Contact your local market office for current prices.";
  } else {
    // Check if a crop is mentioned
    const matchedCrop = ETHIOPIAN_CROPS.find((c) => upper.includes(c.name));

    if (matchedCrop) {
      const [crop] = await db
        .select({ id: crops.id })
        .from(crops)
        .where(ilike(crops.name, matchedCrop.name))
        .limit(1);
      const dbAdvisories = crop
        ? await db
            .select({ title: content.title, body: content.body })
            .from(content)
            .where(and(eq(content.status, "PUBLISHED"), eq(content.cropId, crop.id)))
            .limit(5)
        : [];

      const relevant = dbAdvisories.find(
        (a) => a.title.toUpperCase().includes(matchedCrop.name) || a.body.toUpperCase().includes(matchedCrop.name)
      );

      reply = relevant
        ? `[SIMULATED APPROVED ADVISORY - ${relevant.title}]: ${relevant.body.slice(0, 140)}`
        : `[SIMULATION ONLY] No published advisory for ${matchedCrop.name} was found. Please contact your extension worker for crop-specific advice.`;
    } else {
      reply = "[Agri-Insight SMS Service]: Unrecognized keyword. Send 'CROP <NAME> <SYMPTOM>' (e.g., CROP MAIZE LEAF_YELLOW), 'WEATHER' for rain forecast, or 'PRICE' for current ECX commodity market rates.";
    }
  }

  // 3. Persist inbound farmer query
  const [inbound] = await db
    .insert(messages)
    .values({
      title: `SMS Query: ${text.slice(0, 30)}`,
      body: text,
      channel: "SMS",
      status: "RECEIVED",
      createdBy: input.createdBy,
    })
    .returning();

  // 4. Persist outbound system reply
  const [outbound] = await db
    .insert(messages)
    .values({
      title: "SMS Automated Reply",
      body: reply,
      channel: "SMS",
      status: "SIMULATED",
      createdBy: input.createdBy,
    })
    .returning();

  // 5. Link recipients if farmer exists
  if (farmerRecord) {
    await db.insert(messageRecipients).values([
      { messageId: inbound.id, farmerId: farmerRecord.id, status: "SIMULATED_RECEIVED", deliveryMode: "SIMULATED", sentAt: new Date() },
      { messageId: outbound.id, farmerId: farmerRecord.id, status: "SIMULATED_SENT", deliveryMode: "SIMULATED", sentAt: new Date() },
    ]);
  }

  return {
    query: text,
    reply,
    timestamp: new Date().toISOString(),
    inboundMessageId: inbound.id,
    outboundMessageId: outbound.id,
  };
}

export async function listSmsHistory(limit = 30, userId: string) {
  const rows = await db
    .select({
      id: messages.id,
      title: messages.title,
      body: messages.body,
      status: messages.status,
      createdAt: messages.createdAt,
    })
    .from(messages)
    .where(and(eq(messages.channel, "SMS"), eq(messages.createdBy, userId)))
    .orderBy(desc(messages.createdAt))
    .limit(Math.max(1, Math.min(100, Math.trunc(limit) || 30)));

  return rows.reverse().map((m) => ({
    id: m.id,
    text: m.body,
    isUser: m.status === "RECEIVED",
    timestamp: m.createdAt.toISOString(),
  }));
}
