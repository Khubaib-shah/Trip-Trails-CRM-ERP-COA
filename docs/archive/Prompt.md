# Trip Trails ERP — Complete System Audit, Fix, Refactor and Completion Plan

You are working on an existing Travel CRM/ERP application called **Trip Trails**.

This is an existing production-oriented application with both a frontend and backend already implemented.

Your task is to perform a **complete system audit before making architectural changes or randomly creating new functionality**.

The goal is to take the existing application, understand everything that has already been built, identify incomplete or broken workflows, remove incorrect assumptions, fix architectural issues, and complete the system into a coherent end-to-end Travel Agency CRM + ERP + Accounting platform.

---

# IMPORTANT BUSINESS DECISIONS — READ BEFORE ANALYZING THE CODE

The following business decisions are final requirements.

## 1. This system is specifically for Trails

This is no longer being designed as a generic SaaS product intended to be sold as a multi-tenant white-label application.

Do NOT introduce unnecessary SaaS functionality such as:

- Tenant subscriptions
- Tenant provisioning
- White-label configuration
- Custom tenant domains
- Separate SaaS deployments
- Tenant billing
- Tenant onboarding flows

The system is specifically being built for the Trip Trails travel business.

---

# 2. Multiple Agencies Will Exist

Although this is not a SaaS multi-tenant product, the system must support multiple travel agencies/business entities.

Conceptually:

Trip Trails ERP

→ Agency A

→ Agency B

→ Agency C

Each agency must have its own relevant operational and financial data.

Examples include:

- Users
- Customers
- Leads
- Quotations
- Bookings
- Suppliers
- Payments
- Expenses
- Accounting
- Reports

The system must clearly determine how agency-level data isolation currently works.

Audit the existing architecture and identify whether the project currently uses concepts such as:

- Tenant
- Organization
- Company
- Agency
- Workspace

Do not blindly create a second parallel architecture.

Determine the cleanest migration path.

If the existing Tenant architecture is unnecessarily complex because it was originally built for SaaS multi-tenancy, recommend how to simplify it into an Agency-based structure.

Preferred domain terminology going forward should be:

```text
Agency
```

However, do not rename database models blindly before auditing dependencies and migration impact.

---

# 3. THE BUSINESS MODEL IS HARDCODED AS AGENT-BASED

Trip Trails operates as a **Travel Agent**, not a Principal.

This is a confirmed business requirement.

Do NOT implement Principal vs Agent switching.

Do NOT build a configurable business model selector.

The accounting and financial architecture should be designed specifically around an **Agent-based travel business**.

The system must understand the difference between:

1. Supplier Amount
2. Agency Margin / Commission
3. VAT / Tax
4. Customer Total

Example:

Flight Ticket:

Supplier: Emirates

Supplier Cost: AED 1,000

Selling Price: AED 1,200

Agency Margin:

AED 200

VAT:

5% of Margin = AED 10

Customer Total:

AED 1,210

Conceptually:

```text
Supplier Amount:     AED 1,000

Agency Margin:       AED   200

VAT on Margin:       AED    10

Customer Pays:       AED 1,210
```

The accounting and reporting system must reflect that Trip Trails earns the Agency Margin/Commission.

Do not incorrectly treat the entire customer selling amount as agency revenue.

However, supplier obligations and customer receivables must still be tracked properly.

---

# 4. TAX/VAT MUST BE CONFIGURABLE PER SERVICE

Although Trip Trails is permanently Agent-based, VAT treatment must NOT be globally hardcoded to one formula.

Each booking service may require a different tax treatment.

The system should support appropriate tax configuration and selection per service.

Examples may include:

- VAT on Margin
- VAT on Selling Amount
- Zero Rated
- Exempt
- No VAT

The currently required common case is:

```text
Margin = Selling Price - Supplier Cost

VAT = Margin × VAT Rate

Customer Total = Supplier Cost + Margin + VAT
```

Example:

```text
Supplier Cost = AED 1,000

Selling Price = AED 1,200

Margin = AED 200

VAT = AED 10

Customer Total = AED 1,210
```

Do not rely on frontend-only calculations.

The backend must remain the financial source of truth.

Tax details used for each booking/service must be historically preserved.

---

# PRIMARY SYSTEM GOAL

The final system must support a complete business journey from:

```text
LEAD
  ↓
QUALIFICATION
  ↓
CUSTOMER
  ↓
QUOTATION
  ↓
ACCEPTANCE
  ↓
BOOKING
  ↓
CONFIRMATION / OPERATIONS
  ↓
CUSTOMER PAYMENT
  ↓
SUPPLIER PAYMENT
  ↓
ACCOUNTING
  ↓
FINANCIAL REPORTING
```

But the system must also support direct operational workflows.

---

# REQUIRED ENTRY FLOWS

The system must support all appropriate entry points.

## FLOW A — Lead to Quotation to Booking

```text
Lead
 ↓
Qualification
 ↓
Customer
 ↓
Quotation
 ↓
Quotation Accepted
 ↓
Booking Created
```

---

## FLOW B — Lead to Direct Booking

Sometimes a sales person should be able to create a booking directly without creating a quotation.

```text
Lead
 ↓
Customer / Lead Details
 ↓
Direct Booking
```

The system must determine how the lead/customer relationship should be preserved.

---

## FLOW C — Direct Customer Booking

The user should be able to create a booking directly.

```text
Customer
 ↓
Create Booking
```

No lead or quotation should be mandatory.

---

## FLOW D — Quotation to Booking

A quotation should be convertible into a booking.

The conversion must preserve traceability.

Example:

```text
Lead #LD-100

↓
Quotation #QT-200

↓
Booking #BK-300
```

The booking should retain a reference to the originating quotation where applicable.

Do not require manual re-entry of all quotation services.

---

# IMPORTANT: DO NOT DUPLICATE DATA DURING QUOTATION CONVERSION

Audit the existing quotation and booking architecture.

Determine how quotation items/services are currently stored.

When converting an accepted quotation into a booking:

- Relevant service information should transfer correctly
- Customer information should transfer correctly
- Supplier information should transfer correctly where available
- Selling prices should be preserved
- Cost estimates should be preserved where appropriate
- Tax information should be preserved
- Dates and traveler information should be handled correctly

The system must create independent booking records where operational changes are expected after conversion.

The quotation must remain historically intact.

Do not mutate historical quotation data after it has been accepted/converted.

The booking should maintain a reference such as:

```text
sourceQuotationId
```

or an equivalent traceable relationship.

Audit whether this relationship already exists.

---

# MULTIPLE BOOKING TYPES

Audit all current booking types.

The system currently includes concepts such as:

- Custom Bookings
- Tours
- Other Travel Services

Determine:

- Which booking types currently exist
- Whether their workflows are consistent
- Whether they duplicate each other
- Whether they use separate schemas unnecessarily
- Whether they can share a common booking financial model

The system should support multiple services inside one booking.

Example:

Booking #BK-1001

```text
Flight
Supplier: Emirates
Cost: AED 1,000
Sell: AED 1,200
```

```text
Hotel
Supplier: Hotel Supplier
Cost: AED 2,000
Sell: AED 2,500
```

```text
Safari
Supplier: Safari Supplier
Cost: AED 400
Sell: AED 500
```

Each service must support its own:

- Supplier
- Supplier Cost
- Estimated Cost
- Actual Cost
- Selling Price
- Margin
- Tax Treatment
- Tax Rate
- Tax Amount
- Customer Total
- Service Status

Audit the existing implementation before adding fields.

---

# SUPPLIER MANAGEMENT AND ACCOUNTS PAYABLE

When a booking contains services from suppliers, the system must track financial obligations to suppliers.

Example:

```text
Supplier: Emirates

Booking Service Cost:

AED 1,000
```

The supplier ledger/payables should reflect the obligation according to the correct booking confirmation/financial recognition workflow.

The system must support:

- Supplier Ledger
- Supplier Payables
- Outstanding Balance
- Partial Payments
- Multiple Payments
- Payment Allocations
- Supplier Statements
- AP Aging

---

# CRITICAL SUPPLIER PAYMENT REQUIREMENT

One supplier payment may settle multiple booking services.

Example:

One AED 10,000 bank payment to Emirates could pay:

- Booking A Flight
- Booking B Flight
- Booking C Flight
- Booking D Flight

Therefore:

DO NOT architect supplier payments with only:

```text
supplierPayment.bookingServiceId
```

Instead, use or preserve an allocation architecture.

Conceptually:

```text
Supplier Payment
       │
       ├── Allocation → Supplier Payable A
       ├── Allocation → Supplier Payable B
       └── Allocation → Supplier Payable C
```

Audit whether an allocation model already exists.

If it exists, evaluate whether it is correct and reusable.

---

# CUSTOMER MANAGEMENT AND ACCOUNTS RECEIVABLE

Audit the existing:

- Customers
- Customer Payments
- Invoices
- Customer Ledgers
- Outstanding Balances

The final system should support:

- Customer Receivables
- Customer Invoices
- Partial Payments
- Payment Allocations
- Customer Statements
- Customer Ledger
- Outstanding Balance

One customer payment may potentially settle multiple invoices/bookings.

Avoid forcing a one-payment-to-one-booking relationship.

---

# LEAD MANAGEMENT — COMPLETE AUDIT

Audit the complete lead lifecycle.

Determine:

- How leads are created
- Lead statuses
- Lead sources
- Assignment
- Follow-ups
- Notes
- Conversion to customer
- Conversion to quotation
- Conversion to booking

Identify:

- Broken flows
- Missing relationships
- Duplicate data
- Missing validation
- Missing status transitions
- Orphaned records

The Lead module must work naturally with the Quotation and Booking modules.

---

# QUOTATION MANAGEMENT — COMPLETE AUDIT

Audit the complete quotation workflow.

Determine:

- How quotations are created
- Whether quotations belong to leads or customers
- How quotation services/items are stored
- Whether suppliers can be selected
- Whether estimated costs exist
- Whether selling prices exist
- Whether taxes are calculated correctly
- Whether quotation versions exist
- How approval/acceptance works
- Whether a quotation can be converted to a booking

The final system should support a coherent quotation lifecycle.

Suggested statuses may include:

```text
DRAFT
SENT
VIEWED
REVISED
ACCEPTED
REJECTED
EXPIRED
CONVERTED
```

Do not blindly implement these exact statuses without checking the current domain model.

Determine which statuses are actually appropriate.

---

# BOOKING CREATION — COMPLETE AUDIT AND FIX

This is one of the highest-priority areas.

Audit the entire booking creation flow from frontend to backend.

Check:

## Frontend

- Form structure
- Validation
- State management
- API payload construction
- Supplier selection
- Customer selection
- Service creation
- Pricing calculations
- Tax calculations
- Traveler information
- Date validation
- Currency handling
- Error handling
- Loading states
- Draft handling
- Edit workflow

## Backend

- API validation
- DTO/schema validation
- Authorization
- Agency ownership validation
- Database transactions
- Booking creation
- Service creation
- Supplier relationships
- Traveler creation
- Pricing calculations
- Tax calculations
- Status creation
- Financial records
- Error handling

Identify every bug or inconsistency.

Compare the frontend payload with the backend expected payload.

Fix mismatches.

Do not assume the frontend and backend are synchronized.

---

# DIRECT BOOKING

The system must support creating a booking without:

- Lead
- Quotation

A user should be able to select or create a customer and proceed directly to booking creation.

The booking must still have:

- Customer
- Agency
- Services
- Suppliers where applicable
- Travelers
- Prices
- Dates
- Financial information

Lead and quotation relationships must be optional.

---

# ACCOUNTING SYSTEM

Trip Trails needs a proper accounting layer.

Do NOT implement accounting by manually updating random balances.

Use double-entry accounting principles.

The accounting foundation must include:

## Chart of Accounts

## Journal Entries

## Journal Entry Lines

## General Ledger

## Accounts Receivable

## Accounts Payable

## Tax/VAT Accounts

## Expense Accounts

## Asset Accounts

## Liability Accounts

## Equity / Retained Earnings

Every posted journal entry must satisfy:

```text
Total Debits = Total Credits
```

Posted financial records must be auditable.

Avoid silently editing historical accounting entries.

Use appropriate:

- Reversals
- Adjustments
- Credit notes
- Cancellation/reversal logic

where required.

---

# AGENT-BASED ACCOUNTING MODEL

The accounting architecture must be specifically designed for Trip Trails operating as a travel agent.

The system must clearly distinguish:

```text
Supplier Amount
```

from:

```text
Agency Margin / Commission
```

from:

```text
VAT
```

from:

```text
Customer Total
```

Do not incorrectly inflate revenue by treating all supplier pass-through money as Trip Trails revenue.

The financial architecture must support reliable:

- Margin reporting
- Agency income reporting
- Customer receivables
- Supplier payables
- VAT reporting
- Profit & Loss

---

# EXPENSE MANAGEMENT

Audit the existing expense module completely.

Determine:

- Existing models
- Categories
- Accounts
- Payment tracking
- Approval
- Recurring expenses
- Reporting

Expenses must eventually integrate with accounting.

---

# IMMEDIATE EXPENSE

Example:

Electricity:

AED 500

This should be recognized in the appropriate expense account.

---

# PREPAID EXPENSES — HIGH PRIORITY

The system must support prepaid expenses and accrual-based reporting.

Example:

Trip Trails pays one year of office rent in January.

Annual Rent:

AED 120,000

Period:

January through December

The entire AED 120,000 must NOT appear as January expense.

Instead:

At payment:

The amount should be recorded as a prepaid expense asset.

Then the expense should be recognized over the coverage period.

Example:

```text
AED 120,000 / 12 months

Monthly Rent Expense:

AED 10,000
```

January P&L:

```text
Rent Expense:

AED 10,000
```

Remaining amount:

```text
Prepaid Rent Asset:

AED 110,000
```

The system should support:

- Prepaid Expenses
- Start Date
- End Date
- Recognition Schedule
- Monthly/Periodic Recognition
- Remaining Balance
- Journal Entries
- Reversals/Adjustments where required

Audit the current expense system and determine the best way to integrate this.

---

# ACCRUED EXPENSES

The architecture should support accrued expenses.

Example:

Salary belongs to September but is paid in October.

The system should be architecturally capable of recognizing:

- Expense when incurred
- Liability until paid
- Settlement when payment occurs

Do not unnecessarily implement advanced features before the foundation is correct, but design the accounting model so this can be supported.

---

# TAX / VAT

Audit all existing VAT/tax logic.

Determine:

- Where tax is calculated
- Whether it is frontend-only
- Whether backend recalculates/validates it
- Whether tax history is preserved
- Whether tax rates are hardcoded

The backend must be the source of truth.

Tax treatment should be preserved on the relevant financial transaction.

Do not globally hardcode VAT as 5% of margin for every service.

The business model is Agent-based, but tax treatment can still vary per service.

---

# REQUIRED REPORTS

The final system must support the following reports.

## 1. Margin Report

Filter by:

- Date Range
- Agency
- Booking
- Booking Type
- Service Type
- Supplier
- Customer
- Currency

Show:

- Supplier Cost
- Selling Price
- Agency Margin
- Margin Percentage
- Tax
- Net Margin

---

## 2. Accounts Receivable Aging

Show outstanding customer balances by aging buckets:

- Current
- 1–30 Days
- 31–60 Days
- 61–90 Days
- 90+ Days

---

## 3. Accounts Payable Aging

Show outstanding supplier balances by aging buckets:

- Current
- 1–30 Days
- 31–60 Days
- 61–90 Days
- 90+ Days

---

## 4. VAT Support Report

The report should use actual historical tax treatment and show:

- Transactions
- Tax Treatment
- Tax Base
- Output VAT
- Adjustments
- Net VAT Position

---

## 5. Cost Variance Report

Compare:

```text
Estimated Supplier Cost
```

vs:

```text
Actual Supplier Cost
```

Calculate:

- Cost Variance
- Variance Percentage

---

## 6. Profit & Loss

Calculate:

```text
Agency Revenue / Commission Income

minus

Operating Expenses

plus/minus

Other Income / Expenses

equals

Net Profit
```

The report must respect prepaid expense recognition.

Do not simply use cash payments as expenses for the reporting period.

---

## 7. Balance Sheet

Show:

### Assets

- Cash
- Bank
- Accounts Receivable
- Prepaid Expenses

### Liabilities

- Accounts Payable
- VAT Payable
- Accrued Expenses

### Equity

- Owner Equity
- Retained Earnings

The accounting equation must remain valid.

---

# DATABASE AUDIT

Analyze the complete database schema.

Identify every model related to:

- Agency/Tenant
- Users
- Customers
- Leads
- Quotations
- Bookings
- Booking Services
- Tours
- Suppliers
- Payments
- Payment Allocations
- Expenses
- Ledgers
- Invoices
- Taxes
- Reports

For every relevant model explain:

1. Current purpose
2. Current relationships
3. Whether it is correct
4. Whether it is incomplete
5. Whether it duplicates another model
6. Whether it should be extended
7. Whether it should be deprecated or refactored

Do not generate migrations until the audit and architecture are approved.

---

# FRONTEND AUDIT

Analyze all relevant frontend pages and components.

Specifically inspect:

```text
Dashboard

Agencies

Users

Leads

Customers

Quotations

Bookings

Custom Bookings

Tours

Suppliers

Supplier Ledger

Supplier Payments

Customer Payments

Expenses

Reports

Finance
```

For every module identify:

- Complete functionality
- Missing functionality
- Broken functionality
- API mismatches
- UI inconsistencies
- Validation issues
- Incorrect calculations
- Dead code
- Duplicate components
- Missing loading states
- Missing error handling

Do not redesign working UI unnecessarily.

Fix functionality first.

---

# BACKEND AUDIT

Analyze:

- Routes
- Controllers
- Services
- Database schema
- Validation schemas
- Authorization
- Transactions
- Financial logic
- Error handling

Identify:

- Dead APIs
- Missing APIs
- Duplicate APIs
- Broken relationships
- Inconsistent naming
- Missing authorization
- Data integrity risks
- Race conditions
- Missing database transactions

---

# MONEY AND CURRENCY

Audit how money is currently stored.

Do not use JavaScript floating point numbers as the financial source of truth.

Ensure the architecture supports appropriate decimal precision.

Audit:

- Currency fields
- Exchange rates
- Multi-currency bookings
- Reporting currency

If multi-currency already exists, explain how it works and whether it is sufficient.

Do not randomly redesign currency handling unless necessary.

---

# AGENCY DATA OWNERSHIP AND SECURITY

Since multiple agencies exist inside the system, audit agency ownership.

Every relevant business record should have clear ownership where appropriate.

Examples:

```text
Agency
→ Leads

Agency
→ Customers

Agency
→ Quotations

Agency
→ Bookings

Agency
→ Expenses

Agency
→ Financial Records
```

Users must not accidentally access data belonging to another agency unless their role explicitly allows it.

Audit all current authorization and ownership checks.

---

# CRITICAL DATA INTEGRITY REQUIREMENTS

Identify all operations that must run inside database transactions.

Examples may include:

- Quotation Conversion
- Booking Creation
- Customer Payment Allocation
- Supplier Payment Allocation
- Journal Posting
- Prepaid Expense Recognition

Financial calculations must not depend exclusively on the frontend.

The backend must validate and calculate important financial values.

---

# REQUIRED AUDIT OUTPUT

BEFORE IMPLEMENTING MAJOR NEW FEATURES, provide a detailed report with the following sections.

---

## SECTION 1 — COMPLETE CURRENT SYSTEM OVERVIEW

Explain the existing architecture.

---

## SECTION 2 — MODULE-BY-MODULE STATUS

Create a table:

| Module | Status | Existing Implementation | Problems | Missing Work |
| ------ | ------ | ----------------------- | -------- | ------------ |

Include:

- Agency
- Users
- Leads
- Customers
- Quotations
- Booking Creation
- Booking Management
- Tours
- Suppliers
- Payments
- Expenses
- Accounting
- Reports

Use statuses:

- Complete
- Partially Complete
- Broken
- Missing
- Needs Refactor

---

## SECTION 3 — CURRENT BUSINESS FLOW ANALYSIS

Analyze whether the following flows currently work:

```text
Lead → Customer
```

```text
Lead → Quotation
```

```text
Quotation → Booking
```

```text
Lead → Direct Booking
```

```text
Customer → Direct Booking
```

For each flow explain:

- What works
- What fails
- Missing relationships
- Required fixes

---

## SECTION 4 — DATABASE ARCHITECTURE AUDIT

Document all relevant models and relationships.

---

## SECTION 5 — API AUDIT

Document relevant APIs.

Compare frontend API usage with backend implementations.

Identify mismatches.

---

## SECTION 6 — BOOKING CREATION DEEP AUDIT

This must be extremely detailed.

Trace the entire booking creation process:

```text
Frontend Form

→ Validation

→ Request Payload

→ API

→ Backend Validation

→ Service Logic

→ Database Transaction

→ Booking Creation

→ Service Creation

→ Supplier Relationships

→ Travelers

→ Financial Data
```

Identify every mismatch or issue.

---

## SECTION 7 — FINANCIAL AND ACCOUNTING AUDIT

Identify everything that currently exists regarding:

- Supplier Ledger
- Customer Ledger
- Payments
- Allocations
- Expenses
- Tax
- Profit
- Reports

---

## SECTION 8 — GAP ANALYSIS

Compare the existing system against the final required Trip Trails ERP.

Clearly identify:

### Already Complete

### Can Be Reused

### Needs Fixing

### Needs Refactoring

### Completely Missing

---

## SECTION 9 — RECOMMENDED FINAL ARCHITECTURE

Propose the final architecture.

Do not create duplicate systems.

Reuse correct existing components and models.

---

## SECTION 10 — IMPLEMENTATION ROADMAP

Create a prioritized implementation plan.

Recommended order:

### Phase 0

Complete Audit and Architecture Confirmation

### Phase 1

Fix Agency Architecture and Ownership

### Phase 2

Fix Lead → Quotation → Booking Workflow

### Phase 3

Fix Direct Booking Workflow

### Phase 4

Complete Supplier and Customer Financial Flows

### Phase 5

Accounting Foundation

- Chart of Accounts
- Journal Entries
- Journal Lines
- General Ledger

### Phase 6

Expense Accounting

- Immediate Expenses
- Prepaid Expenses
- Expense Recognition

### Phase 7

VAT and Tax

### Phase 8

Financial Reports

### Phase 9

Data Integrity and Testing

---

# FINAL RULES

1. Do not immediately rewrite the project.
2. Do not create duplicate models.
3. Do not create duplicate APIs.
4. Audit before refactoring.
5. Reuse correct existing architecture.
6. Fix broken flows before adding unnecessary features.
7. Preserve existing production data where possible.
8. Use database transactions for critical workflows.
9. The backend is the source of truth for financial calculations.
10. Trip Trails is permanently Agent-based.
11. Do not build Principal/Agent switching.
12. Multiple Agencies must be supported.
13. This is not a SaaS white-label multi-tenant platform.
14. Booking creation is a high-priority workflow.
15. The complete Lead → Quotation → Booking journey must work.
16. Direct Booking must also work.
17. Quotation conversion must preserve traceability.
18. Accounting must use double-entry principles.
19. Do not manually update a “profit balance”.
20. Profit must be calculated through financial reporting.
21. Financial records must be auditable.
22. Do not trust frontend-only financial calculations.

---

# FIRST RESPONSE REQUIREMENT

Your first response after analyzing the entire codebase must be an **AUDIT REPORT ONLY**.

Do not start implementing major new architecture immediately.

The audit report must clearly explain:

1. Exactly what currently exists.
2. Exactly what works.
3. Exactly what is broken.
4. Exactly what is missing.
5. What can be reused.
6. What should be refactored.
7. The safest implementation order.

After the audit report, wait for approval before performing major refactors.

The goal is to complete Trip Trails into a reliable end-to-end Travel Agency CRM, Booking Management System, ERP, and Accounting platform with complete traceability from Lead → Quotation → Booking → Payments → Accounting → Reports.
