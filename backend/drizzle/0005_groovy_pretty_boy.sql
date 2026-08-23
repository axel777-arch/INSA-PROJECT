CREATE TABLE "admin_settings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"instance_name" text DEFAULT 'Agri-Insight Beacon' NOT NULL,
	"default_language" text DEFAULT 'English' NOT NULL,
	"support_email" text DEFAULT 'support@agri-insight.com' NOT NULL,
	"sms_broadcast_enabled" boolean DEFAULT true NOT NULL,
	"maintenance_mode" boolean DEFAULT false NOT NULL,
	"auto_escalation_hours" double precision DEFAULT 24 NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
