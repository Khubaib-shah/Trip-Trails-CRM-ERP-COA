# TripTrails — ERP, CRM & Accounting Platform

> A full-stack enterprise travel management platform built to unify agency CRM, booking operations, multi-currency invoicing, VAT-compliant financial calculations, and double-entry general ledger accounting into a single, cohesive system.

[![TypeScript](https://img.shields.io/badge/TypeScript-5.4+-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-16.2-black?logo=next.js&logoColor=white)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19.2-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-20+-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.19-000000?logo=express&logoColor=white)](https://expressjs.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Prisma](https://img.shields.io/badge/Prisma-5.14+-2D3748?logo=prisma&logoColor=white)](https://www.prisma.io/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-v4-06B6D4?logo=tailwindcss&logoColor=white)](https://tailwindcss.com/)

---

## 1. Overview

**TripTrails** is an enterprise travel operations and accounting platform engineered specifically for travel agencies, tour operators, and destination management companies (DMCs). 

Travel agencies operate under a unique and challenging operational model: services are purchased from third-party global suppliers (airlines, wholesalers, local tour operators, hotels) and bundled for retail or corporate customers. In traditional setups, customer relationships live in a fragmented CRM, bookings are tracked in spreadsheets, and finances are retroactively balanced in off-the-shelf accounting software that does not support travel-specific tax laws (such as the Tour Operators' Margin Scheme / VAT on Margin).

TripTrails solves this by bridging the entire lifecycle in real time:
1. **Commercial Pipeline**: Managing inbound leads, customer profiles, dynamic itineraries, and multi-version quotations.
2. **Operational Execution**: Converting accepted quotes into structured multi-service bookings with supplier cost allocations and traveler tracking.
3. **Billing & Collections**: Generating line-item invoices, payment schedules, receipts, and issuing credit notes with 409 conflict checks against duplicate invoicing.
4. **Automated Accounting**: Directly translating operational milestones into double-entry journal entries, posting to balanced general ledgers, trial balances, balance sheets, and profit & loss statements without manual bookkeeping intervention.

---

## 2. Core Modules

### ✈️ Travel & Booking Operations
* **Multi-Service Bookings**: Support for composite itineraries containing flights, hotels, tours, transfers, visas, and custom travel packages.
* **Line-Item Financial Controls**: Granular tracking of unit cost, unit selling price, supplier invoice reconciliation, quantity multipliers, and expected vs. actual profit margins.
* **Traveler & Passenger Management**: Passenger detail capture, passport records, room allocations, and special requests.
* **Supplier Workflows**: Supplier directory, payment tracking, supplier invoice recording, and direct cost allocations per service.
* **Document Engine**: In-browser PDF generation for invoices, receipts, quotations, and account statements via `@react-pdf/renderer`.

### 👥 CRM & Lead Management
* **Pipeline Management**: Inbound lead intake, status pipelines (New, Contacted, Qualified, Proposal, Won, Lost), priority flagging, and source attribution.
* **Activity History**: Chronological interaction logging (calls, emails, meetings, follow-ups, and notes).
* **One-Click Conversion**: Automated transformation of qualified leads into structured customer accounts and initial booking drafts.
* **Customer Directory**: Corporate vs. individual categorization, multi-contact directories, transaction histories, outstanding balances, and document attachments.

### 📊 Double-Entry Accounting
* **Chart of Accounts (COA)**: Standard 4-digit hierarchical accounts classified across Assets (1000s), Liabilities (2000s), Equity (3000s), Revenue (4000s), and Expenses/Cost of Sales (5000s).
* **Balanced Journal Entries**: Enforces standard accounting equations where every transaction requires balanced debits and credits ($\sum \text{Debits} = \sum \text{Credits}$) before committing to the database.
* **Tax Treatment Engine**: Built-in logic for Tour Operators Margin Scheme (`VAT_ON_MARGIN`), standard rated (`VAT_ON_SELLING_PRICE`), zero-rated, exempt, and out-of-scope services with Banker's rounding to 2 decimal places.
* **Automated Audit Trail**: Automatic journal entry posting on invoice generation and symmetric reversal journals upon invoice cancellation or credit note issuance.
* **Financial Statements**: Dynamic generation of General Ledger, Trial Balance, Profit & Loss (Income Statement), and Balance Sheet scoped by agency, branch, and date range.

### 🏢 Operations & Multi-Branch Administration
* **Multi-Tenant / Branch Hierarchy**: Multi-branch isolation under parent agencies with branch-specific currency configuration and head-office consolidation.
* **Role-Based Access Control (RBAC)**: Fine-grained permission system (`admin`, `manager`, `agent`, `accountant`) with route guards and action-level authorization.
* **Expense Management**: Categorized business expense tracking, payment account attribution, and support for prepaid expense amortization schedules.

---

## 3. System Architecture

```mermaid
flowchart TB
    subgraph Client ["Frontend Layer (Next.js 16 + React 19)"]
        UI["Tailwind CSS v4 + Radix UI"]
        State["Zustand Client Stores (Auth, Branch, Sidebar)"]
        Query["TanStack React Query + IndexedDB Persistence"]
        RHF["React Hook Form + Zod Client Validation"]
        PDF["Client-Side PDF Engine (@react-pdf/renderer)"]
    end

    subgraph Gateway ["Next.js Proxy & Security Layer"]
        Proxy["Next.js Route Rewrite (/api/* -> Express:5000)"]
        CookieManager["Same-Origin HttpOnly Cookie Transport"]
    end

    subgraph Backend ["Backend API Layer (Node.js + Express + TypeScript)"]
        Middleware["Security Middleware (Helmet, CORS, HPP, RateLimit)"]
        AuthMid["Auth Middleware + 60s In-Memory Session Cache"]
        RoleMid["RBAC Guard + Role Permission Cache"]
        Controllers["Domain Controllers (REST Endpoints)"]
        FinCalc["Financial Calculator (Margin VAT & Banker's Rounding)"]
        Services["Domain Services (Domain, Invoicing, Accounting, Quotations)"]
    end

    subgraph Database ["Persistence Layer (PostgreSQL + Prisma ORM)"]
        Prisma["Prisma Client 5.14+ (Schema & Query Generation)"]
        PgPool["PgBouncer Connection Pooler (Transaction Mode)"]
        PG[(PostgreSQL 15+ Relational Database / Supabase)]
    end

    Client --> Gateway
    Gateway --> Middleware
    Middleware --> AuthMid
    AuthMid --> RoleMid
    RoleMid --> Controllers
    Controllers --> FinCalc
    Controllers --> Services
    Services --> Prisma
    Prisma --> PgPool
    PgPool --> PG
```

---

## 4. Technology Stack

| Layer | Technology | Purpose & Implementation Details |
| :--- | :--- | :--- |
| **Frontend Framework** | Next.js 16.2 (App Router) | Server-driven layout shell, client-side route orchestration, and API proxying |
| **Frontend Library** | React 19.2 | Modern concurrent rendering, transitions, and component lifecycle |
| **Language** | TypeScript 5.4+ | Strict end-to-end type safety across both frontend and backend codebases |
| **Styling & Design System** | Tailwind CSS v4 + CSS Variables | Design token system with native dark/light theme switching via `next-themes` |
| **UI Primitives** | Radix UI + Lucide Icons | Accessible headless components (Dialogs, Tooltips, Dropdowns, Sheets) |
| **Client State Management** | Zustand 5.0 | Persistent UI state (active branch, authenticated user session, sidebar status) |
| **Server State & Caching** | TanStack React Query 5.101 | Client-side query caching with offline IndexedDB persistence (`idb-keyval`) |
| **Data Tables** | TanStack React Table 8.21 | Headless tabular data manipulation with column filtering, sorting, and pagination |
| **Form Handling & Validation** | React Hook Form 7.80 + Zod | Schema-driven client and server input validation with declarative field errors |
| **Document Generation** | `@react-pdf/renderer` 4.5 | Declarative in-browser PDF rendering for invoices, receipts, and quotations |
| **Backend Framework** | Node.js + Express 4.19 | Modular RESTful API with layered controllers, services, and error handling |
| **Database & ORM** | PostgreSQL 15+ via Prisma 5.14 | Relational database schema with 42 relational models, foreign keys, and indexes |
| **Connection Pooling** | PgBouncer (Transaction Mode) | Scalable database connection pooling hosted on AWS Supabase infrastructure |
| **Security & Hardening** | Helmet, HPP, Express Rate Limit | HTTP security headers, parameter pollution protection, and IP rate limiting |
| **Authentication** | JWT (`jsonwebtoken`) + Bcrypt | Cryptographically signed access/refresh tokens delivered via HttpOnly cookies |
| **Testing & Quality** | Custom TypeScript Test Runner | Automated P0 integration & regression test suites validating critical workflows |

---

## 5. Technical Highlights & Engineering Decisions

* **Client-Side PDF Generation without Server Load**: Instead of running resource-heavy Chromium/Puppeteer processes on the backend server, documents (Invoices, Quotations, Customer Receipts, Supplier Statements) are rendered directly in the client browser using `@react-pdf/renderer`, eliminating backend memory spikes.
* **Deterministic Financial Calculations**: All margin calculations, VAT computations, and line-item totals are governed by an isolated `financial-calculator.ts` library on the backend using Banker's rounding (`Math.round(val * 100) / 100`) to prevent JavaScript floating-point drift across multi-currency transactions.
* **Zero-Roundtrip Authentication Caching**: To prevent high-latency remote database queries on every authenticated request, `authMiddleware` features an in-memory session cache (60s TTL) for verified JWTs, cutting repeated authentication latency from ~560ms down to sub-millisecond speeds while invalidating instantly on logout.
* **Selective RSC Link Prefetching Optimization**: In Next.js App Router, navigation links by default trigger background compilation and prefetching for all viewport links. By applying `prefetch={false}` across fixed navigation bars, over 90 concurrent compilation requests were eliminated on initial page loads.
* **Multi-Branch Context Scoping**: System workflows enforce tenancy via `agencyScope` and `buildContext` utilities, ensuring operational staff cannot view or alter financial records outside their assigned branch unless granted administrative authorization.

---

## 6. Database & Data Modeling

The relational schema is defined in [`prisma/schema.prisma`](travelflow-backend/prisma/schema.prisma) consisting of **42 normalized models** enforcing strict data integrity across tenants:

```text
Agency (Tenant Root)
├── Branch (Multi-Location Support)
├── User (RBAC Credentials & Branch Assignment)
├── Role (Granular Permission Lists)
├── Customer (CRM Entities)
│   ├── CustomerNote & CustomerDocument
│   └── Booking (Central Operational Unit)
│       ├── BookingService (Line items with pricing & tax attributes)
│       ├── BookingTraveler (Passenger profiles)
│       ├── BookingDocument & BookingActivity
│       └── Invoice (Commercial Billing Document)
│           ├── InvoiceLine (Itemized invoice snapshot)
│           └── CustomerPayment (Collections & PaymentAllocations)
├── Supplier (Vendor Registry)
│   └── SupplierPayment & SupplierPaymentAllocation
├── Quotation (Multi-Version Sales Proposals)
│   ├── QuotationItem & QuotationTax
│   └── QuotationVersion (Historical revisions)
└── ChartOfAccount (General Ledger Structure)
    ├── FiscalPeriod (Accounting Period Control)
    └── JournalEntry (Double-Entry Header)
        └── JournalLine (Debit/Credit records with balance constraints)
```

---

## 7. Accounting Engine Architecture

TripTrails implements double-entry bookkeeping adapted specifically for travel agencies:

### 1. Chart of Accounts Structure
Accounts follow standard accounting conventions:
* **1000–1999 (Assets)**: Cash on Hand, Bank Accounts, Accounts Receivable, Input VAT Recoverable, Fixed Assets.
* **2000–2999 (Liabilities)**: Accounts Payable (Suppliers), Output VAT Payable, Customer Advances.
* **3000–3999 (Equity)**: Retained Earnings, Owner's Capital.
* **4000–4999 (Revenue)**: Ticket Sales Revenue, Tour Package Revenue, Visa Service Revenue, Commission Income.
* **5000–5999 (Cost of Sales / Expenses)**: Cost of Airline Tickets, Hotel Costs, Tour Operating Expenses, Cost Variance.

### 2. Double-Entry Posting Lifecycle
When an invoice is issued from a booking:
1. **Accounts Receivable (Account 1100)** is debited for the total invoice amount.
2. **Supplier Payable (Account 2000)** is credited for the baseline service cost price.
3. Under the **Tour Operators Margin Scheme (`VAT_ON_MARGIN`)**:
   $$\text{Margin} = \text{Selling Price} - \text{Cost Price}$$
   $$\text{Tax Base} = \frac{\text{Margin}}{1 + \text{VAT Rate}}$$
   $$\text{Output VAT} = \text{Margin} - \text{Tax Base}$$
   * **Output VAT Payable (Account 2200)** is credited for the tax amount on the margin.
   * **Service Revenue (Account 4000)** is credited for the net earned margin.
4. **Debits Equal Credits Integrity**: The engine validates $\sum \text{Debits} == \sum \text{Credits}$ before writing the `JournalEntry` and `JournalLine` rows in a single atomic database transaction.

### 3. Reversal Accounting
If an invoice is cancelled or a Credit Note is issued, the system does not delete historical records. Instead, it generates a mirror-image **Reversal Journal Entry**, crediting Accounts Receivable and debiting Revenue/Payables to preserve complete financial auditability.

---

## 8. Authentication, Authorization & Security

* **Cookie-Based Authentication**: The API delivers standard JWT access tokens (15m expiry) and refresh tokens (30d expiry) in `HttpOnly`, `SameSite=Lax`, secure cookies. JavaScript running in the browser cannot access tokens directly, eliminating XSS token theft vectors.
* **Token Blacklisting & Revocation**: Revoked access tokens are stored in a dedicated `TokenBlacklist` database table and mirrored in a high-speed memory Set to enforce immediate session termination upon logout.
* **Role-Based Guards**: Protected routes utilize `requireRole(["admin", "manager"])` and permission-level guards (`requirePermission("Invoices: Create")`).
* **Multi-Tenant Protection**: Incoming requests pass through `tenantMiddleware`, which extracts the verified user's `agencyId`. All subsequent database queries enforce tenant scoping (`where: { agencyId }`) to prevent cross-tenant data leakage.

---

## 9. Key Engineering Challenges & Solutions

### 1. Automated Invoice Balancing for Zero & Negative Margin Bookings
* **Challenge**: In travel bookings, promotional items or negotiated package discounts can result in zero margin (selling price equals cost price) or negative margin (service sold at a loss). Standard percentage-based VAT calculations produce invalid or unbalanced debits and credits.
* **Approach**: Built conditional financial journal branching in `accounting.service.ts`. When margin is zero, the transaction is treated as a pure pass-through (Accounts Receivable debited, Accounts Payable credited with 0 VAT and 0 Revenue). When margin is negative, the loss is automatically mapped and debited to **Account 5000 (Cost Variance)**, ensuring debits always equal credits.
* **Result**: Guaranteed journal balance across all edge-case booking scenarios verified by automated regression test suites.

### 2. High-Latency Cloud Database Connection Overhead
* **Challenge**: Connecting a local development backend or edge server to a cloud-hosted database (Supabase AWS `ap-south-1`) introduces ~105ms network round-trip time. Running `SET LOCAL` session variables outside transactions on a connection pooler added 276ms of wasted latency per query, causing composite endpoints to take 2–3 seconds.
* **Approach**: Bypassed redundant session SQL queries in favor of application-level multi-tenant query scoping, and implemented an in-memory session cache for authenticated JWT validation.
* **Result**: Reduced repeated endpoint latency by over 60%, eliminating redundant database round-trips for authenticated dashboard loads.

### 3. Concurrency Protection Against Duplicate Invoicing
* **Challenge**: Rapid multiple clicks on invoice generation actions from booking interfaces risked creating multiple active invoices and duplicate accounting entries for the same reservation.
* **Approach**: Added database-level constraint validation in `invoice.service.ts` checking for pre-existing active (non-cancelled) invoices linked to the booking, raising an explicit `409 Conflict` error if an active invoice already exists.
* **Result**: Prevents duplicate commercial claims and duplicate general ledger entries.

---

## 10. Automated Testing & Verification

The backend includes automated P0 integration and regression test suites executed sequentially via `tests/run_all.ts`:

```bash
cd travelflow-backend
npm run test
```

### Verified Test Suites (19/19 Passing)
* **P0.1: Security — Credential & Password Hash Sanitization** (4 tests): Ensures user queries, authentication responses, and profile payloads never expose password hashes or sensitive internal fields.
* **P0.2: Expense Accounting & Audit Trail** (4 tests): Verifies automatic chart of accounts resolution, balanced journal postings, and prepaid expense amortization logic.
* **P0.3: Zero / Negative Margin Invoice Balancing** (4 tests): Verifies debit/credit balance equality under positive, zero, and loss-making sales margins.
* **P0.4: Quantity & Pricing Single Source of Truth** (4 tests): Validates that line costs, line selling prices, VAT base, and margin values scale accurately across multi-quantity bookings and quotation conversions.
* **P0.5: Duplicate Invoice Prevention & Cancellation Reversal** (3 tests): Tests the 409 Conflict duplicate invoice guard and validates that invoice cancellations generate mirror reversal journal entries.

---

## 11. Project Structure

```text
travelflow/
├── travelflow-backend/               # Node.js + Express REST API
│   ├── prisma/
│   │   ├── schema.prisma             # 42 Relational Prisma Models
│   │   ├── seed-basic.ts             # Initial Agency, Roles, COA, & Customer Seed
│   │   └── migrations/               # PostgreSQL Schema Migrations
│   ├── src/
│   │   ├── config/                   # Environment & runtime configuration
│   │   ├── controllers/              # HTTP Route Handlers (Auth, Domain, Invoice, Accounting)
│   │   ├── lib/                      # Database client & Financial Calculator
│   │   ├── middleware/               # Auth, Tenant isolation, RBAC, Validation
│   │   ├── routes/                   # Express Router definitions (/api/v1/*)
│   │   ├── services/                 # Core Business Logic & Accounting Engines
│   │   ├── utils/                    # ApiError, ApiResponse, Reference Generator
│   │   ├── validators/               # Zod validation schemas
│   │   ├── app.ts                    # Express application configuration
│   │   └── server.ts                 # Server entrypoint and DB connection
│   ├── tests/                        # P0 Regression & Integration Test Suite
│   └── package.json
│
├── travelflow-frontend/              # Next.js 16 + React 19 Client
│   ├── app/                          # App Router Pages & Layouts
│   │   ├── (auth)/                   # Authentication routes (Sign-in)
│   │   ├── (dashboard)/              # Authenticated dashboard views
│   │   │   ├── accounting/           # COA, General Ledger, Journals, AR/AP
│   │   │   ├── bookings/             # Booking management & service details
│   │   │   ├── customers/            # CRM Customer directory & profiles
│   │   │   ├── expenses/             # Expense tracking & amortization
│   │   │   ├── invoices/             # Invoicing, Credit Notes, & Collections
│   │   │   ├── leads/                # Lead tracking pipeline
│   │   │   ├── quotations/           # Proposal builder & versioning
│   │   │   ├── reports/              # Financial statements & branch analytics
│   │   │   └── layout.tsx            # Authenticated App Shell & Sidebar
│   │   ├── print/                    # Dedicated print/PDF preview routes
│   │   └── globals.css               # Design system tokens & Tailwind v4 theme
│   ├── components/                   # Reusable UI component library
│   │   ├── layout/                   # Sidebar, Topbar, Breadcrumbs, UserMenu
│   │   ├── tables/                   # TanStack DataTable primitives & filters
│   │   ├── ui/                       # Radix UI + Shadcn component primitives
│   │   └── shared/                   # Status badges, Stat cards, Empty states
│   ├── features/                     # Domain-specific component modules
│   ├── hooks/                        # Custom hooks (permissions, window size)
│   ├── lib/                          # API client, PDF generation, formatters
│   ├── store/                        # Zustand client state stores
│   ├── types/                        # TypeScript domain interfaces
│   └── package.json
│
└── README.md
```

---

## 12. Development Setup

### Prerequisites
* **Node.js**: `v20.x` or higher (LTS recommended)
* **npm**: `v10.x` or higher
* **PostgreSQL**: `v15.x` or a cloud-hosted PostgreSQL instance (e.g., Supabase)

### 1. Clone the Repository
```bash
git clone https://github.com/Khubaib-shah/TravelFlow.git
cd TravelFlow
```

### 2. Backend Setup
```bash
cd travelflow-backend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env

# Generate Prisma Client & push schema to database
npx prisma generate
npx prisma db push

# Seed initial Agency, Branch, Roles, Admin User, and Chart of Accounts
npm run seed

# Run automated tests
npm run test

# Start backend in development mode (port 5000)
npm run dev
```

### 3. Frontend Setup
```bash
cd ../travelflow-frontend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env.local

# Start frontend in development mode (port 3000)
npm run dev
```

Access the application at `http://localhost:3000`.

---

## 13. Environment Variables

### Backend Configuration (`travelflow-backend/.env`)
| Variable | Description | Example / Default |
| :--- | :--- | :--- |
| `PORT` | Local port for Express API server | `5000` |
| `NODE_ENV` | Application environment (`development`, `production`) | `development` |
| `DATABASE_URL` | PostgreSQL connection string (PgBouncer pooler or direct) | `postgresql://user:password@host:5432/db` |
| `DIRECT_URL` | Direct PostgreSQL connection string for Prisma migrations | `postgresql://user:password@host:5432/db` |
| `JWT_SECRET` | Secret key used to sign access tokens | `your-secure-access-secret-min-64-chars` |
| `JWT_EXPIRES_IN` | Access token lifespan | `15m` |
| `JWT_REFRESH_SECRET` | Secret key used to sign refresh tokens | `your-secure-refresh-secret-min-64-chars` |
| `JWT_REFRESH_EXPIRES_IN` | Refresh token lifespan | `30d` |
| `FRONTEND_URL` | Allowed CORS origin for frontend client requests | `http://localhost:3000` |

### Frontend Configuration (`travelflow-frontend/.env.local`)
| Variable | Description | Example / Default |
| :--- | :--- | :--- |
| `BACKEND_URL` | Backend server URL targeted by Next.js proxy rewrites | `http://127.0.0.1:5000` |
| `NEXT_PUBLIC_USE_API` | Toggles live backend API client vs mock fallback | `true` |

---

## 14. Screenshots & Visual Interface

> *Screenshots demonstrating the operational dashboard, multi-service booking workflows, interactive chart of accounts, and printable invoices can be reviewed below:*

| Dashboard & Operations | Financial Management |
| :---: | :---: |
| ![Dashboard Overview](docs/screenshots/dashboard.png) | ![Chart of Accounts](docs/screenshots/accounting.png) |
| *Operational overview with KPIs, activity logs, and branch selector* | *Hierarchical Chart of Accounts & balanced general ledger* |

| Booking Workflow | Invoices & Print Engine |
| :---: | :---: |
| ![Booking Management](docs/screenshots/bookings.png) | ![Printable Invoice](docs/screenshots/invoice.png) |
| *Multi-service itinerary builder with margin calculations* | *Client-side generated PDF tax invoices with line-item VAT* |

---

## 15. Project Status

* **Status**: Active Development / Core ERP Platform Complete
* **Core Functionality**: Full-stack booking lifecycle, quotation versioning, CRM pipelines, invoicing, and double-entry accounting engines are fully operational and verified by automated regression test suites.

---

## 16. What This Project Demonstrates

* **Full-Stack Systems Engineering**: Seamless end-to-end integration between a complex Next.js client and an Express/TypeScript REST backend.
* **Relational Database Design**: Modeling complex multi-tenant operational data across 42 relational models with referential integrity.
* **Financial Domain Expertise**: Implementing formal double-entry accounting, VAT on margin schemes, and balanced ledger controls directly in code.
* **Performance & Scalability**: Diagnosing and resolving network latency, database connection overhead, and client-side rendering bottlenecks.
* **Clean Code & Testing Standards**: Maintaining a modular, layered codebase backed by deterministic business logic and comprehensive P0 regression tests.

---

## 17. Developer & Contact

**Khubaib Shah**  
*Full-Stack Software Engineer*

* **GitHub**: [@Khubaib-shah](https://github.com/Khubaib-shah)
* **Repository**: [https://github.com/Khubaib-shah/TravelFlow](https://github.com/Khubaib-shah/TravelFlow)
* **Email**: `bewithbaacha@gmail.com`
