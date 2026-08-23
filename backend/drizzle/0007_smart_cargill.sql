ALTER TABLE "message_recipients" DROP CONSTRAINT IF EXISTS "message_recipients_recipient_id_users_id_fk";
--> statement-breakpoint
ALTER TABLE "message_recipients" ALTER COLUMN "recipient_id" SET DATA TYPE text;