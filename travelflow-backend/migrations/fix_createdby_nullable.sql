-- Make JournalEntry.createdBy nullable for system-generated entries
ALTER TABLE "JournalEntry" ALTER COLUMN "createdBy" DROP NOT NULL;
ALTER TABLE "JournalEntry" DROP CONSTRAINT "JournalEntry_createdBy_fkey";
ALTER TABLE "JournalEntry" ADD CONSTRAINT "JournalEntry_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"(id) ON DELETE SET NULL;
