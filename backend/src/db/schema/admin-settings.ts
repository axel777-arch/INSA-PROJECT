import { boolean, doublePrecision, pgTable, text, timestamp, uuid } from 'drizzle-orm/pg-core';

export const adminSettings = pgTable('admin_settings', {
  id: uuid('id').defaultRandom().primaryKey(),
  instanceName: text('instance_name').notNull().default('Agri-Insight Beacon'),
  defaultLanguage: text('default_language').notNull().default('English'),
  supportEmail: text('support_email').notNull().default('support@agri-insight.com'),
  smsBroadcastEnabled: boolean('sms_broadcast_enabled').notNull().default(true),
  maintenanceMode: boolean('maintenance_mode').notNull().default(false),
  autoEscalationHours: doublePrecision('auto_escalation_hours').notNull().default(24),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});
