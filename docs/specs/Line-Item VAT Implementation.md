# Line-Item VAT Implementation Plan

## Overview
Currently, the Quotation system applies a "Global Tax" at the bottom of the form. While this works for domestic trips, international travel accounting requires tax rules based on the "Place of Supply." Services provided internationally are often zero-rated or out-of-scope, while local services are standard-rated (e.g., 5% VAT in UAE).

To support this, we need to migrate from a global quotation tax model to a **per-service line-item VAT model**. This document outlines the technical steps required to build this feature when needed.

---

## 1. Database Schema Updates (`schema.prisma`)
The `BookingService` model already supports per-item VAT. We need to mirror this capability in the `QuotationItem` model.

**Changes required in `QuotationItem`:**
```prisma
  // Add these fields to QuotationItem
  taxTreatment  String  @default("VAT_ON_MARGIN") // VAT_ON_MARGIN, ZERO_RATED, EXEMPT, etc.
  vatRate       Float   @default(0)               // e.g., 5 for 5%
  taxBase       Float   @default(0)               // Calculated: (sellingPrice - costPrice)
  taxAmount     Float   @default(0)               // Calculated: taxBase * (vatRate / 100)
```
*Note: The global `QuotationTax` model can be deprecated or kept only for generic flat fees.*

---

## 2. Shared Types (`types/quotation.ts`)
Update the TypeScript interfaces to match the new schema.

**Changes required in `QuotationItem` Interface:**
```typescript
export interface QuotationItem {
  // ... existing fields ...
  taxTreatment: string;
  vatRate: number;
  taxBase: number;
  taxAmount: number;
}
```

---

## 3. Frontend UI (`QuotationForm.tsx`)
The largest changes will be in the form UI and the real-time calculation logic.

### A. Update the Schema (`quotation.schema.ts`)
Add the new fields to the Zod validation schema for items:
```typescript
const quotationItemSchema = z.object({
  // ... existing fields ...
  taxTreatment: z.string().default("VAT_ON_MARGIN"),
  vatRate: z.coerce.number().min(0).default(0),
});
```

### B. Update the Items Data Table
In the `QuotationForm` item builder:
1. Add a dropdown for **Tax Treatment** (VAT on Margin, Zero Rated).
2. Add a number input for **VAT Rate %** (defaulting to 5 or 0 depending on treatment).
3. Display a read-only column for the **Tax Amount** calculated for that specific line.

### C. Update Total Calculations
Modify the `calcTotals` function to sum the tax from individual items rather than from a global taxes array.
```typescript
function calcTotals(items: QuotationItem[]) {
  let subtotal = 0;
  let totalCost = 0;
  let taxAmount = 0;

  items.forEach((it) => {
    const qty = it.quantity || 1;
    const sell = it.sellingPrice || 0;
    const cost = it.costPrice || 0;
    const margin = sell - cost;
    
    subtotal += qty * sell;
    totalCost += qty * cost;

    // Line item tax calculation
    const rate = it.vatRate || 0;
    taxAmount += qty * (margin * (rate / 100));
  });

  return { subtotal, estimatedProfit: subtotal - totalCost, taxAmount };
}
```

---

## 4. Backend API & Conversion Logic
Ensure the backend safely processes and passes the new line-item fields.

### A. `createQuotation` / `updateQuotation`
Ensure the new `taxTreatment`, `vatRate`, `taxBase`, and `taxAmount` fields are accepted in the payload and saved to the `QuotationItem` table.

### B. `convertQuotationToBooking`
Update the conversion logic to map the quotation item's specific tax fields directly into the booking service.

**Remove the hardcoded fallback:**
```typescript
// OLD:
const taxTreatment: TaxTreatment = "VAT_ON_MARGIN";
const vatRate = (quotation.taxes || []).reduce(...);

// NEW:
const taxTreatment = item.taxTreatment as TaxTreatment || "VAT_ON_MARGIN";
const vatRate = item.vatRate || 0;
```

---

## Summary of Impact
- **Pros:** Full compliance with complex international tax laws. Perfect mapping from Quotation to Booking without data loss.
- **Cons:** Slightly heavier UI for agents when building quotes (they must consider tax for every line item).
