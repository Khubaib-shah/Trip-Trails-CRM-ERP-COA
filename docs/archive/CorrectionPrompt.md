# Trip Trails ERP — Architecture Review and Phase 1 Implementation Instructions

The audit report has been reviewed.

Before implementation begins, the following architecture decisions are confirmed and must override any simplified assumptions made during the audit.

Do not rebuild the existing system.

The project already has a substantial foundation and the goal is to extend and correct the existing architecture.

---

# 1. AGENCY ARCHITECTURE IS CONFIRMED

Trip Trails ERP is not a SaaS white-label product.

Do NOT introduce:

- SaaS subscriptions
- Tenant billing
- White-label provisioning
- Custom tenant domains
- Tenant onboarding
- Separate tenant deployments

However, multiple Agencies exist inside the system.

The structure is:

```text
Trip Trails ERP

Agency
 ├── Branches
 ├── Users
 ├── Customers
 ├── Leads
 ├── Quotations
 ├── Bookings
 ├── Suppliers
 ├── Expenses
 └── Accounting
```

Agency remains the primary ownership and financial boundary.

All cross-agency access must be prevented unless explicitly authorized.

Do not replace the existing healthy Agency architecture.

Only simplify legacy naming or helper logic that incorrectly reflects the previous SaaS/tenant architecture.

---

# 2. TRIP TRAILS IS PERMANENTLY AGENT-BASED

This is a hard business rule.

Do NOT implement:

- Principal mode
- Agent/Principal switching
- Configurable business models

The system is designed specifically for an Agent-based travel business.

However, tax treatment must remain configurable per service.

---

# 3. OPERATIONAL FINANCIAL DATA VS ACCOUNTING DATA

Do not treat BookingService fields and Journal Entries as the same thing.

There are two layers.

## Operational Layer

BookingService stores commercial and operational facts:

```text
Supplier
Estimated Supplier Cost
Actual Supplier Cost
Selling Price
Quantity
Tax Treatment Snapshot
Tax Rate Snapshot
Service Status
```

## Accounting Layer

Journal Entries represent posted financial events.

Do not create journal entries simply because someone creates or edits a draft booking.

Accounting entries should be created only when a defined financial posting event occurs.

---

# 4. MARGIN MUST NOT BE AN INDEPENDENT EDITABLE VALUE

Do not allow users to independently edit:

```text
Supplier Cost
Selling Price
Margin
```

because this creates inconsistent financial data.

The source values should be:

```text
Estimated Supplier Cost
Actual Supplier Cost
Selling Price
```

The backend calculates:

```text
Expected Margin

Actual Margin

Cost Variance
```

Example:

```text
Estimated Cost = 1,000
Actual Cost = 1,100
Selling Price = 1,300

Expected Margin = 300
Actual Margin = 200

Cost Variance = 100
```

If calculated values are persisted as snapshots for historical reporting or performance, they must be backend-generated and not independently editable.

---

# 5. ESTIMATED COST VS ACTUAL COST

The meaning must be explicitly separated.

## Estimated Supplier Cost

The expected supplier amount during quotation/planning.

## Actual Supplier Cost

The actual confirmed amount owed to the supplier.

Example:

During quotation:

```text
Estimated Cost = AED 2,000
Selling Price = AED 2,500
Expected Margin = AED 500
```

Later:

```text
Actual Cost = AED 2,200
Selling Price = AED 2,500
Actual Margin = AED 300
```

This difference must power the Cost Variance Report.

---

# 6. AGENT-BASED FINANCIAL MODEL

Example:

```text
Supplier Cost = AED 1,000

Selling Price Before VAT = AED 1,200

Agency Margin = AED 200

VAT = AED 10

Customer Total = AED 1,210
```

The system must distinguish:

```text
Supplier Obligation = AED 1,000

Agency Revenue / Margin = AED 200

VAT Liability = AED 10

Customer Receivable = AED 1,210
```

Do NOT automatically record:

```text
Revenue = AED 1,200
Expense = AED 1,000
```

because that incorrectly represents the business as a principal/gross seller.

The supplier amount must be treated according to the Agent-based pass-through architecture.

---

# 7. AP AND AR MUST USE OPEN ITEMS

Do not architect financial settlement as:

```text
Payment → Booking
```

A booking is an operational record.

Instead, create or standardize explicit financial open items.

Conceptually:

```text
Booking Service
       │
       ├── Customer Receivable
       │
       └── Supplier Payable
```

Then:

```text
Customer Payment
       │
       └── Payment Allocation
               │
               ▼
       Customer Receivable
```

And:

```text
Supplier Payment
       │
       └── Payment Allocation
               │
               ▼
        Supplier Payable
```

One payment must be capable of allocating to multiple open items.

Example:

```text
AED 10,000 Supplier Payment

├── AED 3,000 → Payable A
├── AED 2,500 → Payable B
├── AED 1,500 → Payable C
└── AED 3,000 → Payable D
```

Likewise, one customer payment may settle multiple customer receivables.

Do not create one-payment-to-one-booking restrictions.

---

# 8. QUOTATION → BOOKING TRACEABILITY

Add formal source traceability.

A quotation-based booking must preserve:

```text
sourceQuotationId
```

or an equivalent formal relationship.

The quotation must remain historically intact after conversion.

Do not mutate historical quotation items when booking services later change.

The Booking must become operationally independent while maintaining traceability.

---

# 9. LEAD → CUSTOMER → QUOTATION → BOOKING TRACEABILITY

The system must preserve the origin of business.

Supported flows:

```text
Lead → Customer → Quotation → Booking
```

```text
Lead → Direct Booking
```

```text
Customer → Direct Booking
```

```text
Customer → Quotation → Booking
```

Direct bookings must not require a Lead or Quotation.

Lead and quotation references should be optional where appropriate.

However, if a booking originates from one, the source relationship must be preserved.

---

# 10. BOOKING CREATION MUST BE ATOMIC

The audit identified a critical issue:

Booking creation and BookingService creation are currently not fully transactional.

This must be fixed.

The following operations must use a database transaction where appropriate:

```text
Create Booking
Create Booking Services
Create Travelers
Create Financial Source Records
Create Activities
Create Related Notifications
```

The exact scope should be designed carefully.

A failure must not leave a partially created booking.

---

# 11. BACKEND IS THE FINANCIAL SOURCE OF TRUTH

The frontend may calculate values for UI preview.

However, the backend must validate and calculate:

```text
Estimated Cost
Actual Cost
Selling Price
Expected Margin
Actual Margin
Tax Base
Tax Amount
Customer Total
```

Do not trust frontend financial calculations.

Use appropriate decimal precision.

Do not use JavaScript floating point arithmetic as the financial source of truth.

---

# 12. TAX MUST BE A HISTORICAL SERVICE SNAPSHOT

Tax treatment must be stored with the service/financial transaction.

Do not rely only on a current global tax configuration.

A historical booking service should preserve:

```text
Tax Treatment

Tax Rate

Tax Base

Tax Amount

Tax Calculation Method
```

Supported treatments may include:

```text
VAT_ON_MARGIN
VAT_ON_SELLING_PRICE
ZERO_RATED
EXEMPT
NO_VAT
```

The backend must calculate according to the selected treatment.

Do not assume every service uses 5%.

---

# 13. ACCOUNTING POSTING EVENTS

Before implementing journal logic, define explicit financial posting events.

Do not post accounting entries for every draft edit.

Potential lifecycle:

```text
DRAFT

→ CONFIRMED

→ FINANCIALLY POSTED

→ PARTIALLY SETTLED

→ SETTLED

→ CANCELLED
```

Do not blindly use these exact statuses if existing domain statuses are already better.

Instead, audit the current lifecycle and define a consistent state model.

The key requirement:

**Operational editing and accounting posting must be separated.**

---

# 14. EXPENSE ACCOUNTING

The existing Expense model should be extended rather than duplicated.

Support:

## Immediate Expense

Expense is recognized immediately.

## Prepaid Expense

Example:

```text
Annual Rent Paid in January

AED 120,000

Coverage:

January → December
```

At payment:

```text
Prepaid Expense Asset = AED 120,000
```

Each month:

```text
Rent Expense = AED 10,000
```

The remaining amount stays as a Prepaid Expense Asset.

The architecture should support:

```text
Expense

Expense Recognition Schedule

Recognition Entries
```

Do not create a separate disconnected expense system.

---

# 15. IMPLEMENTATION ORDER

Proceed in this order.

## PHASE 1 — DATA INTEGRITY AND OWNERSHIP

- Agency ownership validation
- Cross-agency relationship validation
- Simplify legacy tenant terminology
- Transaction boundaries

## PHASE 2 — LEAD / QUOTATION / BOOKING INTEGRITY

- Lead conversion traceability
- Customer linkage
- Quotation lifecycle
- sourceQuotationId
- Quotation conversion
- Direct booking integrity

## PHASE 3 — SERVICE FINANCIAL MODEL

Implement:

```text
Estimated Supplier Cost
Actual Supplier Cost
Selling Price
Tax Treatment Snapshot
Tax Rate Snapshot
Tax Base
Tax Amount
Customer Total
Service Financial Status
```

Backend-derived:

```text
Expected Margin
Actual Margin
Cost Variance
```

## PHASE 4 — AP/AR OPEN ITEMS AND ALLOCATIONS

- Customer Receivables
- Supplier Payables
- Open balances
- Payment allocations
- Partial payments
- Multi-item settlement

## PHASE 5 — ACCOUNTING POSTING MODEL

- Posting events
- Journal rules
- Revenue recognition
- VAT liability
- Payment settlement
- General ledger

## PHASE 6 — EXPENSE RECOGNITION

- Immediate expenses
- Prepaid expenses
- Recognition schedules
- Accrual-ready architecture

## PHASE 7 — REPORTING

- Margin Report
- Cost Variance
- AR Aging
- AP Aging
- VAT Support
- P&L
- Balance Sheet

## PHASE 8 — TESTING AND RECONCILIATION

Add tests for:

```text
Lead → Quotation → Booking
```

```text
Direct Booking
```

```text
Quotation → Booking
```

```text
Customer Payment → Multiple Receivables
```

```text
Supplier Payment → Multiple Payables
```

```text
Prepaid Expense Recognition
```

```text
Accounting Debits = Credits
```

---

# CURRENT IMPLEMENTATION TASK

Do not implement all phases at once.

Start with:

## Phase 1 — Data Integrity and Ownership

and

## Phase 2 — Lead / Quotation / Booking Integrity

Before modifying the database:

1. List every schema change required.
2. List every existing model affected.
3. List migration risks.
4. Identify existing data compatibility issues.
5. Explain how existing APIs and frontend components will be affected.

Then provide the implementation plan for approval.

Do not perform destructive migrations.

Do not remove existing models without proving they are unused.

Preserve working functionality while correcting broken architecture.
