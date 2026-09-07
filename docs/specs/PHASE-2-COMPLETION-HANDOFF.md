# TravelFlow Phase 2 Completion & Phase 3+ Handoff Document

**Project:** TravelFlow ERP System for Travel Agencies  
**Last Updated:** 2026-09-02  
**Phase Completed:** Phase 2 (Lead-to-Booking Conversion with VAT & Multi-Supplier Support)  
**Next Phase:** Phase 3 (Quotations & Advanced Booking Management)

---

## 1. PROJECT OVERVIEW

**TravelFlow** is a comprehensive ERP system designed for travel agencies to manage:
- Lead capture and management
- Customer relationship management (CRM)
- Booking lifecycle and operations
- Quotations and proposals
- Supplier management
- Financial operations (invoices, payments, expenses)
- Reporting and analytics

**Key Principles:**
- Single-agency model (not multi-tenant)
- Role-based access control (admin, owner, agent, finance)
- PostgreSQL with Prisma ORM for data persistence
- Real-time notifications
- RLS (Row-Level Security) at database level for additional security

---

## 2. TECHNOLOGY STACK

### Frontend
- **Framework:** Next.js 16.2.9 with React 19.2.4
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **UI Components:** shadcn/ui (NOT custom components)
- **Forms:** React Hook Form + Zod validation
- **State Management:** Zustand (auth, invalidation stores)
- **HTTP Client:** Custom API client with fetch + axios
- **Package Manager:** npm

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** PostgreSQL (via Docker on localhost:5433)
- **ORM:** Prisma 5.14.0
- **Authentication:** JWT with HttpOnly cookies
- **Validation:** Zod schemas
- **Environment:** Nodemon for dev, ts-node for TypeScript

### Database
- **Type:** PostgreSQL
- **Location:** Docker container (localhost:5433)
- **Database Name:** travelflow_db
- **Default User:** postgres / postgres
- **RLS Enabled:** Yes (critical for multi-branch security)
- **Seeding:** Realistic TripTrails agency demo data

---

## 3. PROJECT STRUCTURE

```
travelflow/
├── travelflow-backend/                 # Express API server
│   ├── src/
│   │   ├── app.ts                     # Express app setup
│   │   ├── server.ts                  # Server entry point
│   │   ├── config/                    # Configuration files
│   │   ├── controllers/               # Route handlers
│   │   │   ├── domain.controller.ts  # Bookings, leads, quotes
│   │   │   ├── customer.controller.ts
│   │   │   ├── supplier.controller.ts
│   │   │   └── ...
│   │   ├── services/                  # Business logic
│   │   │   ├── domain.service.ts     # Core booking/lead logic (UPDATED IN PHASE 2)
│   │   │   ├── quotation.service.ts  # Quotation logic
│   │   │   ├── customer.service.ts
│   │   │   └── ...
│   │   ├── validators/
│   │   │   └── schemas.ts             # Zod validation schemas (UPDATED IN PHASE 2)
│   │   ├── lib/                       # Utility functions
│   │   ├── middleware/                # Auth, error handling, validation
│   │   ├── models/                    # Type definitions
│   │   ├── routes/                    # API routes
│   │   └── types/                     # TypeScript types
│   ├── prisma/
│   │   ├── schema.prisma              # Database schema (WITH customerId on Lead model)
│   │   ├── seed.ts                    # Database seeding
│   │   └── migrations/                # Schema migrations
│   ├── package.json
│   └── tsconfig.json
│
├── travelflow-frontend/               # Next.js 16 frontend
│   ├── app/
│   │   ├── layout.tsx                 # Root layout
│   │   ├── page.tsx                   # Home page
│   │   ├── (auth)/                    # Auth routes
│   │   ├── (dashboard)/               # Protected routes
│   │   └── ...
│   ├── components/
│   │   ├── leads/
│   │   │   └── ConvertToBookingDrawer.tsx  # UPDATED IN PHASE 2 - Multi-supplier form
│   │   ├── bookings/
│   │   ├── quotations/
│   │   ├── forms/                     # Reusable form components
│   │   ├── layout/                    # Navigation, sidebars
│   │   ├── tables/                    # Data tables
│   │   └── ui/                        # shadcn/ui wrapper components
│   ├── features/                      # Feature-specific logic
│   │   ├── leads/
│   │   ├── bookings/
│   │   ├── quotations/
│   │   ├── customers/
│   │   ├── suppliers/
│   │   └── shared/
│   ├── hooks/                         # Custom React hooks
│   ├── lib/
│   │   ├── api-client.ts              # API client definitions (UPDATED IN PHASE 2)
│   │   ├── data-source.ts             # Mock data & API gateway
│   │   ├── query-keys.ts              # React Query key factory
│   │   └── ...
│   ├── providers/                     # Context providers (Auth, Theme, etc.)
│   ├── public/                        # Static assets
│   ├── store/                         # Zustand stores
│   ├── types/                         # TypeScript types & interfaces
│   ├── package.json
│   └── next.config.ts
│
├── prisma/schema.prisma               # Database schema (SHARED VIEW)
├── PHASE-2-COMPLETION-HANDOFF.md      # THIS FILE
├── CLAUDE_PROJECT_CONTEXT.md          # Project background
├── QA-TEST-PLAN.md                    # Testing strategy
└── README.md
```

---

## 4. PHASE 2 COMPLETION SUMMARY

### Objective
Enable users to convert leads to bookings with full operational detail capture, including:
- Passenger count editing
- Multiple supplier selection per booking
- Automatic VAT calculation based on margin
- Supplier pricing and cost details

### Key Changes Implemented

#### 4.1 Frontend: ConvertToBookingDrawer Component
**File:** `travelflow-frontend/components/leads/ConvertToBookingDrawer.tsx`

**Changes:**
- ✅ Converted from 1-step to 3-step form:
  - **Step 1:** Lead summary display (name, phone, destination, passenger counts)
  - **Step 2:** Booking details (title, dates, passenger editing, notes)
  - **Step 3:** Multiple supplier services with VAT calculations
- ✅ Added `useFieldArray` from React Hook Form for dynamic supplier/service addition
- ✅ Implemented "Add Another Supplier" button to add multiple service lines
- ✅ **REMOVED** manual VAT Amount field - now auto-calculated
- ✅ Added real-time VAT calculation breakdown component showing:
  - Supplier Cost
  - Selling Price
  - Margin
  - **VAT on Margin (%):** Auto-calculated from margin × VAT rate
  - **Customer Pays:** Selling Price + VAT Amount
- ✅ Each service line includes:
  - Service category (Flight, Hotel, Transfer, etc.)
  - Title, description
  - Supplier dropdown (from suppliers hook) or manual override
  - Cost Price & Selling Price
  - VAT Rate (%) input
  - Quantity, unit, status fields
- ✅ Delete button for service lines (disabled if only 1 service remains)

**Key Functions:**
```typescript
VatCalculationBreakdown()        // Shows real-time VAT math
ServiceRow()                     // Individual supplier/service line component
ConvertToBookingDrawer()         // Main multi-step form
```

**Validation Schema:**
```typescript
bookingServiceSchema = z.object({
  serviceCategory, title, description
  supplierId (optional)
  supplierName (optional)
  costPrice, sellingPrice
  vatRate (0-100%)
  // NOTE: vatAmount REMOVED - calculated server-side
  quantity, unit, status
})
```

#### 4.2 Backend: Auto-Calculate VAT on Create/Update
**File:** `travelflow-backend/src/services/domain.service.ts`

**Changes in `convertLead()` function:**
```typescript
// Calculate VAT amount automatically
const costPrice = Number(svc.costPrice) || 0;
const sellingPrice = Number(svc.sellingPrice) || 0;
const margin = Math.max(0, sellingPrice - costPrice);
const vatRate = Number(svc.vatRate) || 0;
const vatAmount = margin > 0 ? (margin * vatRate) / 100 : 0;

// Store in serviceDetails JSON
const serviceDetails = {
  ...existing,
  ...(svc.supplierName ? { supplierName: svc.supplierName } : {}),
  ...(vatRate > 0 ? { vatRate: vatRate } : {}),
  ...(vatAmount > 0 ? { vatAmount: vatAmount } : {}),
};
```

**Changes in `createBooking()` function:**
- Same VAT auto-calculation logic applied

**Changes in `updateBooking()` function:**
- Same VAT auto-calculation logic applied

**Key Improvements:**
- ✅ Empty supplierId strings converted to null
- ✅ All numeric fields coerced to numbers
- ✅ Null-safe handling for VAT fields
- ✅ serviceDetails JSON field used for backward compatibility (no schema migration needed)

#### 4.3 Backend: Schema Validation Updates
**File:** `travelflow-backend/src/validators/schemas.ts`

**Changes:**
- ✅ **REMOVED** `vatAmount` from bookingSchema services array
- ✅ Kept `vatRate` as optional number (0-100)
- ✅ Updated `convertLeadSchema` to omit customerId

```typescript
// BEFORE: had vatAmount field
// AFTER: vatAmount removed, calculated server-side
z.object({
  serviceCategory, title, description,
  supplierId, supplierName,
  costPrice, sellingPrice,
  vatRate: z.number().min(0).max(100).optional(),
  // vatAmount REMOVED
  quantity, unit, status
})
```

#### 4.4 Frontend: API Client & Types
**File:** `travelflow-frontend/lib/api-client.ts`

**Changes:**
- ✅ Removed `vatAmount` from `CreateBookingInput.services` array
- ✅ Updated interface to reflect server-side calculation

```typescript
export interface CreateBookingInput {
  // ...
  services?: Array<{
    serviceCategory, title, description,
    supplierId, supplierName,
    costPrice, sellingPrice,
    vatRate,  // KEPT
    // vatAmount REMOVED
    quantity, unit, status
  }>;
}
```

#### 4.5 Frontend: Booking Schema
**File:** `travelflow-frontend/features/bookings/schemas/booking.schema.ts`

**Changes:**
- ✅ Removed `vatAmount` from bookingServiceSchema
- ✅ Kept `vatRate` for display/editing

---

## 5. CURRENT SYSTEM STATE

### Lead Model (Now has customerId)
```prisma
model Lead {
  id              String    @id @default(uuid()) @db.Uuid
  agencyId        String    @db.Uuid
  branchId        String    @db.Uuid
  leadRef         String    // Unique reference
  name, phone, email, destination
  travelDate, budget
  adults, children
  specialRequirements, source, status
  assignedAgentId String?   @db.Uuid
  customerId      String?   @db.Uuid  // ADDED: links to customer
  notes, lastContactedAt
  isDeleted, deletedAt
  createdAt, updatedAt
  // Relations
  agency, branch, assignedAgent
  customer, activities, bookings, quotations
}
```

### Booking Model (Unchanged, ready for multi-supplier)
```prisma
model Booking {
  id              String    @id @default(uuid()) @db.Uuid
  agencyId, branchId
  bookingRef      String    // Unique reference
  customerId      String    @db.Uuid
  agentId         String    @db.Uuid
  leadId          String?   @db.Uuid  // Link to source lead
  sourceType      String    // "manual", "lead", "quotation"
  title, departureDate, returnDate
  expectedAdults, expectedChildren, expectedInfants
  bookingStatus, paymentStatus
  notes
  isDeleted, deletedAt
  createdAt, updatedAt
  // Relations
  services[]      BookingService[]  // Multiple suppliers
  activities[], documents[], travelers[]
}
```

### BookingService Model (Supports multi-supplier with VAT in JSON)
```prisma
model BookingService {
  id              String    @id @default(uuid()) @db.Uuid
  agencyId, bookingId
  serviceCategory String    // "flight", "hotel", "transfer", etc.
  title, description
  supplierId      String?   @db.Uuid  // Optional supplier link
  costPrice, sellingPrice
  quantity, unit, status
  serviceDetails  Json?     // STORES: {supplierName, vatRate, vatAmount}
  sortOrder       Int
  // Relations
  booking, supplier
}
```

---

## 6. RUNNING THE PROJECT

### Prerequisites
- Node.js 18+ and npm
- Docker with PostgreSQL container running on localhost:5433
- Git

### Database Setup
```bash
# Start PostgreSQL container (if not running)
docker-compose -f compose.yml up -d

# Run migrations
cd travelflow-backend
npx prisma migrate dev

# Seed demo data (TripTrails agency)
npx prisma db seed
```

### Backend
```bash
cd travelflow-backend
npm install
npm run dev
# Server runs on http://localhost:5000/api/v1
```

### Frontend
```bash
cd travelflow-frontend
npm install
npm run dev
# App runs on http://localhost:3000
```

### Test the Lead Conversion
1. Go to http://localhost:3000
2. Login (use seeded credentials from TripTrails demo data)
3. Navigate to **Leads** section
4. Click **"Convert to Booking"** on any lead
5. Follow 3-step form:
   - **Step 1:** Review lead info
   - **Step 2:** Edit passenger counts and dates
   - **Step 3:** Add suppliers and configure VAT rates
6. Click "+ Add Another Supplier" to add multiple supplier lines
7. Observe real-time VAT calculation
8. Submit to create booking

---

## 7. CRITICAL KNOWN ISSUES & BLOCKERS

### ✅ RESOLVED (Phase 2)
- ~~500 Internal Server Error on lead conversion~~ → Fixed via Prisma client regeneration
- ~~Redundant VAT Amount field~~ → Removed, now auto-calculated
- ~~Single supplier only~~ → Now supports multiple suppliers
- ~~Manual VAT calculation required~~ → Automatic based on margin

### ⚠️ TO MONITOR
1. **Prisma Client Generation**: If schema changes, must regenerate:
   ```bash
   npx prisma generate
   ```
2. **TypeScript Compilation**: Both apps must compile before deployment
3. **RLS Policies**: Database RLS enabled - ensure all queries include agencyId filter
4. **Phone Number Validation**: Uses regex pattern, may need refinement for international formats

---

## 8. COMMON PATTERNS & CONVENTIONS

### 1. Service Functions Pattern
```typescript
// In src/services/domain.service.ts
export async function createBooking(
  ctx: TenantContext,           // {agencyId, branchId, userId}
  values: BookingInput,          // Validated data from Zod
  userId: string,                // Actor ID
  actor: string,                 // Actor description
) {
  // Business logic here
  return enrichBooking(booking, ctx);  // Enrich with relations
}
```

### 2. Validation Pattern
```typescript
// In controllers
const validated = await validate(values, bookingSchema);
const result = await domainService.createBooking(ctx, validated, userId, actor);
```

### 3. API Response Pattern
```typescript
// Always include: success, message, code, timestamp
{
  success: true,
  message: "Booking created successfully",
  code: "SUCCESS",
  timestamp: "2026-09-02T10:30:00Z",
  data: { booking }
}
```

### 4. Frontend Form Pattern
```typescript
// 1. Define Zod schema
const schema = z.object({...});
type FormValues = z.infer<typeof schema>;

// 2. Create form with React Hook Form
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onChange"
});

// 3. Use FormField components from shadcn
<FormField control={form.control} name="field" label="Label" />

// 4. Submit with error handling
async function onSubmit(data: FormValues) {
  try {
    await API.endpoint(data);
    showSuccess("Success message");
    router.refresh();
  } catch (error) {
    showError("Error title", error.message);
  }
}
```

### 5. Multi-Field Array Pattern (Used in Phase 2)
```typescript
import { useFieldArray, useWatch } from "react-hook-form";

const { fields, append, remove } = useFieldArray({
  control: form.control,
  name: "services"  // Array field name
});

// Render
{fields.map((field, index) => (
  <ServiceRow
    index={index}
    onRemove={() => remove(index)}
    canRemove={fields.length > 1}
  />
))}

// Add
<button onClick={() => append(defaultService)}>
  Add Service
</button>
```

### 6. Component Extraction Rule
- If a pattern appears **> 3 times** → Extract to reusable component
- Place under `/components` (not `/components/ui`)
- Compose from shadcn primitives, don't rebuild from scratch

---

## 9. IMPORTANT API ENDPOINTS

### Leads
- `POST /api/v1/leads` - Create lead
- `GET /api/v1/leads` - List leads (with filters, pagination)
- `GET /api/v1/leads/:id` - Get single lead
- `PUT /api/v1/leads/:id` - Update lead
- `POST /api/v1/leads/:id/convert` - **UPDATED IN PHASE 2** Convert to booking

### Bookings
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings` - List bookings
- `GET /api/v1/bookings/:id` - Get single booking
- `PUT /api/v1/bookings/:id` - Update booking
- `DELETE /api/v1/bookings/:id` - Soft delete booking

### Suppliers
- `GET /api/v1/suppliers` - List suppliers (used in form dropdowns)
- `POST /api/v1/suppliers` - Create supplier
- `PUT /api/v1/suppliers/:id` - Update supplier

---

## 10. PHASE 3+ ROADMAP

### Phase 3: Quotations & Advanced Booking Management
**Estimated Duration:** 2-3 weeks

**Objectives:**
1. Create quotation workflow from lead or manual
2. Convert quotation to booking
3. Quotation versioning and history
4. Multi-currency support for quotations
5. Bulk quotation generation

**Key Files to Create/Update:**
- `travelflow-frontend/components/quotations/CreateQuotationForm.tsx`
- `travelflow-backend/src/services/quotation.service.ts` (enhance)
- `travelflow-frontend/features/quotations/` (full feature module)

**Database Changes:**
- Enhance `Quotation` model with version tracking
- Add `QuotationVersion`, `QuotationTax` models (already exist)
- Implement soft-delete for quotation history

---

### Phase 4: Financial Management & Invoicing
**Estimated Duration:** 3-4 weeks

**Objectives:**
1. Create invoices from bookings
2. Payment tracking and allocation
3. Credit notes for refunds
4. Payment schedule management
5. Financial reports (P&L, cash flow)

**Key Files:**
- `travelflow-backend/src/services/invoice.service.ts`
- `travelflow-backend/src/services/payment.service.ts`
- Chartof Accounts and Journal Entry management

---

### Phase 5: Supplier Management & Commission
**Estimated Duration:** 2 weeks

**Objectives:**
1. Supplier commission calculation
2. Supplier payment tracking
3. Bulk supplier payments
4. Supplier performance metrics

---

### Phase 6: Reporting & Analytics
**Estimated Duration:** 2-3 weeks

**Objectives:**
1. Dashboard with KPIs
2. Custom report builder
3. Export functionality (PDF, Excel)
4. Financial reports

---

## 11. DEBUGGING TIPS

### 500 Errors
1. Check backend terminal for stack trace
2. Verify Prisma client is regenerated: `npx prisma generate`
3. Check Zod validation schema matches request body
4. Verify agencyId is properly set in context

### TypeScript Errors
```bash
# Frontend
cd travelflow-frontend
npx tsc --noEmit

# Backend
cd travelflow-backend
npx tsc --noEmit
```

### Database Issues
```bash
# Reset database (WARNING: Deletes all data)
npx prisma migrate reset

# View database
npx prisma studio
```

### Port Already in Use
```bash
# Kill processes on ports 3000 and 5000
Get-Process -Name node | Stop-Process -Force
```

---

## 12. KEY CONTACTS & DOCUMENTATION

**Project Owner:** Khubaib-shah  
**Repository:** https://github.com/Khubaib-shah/TravelFlow  
**Current Branch:** main

**Important Files for Onboarding:**
- [CLAUDE_PROJECT_CONTEXT.md](./CLAUDE_PROJECT_CONTEXT.md) - Project background
- [QA-TEST-PLAN.md](./QA-TEST-PLAN.md) - Testing strategy
- [UI-UX-DESIGN-SYSTEM-BLUEPRINT.md](./UI-UX-DESIGN-SYSTEM-BLUEPRINT.md) - Design guidelines
- [MONGODB-POSTGRESQL-MIGRATION-GUIDELINE.md](./MONGODB-POSTGRESQL-MIGRATION-GUIDELINE.md) - Schema migration notes

---

## 13. NEXT DEVELOPER CHECKLIST

### Before Starting Phase 3:
- [ ] Clone repository
- [ ] Install dependencies (both apps)
- [ ] Start Docker PostgreSQL container
- [ ] Run `npx prisma migrate dev` in backend
- [ ] Run `npx prisma db seed` to load demo data
- [ ] Start backend: `npm run dev` in backend folder
- [ ] Start frontend: `npm run dev` in frontend folder
- [ ] Test lead conversion flow end-to-end
- [ ] Review Phase 2 changes in:
  - `ConvertToBookingDrawer.tsx`
  - `domain.service.ts`
  - `schemas.ts`
  - `api-client.ts`
- [ ] Understand VAT calculation logic (margin × rate / 100)
- [ ] Understand multi-supplier pattern using `useFieldArray`
- [ ] Read through PHASE-2-COMPLETION-HANDOFF.md (this file) thoroughly

### Common Setup Issues:
- If npm install fails: `npm cache clean --force` then retry
- If Prisma errors: `npx prisma generate`
- If types missing: Ensure TypeScript compiles for both apps
- If API calls fail: Verify backend is running on localhost:5000

---

**Document Version:** 1.0  
**Last Updated:** September 2, 2026  
**Status:** COMPLETE & READY FOR PHASE 3 HANDOFF

