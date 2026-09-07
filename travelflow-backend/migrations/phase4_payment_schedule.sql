-- Phase 4: PaymentSchedule + PaymentScheduleItem Migration

BEGIN;

CREATE TABLE "PaymentSchedule" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "agencyId" UUID NOT NULL,
  "bookingId" UUID NOT NULL,
  title TEXT NOT NULL,
  "totalAmount" DOUBLE PRECISION NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  notes TEXT,
  "isDeleted" BOOLEAN NOT NULL DEFAULT false,
  "deletedAt" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "PaymentSchedule_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency"(id) ON DELETE CASCADE,
  CONSTRAINT "PaymentSchedule_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"(id) ON DELETE CASCADE
);

CREATE INDEX "PaymentSchedule_agencyId_bookingId_idx" ON "PaymentSchedule"("agencyId", "bookingId");
CREATE INDEX "PaymentSchedule_agencyId_isDeleted_idx" ON "PaymentSchedule"("agencyId", "isDeleted");

CREATE TABLE "PaymentScheduleItem" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "agencyId" UUID NOT NULL,
  "scheduleId" UUID NOT NULL,
  label TEXT NOT NULL,
  amount DOUBLE PRECISION NOT NULL,
  "dueDate" TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  "paidAt" TIMESTAMPTZ,
  "customerPaymentId" UUID,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "PaymentScheduleItem_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency"(id) ON DELETE CASCADE,
  CONSTRAINT "PaymentScheduleItem_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES "PaymentSchedule"(id) ON DELETE CASCADE,
  CONSTRAINT "PaymentScheduleItem_customerPaymentId_fkey" FOREIGN KEY ("customerPaymentId") REFERENCES "CustomerPayment"(id) ON DELETE SET NULL
);

CREATE INDEX "PaymentScheduleItem_agencyId_scheduleId_idx" ON "PaymentScheduleItem"("agencyId", "scheduleId");
CREATE INDEX "PaymentScheduleItem_agencyId_status_idx" ON "PaymentScheduleItem"("agencyId", "status");

COMMIT;
