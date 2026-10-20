import { eq, desc, or, ilike } from "drizzle-orm";
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

export async function processTwoWaySmsQuery(input: SmsQueryInput): Promise<SmsQueryResponse> {
  const text = (input.messageText || "").trim();
  const upper = text.toUpperCase();
  const phone = input.senderPhone || "+251911223344";

  // 1. Resolve user ID for foreign keys
  const [firstUser] = await db.select({ id: users.id }).from(users).limit(1);
  const systemUserId = firstUser?.id ?? "00000000-0000-0000-0000-000000000000";

  let farmerRecord: { id: string } | undefined;
  if (input.farmerId) {
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

  // 2. Generate intelligent agricultural response
  let reply = "";

  if (upper.includes("WEATHER")) {
    reply = "[Agri-Insight Weather Alert]: Oromia/Amhara/Sidama forecast: Moderate rain expected in 48h (15-25mm). Humidity 65%. Recommended: Delay open field pesticide spraying until conditions clear.";
  } else if (upper.includes("PRICE") || upper.includes("MARKET") || upper.includes("ECX")) {
    reply = "[Agri-Insight Market Rates]: ECX Central Addis Prices: Teff (Magna) 9,200 ETB/Qtl; Wheat (Grade 1) 4,800 ETB/Qtl; White Maize 3,400 ETB/Qtl; Washed Coffee 420 ETB/Kg. Prices stable.";
  } else {
    // Check if a crop is mentioned
    const matchedCrop = ETHIOPIAN_CROPS.find((c) => upper.includes(c.name));

    if (matchedCrop) {
      // Check database for published advisories matching this crop
      const dbAdvisories = await db
        .select({ title: content.title, body: content.body })
        .from(content)
        .where(eq(content.status, "PUBLISHED"))
        .limit(5);

      const relevant = dbAdvisories.find(
        (a) => a.title.toUpperCase().includes(matchedCrop.name) || a.body.toUpperCase().includes(matchedCrop.name)
      );

      if (upper.includes("YELLOW") || upper.includes("LEAF")) {
        reply = `[Agri-Insight Advisory - ${matchedCrop.name}]: Yellowing leaves typically indicate nitrogen deficiency or root rot. Apply Urea (50kg/ha) if stunted, or improve drainage. If spots appear, spray Mancozeb fungicide.`;
      } else if (upper.includes("RUST") || upper.includes("FUNGUS")) {
        reply = `[Agri-Insight Advisory - ${matchedCrop.name}]: Rust outbreak detected in regional cluster. Apply Tilt (Propiconazole) or Nativo fungicide early morning. Avoid late afternoon irrigation.`;
      } else if (upper.includes("PEST") || upper.includes("WORM") || upper.includes("BORER")) {
        reply = `[Agri-Insight Advisory - ${matchedCrop.name}]: Fall Armyworm / stem borer symptoms suspected. Apply recommended biopesticide or Karate (Lambda-cyhalothrin) immediately. Consult your local Extension Agent.`;
      } else if (relevant) {
        reply = `[Agri-Insight - ${relevant.title}]: ${relevant.body.slice(0, 140)}... (Reply HELP for more).`;
      } else {
        reply = `[Agri-Insight Advisory - ${matchedCrop.name}]: Best practice: ensure seed spacing 20x40cm, apply DAP at planting and top-dress with Urea at 35 days. Weed twice before flowering.`;
      }
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
      createdBy: systemUserId,
    })
    .returning();

  // 4. Persist outbound system reply
  const [outbound] = await db
    .insert(messages)
    .values({
      title: "SMS Automated Reply",
      body: reply,
      channel: "SMS",
      status: "SENT",
      createdBy: systemUserId,
    })
    .returning();

  // 5. Link recipients if farmer exists
  if (farmerRecord) {
    await db.insert(messageRecipients).values([
      { messageId: inbound.id, farmerId: farmerRecord.id, status: "DELIVERED", sentAt: new Date() },
      { messageId: outbound.id, farmerId: farmerRecord.id, status: "SENT", sentAt: new Date() },
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

export async function listSmsHistory(limit = 30) {
  const rows = await db
    .select({
      id: messages.id,
      title: messages.title,
      body: messages.body,
      status: messages.status,
      createdAt: messages.createdAt,
    })
    .from(messages)
    .where(eq(messages.channel, "SMS"))
    .orderBy(desc(messages.createdAt))
    .limit(limit);

  return rows.reverse().map((m) => ({
    id: m.id,
    text: m.body,
    isUser: m.status === "RECEIVED",
    timestamp: m.createdAt.toISOString(),
  }));
}
