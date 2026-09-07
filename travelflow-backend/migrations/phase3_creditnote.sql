-- Phase 3: CreditNote Migration

BEGIN;

-- 1. Create CreditNote table
CREATE TABLE "CreditNote" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "agencyId" UUID NOT NULL,
  "branchId" UUID,
  "creditNoteRef" TEXT NOT NULL,
  "invoiceId" UUID NOT NULL,
  "customerId" UUID NOT NULL,
  "bookingId" UUID,
  amount DOUBLE PRECISION NOT NULL,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'issued',
  "issuedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "appliedAt" TIMESTAMPTZ,
  notes TEXT,
  "isDeleted" BOOLEAN NOT NULL DEFAULT false,
  "deletedAt" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "CreditNote_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency"(id) ON DELETE CASCADE,
  CONSTRAINT "CreditNote_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"(id) ON DELETE SET NULL,
  CONSTRAINT "CreditNote_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"(id) ON DELETE CASCADE,
  CONSTRAINT "CreditNote_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "Customer"(id) ON DELETE CASCADE,
  CONSTRAINT "CreditNote_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"(id) ON DELETE SET NULL,
  CONSTRAINT "CreditNote_agencyId_creditNoteRef_key" UNIQUE ("agencyId", "creditNoteRef")
);

CREATE INDEX "CreditNote_agencyId_idx" ON "CreditNote"("agencyId");
CREATE INDEX "CreditNote_agencyId_invoiceId_idx" ON "CreditNote"("agencyId", "invoiceId");
CREATE INDEX "CreditNote_agencyId_customerId_idx" ON "CreditNote"("agencyId", "customerId");
CREATE INDEX "CreditNote_agencyId_isDeleted_idx" ON "CreditNote"("agencyId", "isDeleted");
CREATE INDEX "CreditNote_agencyId_isDeleted_createdAt_idx" ON "CreditNote"("agencyId", "isDeleted", "createdAt" DESC);

COMMIT;
