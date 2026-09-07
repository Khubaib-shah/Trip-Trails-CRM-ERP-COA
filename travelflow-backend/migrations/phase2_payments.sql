-- Phase 2: Payment Architecture Migration
-- Creates CustomerPayment, PaymentAllocation, SupplierPaymentAllocation tables
-- Migrates existing Receipt data to CustomerPayment + PaymentAllocation
-- Drops Receipt table and related FKs

BEGIN;

-- 1. Create CustomerPayment table
CREATE TABLE "CustomerPayment" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "agencyId" UUID NOT NULL,
  "branchId" UUID,
  "paymentRef" TEXT NOT NULL,
  "customerId" UUID NOT NULL,
  "bookingId" UUID,
  amount DOUBLE PRECISION NOT NULL,
  "paymentMethod" TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  notes TEXT,
  date TIMESTAMPTZ NOT NULL DEFAULT now(),
  "recordedById" UUID,
  "isDeleted" BOOLEAN NOT NULL DEFAULT false,
  "deletedAt" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "CustomerPayment_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency"(id) ON DELETE CASCADE,
  CONSTRAINT "CustomerPayment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES "Branch"(id) ON DELETE SET NULL,
  CONSTRAINT "CustomerPayment_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "Customer"(id) ON DELETE CASCADE,
  CONSTRAINT "CustomerPayment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"(id) ON DELETE SET NULL,
  CONSTRAINT "CustomerPayment_recordedById_fkey" FOREIGN KEY ("recordedById") REFERENCES "User"(id) ON DELETE SET NULL,
  CONSTRAINT "CustomerPayment_agencyId_paymentRef_key" UNIQUE ("agencyId", "paymentRef")
);

CREATE INDEX "CustomerPayment_agencyId_idx" ON "CustomerPayment"("agencyId");
CREATE INDEX "CustomerPayment_agencyId_customerId_idx" ON "CustomerPayment"("agencyId", "customerId");
CREATE INDEX "CustomerPayment_agencyId_bookingId_idx" ON "CustomerPayment"("agencyId", "bookingId");
CREATE INDEX "CustomerPayment_agencyId_branchId_idx" ON "CustomerPayment"("agencyId", "branchId");
CREATE INDEX "CustomerPayment_agencyId_isDeleted_idx" ON "CustomerPayment"("agencyId", "isDeleted");
CREATE INDEX "CustomerPayment_agencyId_isDeleted_createdAt_idx" ON "CustomerPayment"("agencyId", "isDeleted", "createdAt" DESC);
CREATE INDEX "CustomerPayment_agencyId_isDeleted_customerId_date_idx" ON "CustomerPayment"("agencyId", "isDeleted", "customerId", "date");

-- 2. Create PaymentAllocation table
CREATE TABLE "PaymentAllocation" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "agencyId" UUID NOT NULL,
  "customerPaymentId" UUID NOT NULL,
  "bookingId" UUID NOT NULL,
  amount DOUBLE PRECISION NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "PaymentAllocation_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency"(id) ON DELETE CASCADE,
  CONSTRAINT "PaymentAllocation_customerPaymentId_fkey" FOREIGN KEY ("customerPaymentId") REFERENCES "CustomerPayment"(id) ON DELETE CASCADE,
  CONSTRAINT "PaymentAllocation_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"(id) ON DELETE CASCADE
);

CREATE INDEX "PaymentAllocation_agencyId_customerPaymentId_idx" ON "PaymentAllocation"("agencyId", "customerPaymentId");
CREATE INDEX "PaymentAllocation_agencyId_bookingId_idx" ON "PaymentAllocation"("agencyId", "bookingId");

-- 3. Create SupplierPaymentAllocation table
CREATE TABLE "SupplierPaymentAllocation" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "agencyId" UUID NOT NULL,
  "supplierPaymentId" UUID NOT NULL,
  "bookingId" UUID NOT NULL,
  "bookingServiceId" UUID,
  amount DOUBLE PRECISION NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT "SupplierPaymentAllocation_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency"(id) ON DELETE CASCADE,
  CONSTRAINT "SupplierPaymentAllocation_supplierPaymentId_fkey" FOREIGN KEY ("supplierPaymentId") REFERENCES "SupplierPayment"(id) ON DELETE CASCADE,
  CONSTRAINT "SupplierPaymentAllocation_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"(id) ON DELETE CASCADE,
  CONSTRAINT "SupplierPaymentAllocation_bookingServiceId_fkey" FOREIGN KEY ("bookingServiceId") REFERENCES "BookingService"(id) ON DELETE SET NULL
);

CREATE INDEX "SupplierPaymentAllocation_agencyId_supplierPaymentId_idx" ON "SupplierPaymentAllocation"("agencyId", "supplierPaymentId");
CREATE INDEX "SupplierPaymentAllocation_agencyId_bookingId_idx" ON "SupplierPaymentAllocation"("agencyId", "bookingId");

-- 4. Migrate Receipt data -> CustomerPayment + PaymentAllocation
INSERT INTO "CustomerPayment" (
  id, "agencyId", "branchId", "paymentRef", "customerId", "bookingId",
  amount, "paymentMethod", status, notes, date, "isDeleted", "deletedAt",
  "createdAt", "updatedAt"
)
SELECT
  id, "agencyId", "branchId",
  REPLACE("receiptRef", 'RCP', 'CPY'),
  "customerId", "bookingId",
  amount, "paymentMethod", 'completed', notes, date, "isDeleted", "deletedAt",
  "createdAt", "updatedAt"
FROM "Receipt"
WHERE "isDeleted" = false;

INSERT INTO "PaymentAllocation" (
  id, "agencyId", "customerPaymentId", "bookingId", amount, "createdAt", "updatedAt"
)
SELECT
  gen_random_uuid(), r."agencyId", r.id, r."bookingId", r.amount, r."createdAt", r."updatedAt"
FROM "Receipt" r
WHERE r."isDeleted" = false;

-- 5. Drop Receipt table (cascades to remove FK constraints)
DROP TABLE "Receipt";

COMMIT;
