-- schemaVersion 1
---
CREATE TABLE "contact_events" ("id" TEXT NOT NULL, "person_id" TEXT NOT NULL, "kind" INTEGER NOT NULL, "at" INTEGER NOT NULL, "suggestion_id" TEXT NULL, PRIMARY KEY ("id"));
---
CREATE TABLE "daily_suggestions" ("id" TEXT NOT NULL, "day" TEXT NOT NULL, "person_id" TEXT NOT NULL, "status" INTEGER NOT NULL, "created_at" INTEGER NOT NULL, PRIMARY KEY ("id"));
---
CREATE TABLE "local_settings" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, PRIMARY KEY ("key"));
---
CREATE TABLE "people" ("id" TEXT NOT NULL, "system_id" TEXT NULL, "name" TEXT NOT NULL, "phone" TEXT NULL, "whatsapp" INTEGER NOT NULL DEFAULT 1 CHECK ("whatsapp" IN (0, 1)), "importance" INTEGER NULL, "paused_until" INTEGER NULL, "note" TEXT NULL, "archived" INTEGER NOT NULL DEFAULT 0 CHECK ("archived" IN (0, 1)), "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"));
---
CREATE INDEX idx_contact_events_person ON contact_events (person_id, at);
---
CREATE INDEX idx_daily_suggestions_day ON daily_suggestions (day, created_at);
---
CREATE INDEX idx_people_system ON people (system_id);
