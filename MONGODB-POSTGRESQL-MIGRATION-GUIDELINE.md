# TravelFlow: MongoDB to PostgreSQL Migration Guideline

**Prerequisite for:** Double-Entry Accounting / Financials Module  
**Audience:** AI coding assistants working inside the TravelFlow repository  
**Status:** Planning brief; authoritative for this migration until repository code says otherwise  
**Companion documents:** `AGENTS.md`, `MEMORIES.md`, `UI-UX-DESIGN-SYSTEM-BLUEPRINT.md`, `CLAUDE_PROJECT_CONTEXT.md`

## 0. How to Use This Document

1. This is a phase-gated plan. Do not skip phases or collapse them to move faster.
2. Every phase ends with a sign-off gate. Stop and produce the requested output for human review. Do not start the next phase in the same session unless explicitly told to proceed.
3. Do not touch MongoDB code paths until the phase explicitly allows it. PostgreSQL is built alongside MongoDB until cutover.
4. No stub or mock accounting logic. If a financial rule such as balancing, immutability, or tenant scope cannot be fully implemented, say so and stop.
5. Never invent schema, endpoints, or file paths. Read the repository first; Phase 0 replaces assumptions with facts.

## 1. Objective

Migrate TravelFlow persistence from MongoDB/Mongoose to PostgreSQL/Prisma and use the relational foundation to build a proper double-entry accounting General Ledger module: chart of accounts, journal entries, posting rules, fiscal periods, and financial statements.

This is both a safe migration of existing modules and a native relational design for Financials. The target standard is CA-grade: balanced entries, immutable postings, tenant isolation, and a complete audit trail.

## 2. Why PostgreSQL

- Double-entry accounting is relational: journal lines reference entries, accounts, periods, and source documents.
- PostgreSQL foreign keys, checks, and transactions can enforce financial correctness at the data layer.
- Financial reports are join- and aggregation-heavy, making SQL a better fit than increasingly complex MongoDB pipelines.
- Prisma and PostgreSQL match the team's existing tenant-scoped relational experience and reduce the need to introduce TypeORM or raw `pg` as a primary ORM approach.

## 3. Non-Negotiable Constraints

1. Multi-tenancy and branch isolation must retain current behavior. Every query remains scoped by `agencyId`, and by `branchId` for non-admin users. Prefer stronger enforcement in the relational layer.
2. RBAC through `requireRole` and `requirePermission` must keep working.
3. Cookie-based JWT authentication and frontend refresh-token retry behavior must not change. ObjectId-to-UUID conversion must not break token payloads, `/auth/me`, or silent refresh.
4. No data loss or silent corruption. Every migrated record must be reconciled against the source.
5. The `ApiResponse` contract and `{ data: ... }` response shape stay unchanged.
6. Leads, customers, bookings, suppliers, quotations, invoices, receipts, and expenses must not regress while Financials is built.
7. New frontend screens continue to follow `AGENTS.md`: shadcn primitives, existing design tokens, green primary actions, and gold accent.

## 4. Target Architecture

```text
travelflow-backend/
  prisma/
    schema.prisma
    migrations/
    seed.ts
  src/
    lib/prisma.ts
    controllers/
    middleware/
    routes/
    services/
    validators/
    utils/
```

- PostgreSQL 15+ is the target database.
- Prisma is the ORM.
- `src/lib/prisma.ts` replaces the Mongo connection layer.
- UUIDv4 values are the new primary keys, generated with `@default(uuid())`.
- Any ordering currently inferred from Mongo ObjectId order must use an explicit indexed `createdAt` column.
- Add a Prisma client extension or equivalent enforcement layer for tenant-scoped models so missing `agencyId` filters fail rather than silently allowing cross-tenant access.

## 5. Verified File-Impact Map

This table is a hypothesis until Phase 0 verifies it against the current repository.

| Path                                                         | Expected change                                                                                                        | Reason                                         |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `travelflow-backend/src/config/`                             | Replace Mongo connection with `src/lib/prisma.ts` and Prisma datasource                                                | New connection layer                           |
| `travelflow-backend/src/config/env.ts`                       | Replace `MONGODB_URI` with `DATABASE_URL`; add `DIRECT_URL` if required by pooling                                     | New environment contract                       |
| `travelflow-backend/src/models/*.ts`                         | Eventually replace Mongoose models with `prisma/schema.prisma` models                                                  | Prisma becomes the persistence model           |
| `travelflow-backend/src/services/*.ts`                       | Rewrite Mongoose queries to Prisma equivalents                                                                         | Business logic moves to relational persistence |
| `travelflow-backend/src/controllers/*.ts`                    | Mostly preserve shape; replace ObjectId casting and Mongoose error handling                                            | ORM-specific error/ID behavior changes         |
| `travelflow-backend/src/middleware/tenant*.ts`               | Adapt tenant context and/or delegate enforcement to Prisma extension                                                   | Tenant isolation point                         |
| `travelflow-backend/src/validators/`                         | Replace 24-character ObjectId checks with UUID validation                                                              | ID format changes                              |
| `travelflow-backend/src/utils/`                              | Remove Mongoose transforms; serialize Prisma Decimal values explicitly                                                 | Plain objects and money serialization          |
| `travelflow-backend/src/scripts/` and `seeds/`               | Rewrite against Prisma, with FK-aware ordering                                                                         | Relational seeding/migration                   |
| `travelflow-backend/src/app.ts` and `server.ts`              | Replace Mongoose bootstrap with Prisma startup/check                                                                   | Runtime initialization                         |
| `travelflow-backend/package.json`                            | Remove Mongoose; add `prisma`, `@prisma/client`, and required PostgreSQL driver support                                | Dependency swap                                |
| `travelflow-frontend/types/`                                 | Keep IDs as strings; audit ObjectId parsing and `_id` ordering                                                         | UUIDs remain strings but differ semantically   |
| `travelflow-frontend/lib/api-client.ts` and `data-source.ts` | Likely unchanged; verify ObjectId assumptions                                                                          | Confirm ID-agnostic behavior                   |
| New Financials module                                        | Follow the repository's existing controller/service/route convention unless Phase 0 identifies a better local boundary | New ledger functionality                       |

Do not delete Mongo files until their module has passed cutover verification and the final decommission phase has been approved.

## 6. Phase Plan

### Phase 0: Discovery and Inventory

**Code changes:** None.

Verify every assumption in this document:

- Inventory every Mongoose model field-by-field, including types, indexes, references, embedded subdocuments, and arrays.
- Mark each model as tenant-scoped, branch-scoped, soft-deleted, and/or dependent on ObjectId ordering.
- Find every `.populate(`, `.aggregate(`, `.lean(`, and manual `agencyId`/`branchId` filter in services.
- Find Mongo ObjectId regex validation in backend and frontend.
- Find `_id` sorting and pagination logic.
- Record current document counts per collection for reconciliation.

**Required output:** Corrected file-impact map, complete model inventory, and all non-trivial query/aggregation patterns.  
**Sign-off gate:** Human review of the inventory before schema design.

### Phase 1: Relational Schema Design

Create `prisma/schema.prisma` from the verified inventory, not from guesses.

Rules:

- Every tenant-scoped model has required indexed `agencyId` foreign key to `Agency`.
- Use composite indexes for common agency-plus-branch queries.
- Preserve soft delete with `isDeleted`; use PostgreSQL partial indexes where supported by the chosen migration strategy.
- Use `Decimal`/PostgreSQL `numeric` for all money; never `Float`.
- Convert embedded subdocuments to related tables when independently queried/reported, otherwise use `Json` deliberately.
- Include Financials models in the same schema because they reference invoices, receipts, expenses, and supplier payments.

**Sign-off gate:** Full schema review and approval before running `prisma migrate dev`.

### Phase 2: Parallel Infrastructure

MongoDB remains untouched and remains the running source of truth.

- Provision PostgreSQL locally or in a development environment.
- Install Prisma and PostgreSQL dependencies.
- Add `prisma/schema.prisma` and run migrations only after Phase 1 approval.
- Add an unconnected `src/lib/prisma.ts` singleton.
- Confirm the existing Mongo-backed application still builds and runs.

**Verification:** `npx prisma validate`, successful migration against the approved schema, and an unchanged Mongo application build/run.  
**Sign-off gate:** Human approval before data migration tooling.

### Phase 3: Data Migration Tooling

Create an idempotent, one-way ETL script such as `scripts/migrate-to-postgres.ts`.

- Read each Mongo collection and write to PostgreSQL in foreign-key order: agencies, branches, users/roles, then dependent modules, with new Financials tables last.
- Map ObjectIds to generated UUIDs.
- Persist an old Mongo ID to new UUID mapping table or equivalent durable mapping store.
- Preserve `createdAt` and `updatedAt` exactly.
- Make the script re-runnable against a wiped PostgreSQL database.

Required reconciliation:

- Row counts match source counts, with every intentional exclusion documented.
- Sample foreign keys resolve, including customer-to-booking and agency/branch relationships.
- Money aggregates, such as invoice totals per agency, match the source.

**Sign-off gate:** Full production-like migration and reconciliation report reviewed before backend reads PostgreSQL.

### Phase 4: Backend Service-by-Service Cutover

Suggested order:

1. Agencies, branches, users, and roles
2. Customers and leads
3. Suppliers
4. Bookings
5. Quotations
6. Invoices, receipts, and expenses
7. Templates, settings, notifications, and dashboard statistics

For each module:

- Rewrite services to Prisma.
- Keep controllers thin; change only flagged ID/error handling.
- Update Zod ID validation.
- Update frontend types/client only where Phase 0 found ObjectId-specific behavior.
- Manually verify the module end-to-end before proceeding.

Use a module-level configuration flag where possible so a cutover can be reversed. Do not stack multiple unreviewed module rewrites.

**Sign-off gate:** Human review after every module.

### Phase 5: Frontend Adjustments

- Replace `_id`-based ordering with `createdAt` wherever found.
- Remove Mongo ObjectId validation.
- Check whether UI logic branches on Mongoose-specific error messages instead of status codes.
- Re-verify loading, empty, error, forbidden, and mutation-refresh states.

### Phase 6: Financials Module

Build Financials against the approved relational schema. This is greenfield accounting functionality, not a migration shortcut.

**Sign-off gate:** Human approval before wiring invoice, receipt, expense, or supplier-payment auto-posting into production paths.

### Phase 7: Final Cutover and Mongo Decommission

- Freeze writes.
- Run final incremental migration and reconciliation.
- Switch production to `DATABASE_URL`.
- Remove `MONGODB_URI`, dead Mongo code, and the Mongoose dependency only after approval.
- Archive the final Mongo dump for the agreed rollback retention period.

**Sign-off gate:** Explicit human authorization before decommissioning MongoDB.

### Phase 8: Post-Migration Hardening

- Review indexes using real query patterns and `EXPLAIN ANALYZE`.
- Confirm PostgreSQL backup and restore procedures.
- Verify tenant-safety enforcement across every tenant-scoped model.

## 7. Financials Data Model

Design these models as part of Phase 1:

- **ChartOfAccount:** `id`, `agencyId`, `code`, `name`, `type` (`ASSET`, `LIABILITY`, `EQUITY`, `REVENUE`, `EXPENSE`), optional `parentAccountId`, `isActive`, and `normalBalance` (`DEBIT` or `CREDIT`).
- **FiscalPeriod:** `id`, `agencyId`, `startDate`, `endDate`, and `status` (`OPEN` or `CLOSED`). Posting to a closed period is rejected.
- **JournalEntry:** `id`, `agencyId`, `branchId`, `date`, `reference`, `description`, `status` (`DRAFT`, `POSTED`, `REVERSED`), nullable `sourceModule`/`sourceId`, `createdBy`, and `postedAt`.
- **JournalLine:** `id`, `journalEntryId`, `accountId`, Decimal `debit`, Decimal `credit`, `currency`, `exchangeRate` defaulting to 1 for single-currency operation, and `description`.

### Accounting invariants

- Posting occurs inside a Prisma transaction.
- A journal entry cannot become `POSTED` unless total debits equal total credits.
- Posted entries and their lines cannot be edited or deleted.
- Corrections are new reversing entries referencing the original entry.
- Closed fiscal periods reject posting.
- All entries remain agency- and branch-scoped.

### Auto-posting integration points

Build and approve these last:

- Invoice issued: Debit Accounts Receivable; Credit Revenue.
- Receipt recorded: Debit Cash/Bank; Credit Accounts Receivable.
- Expense recorded: Debit Expense; Credit Cash/Bank or Accounts Payable.
- Supplier payment: Debit Accounts Payable; Credit Cash/Bank.

### Currency and reporting

Confirm with the user whether agencies transact in PKR, AED, SAR, and/or USD before assuming a single currency. If multi-currency is needed, retain `exchangeRate` and a base-currency reporting amount from the beginning.

Trial balance, ledger, profit and loss, and balance sheet reports should query journal lines and accounts through SQL views or Prisma queries. Do not duplicate report data in drift-prone materialized application records.

## 8. Rollback Strategy

- Through Phase 6, MongoDB is the source of truth and rollback means continuing with the old path.
- From Phase 4, use module-level flags where possible.
- Keep Mongo models and data until the relevant cutover is verified.
- Phase 7 decommissioning is the only irreversible step and requires explicit approval.

## 9. Final Pre-Production Checklist

- [ ] Phase 0 inventory reviewed and signed off
- [ ] `schema.prisma` reviewed and signed off, including Financials tables
- [ ] Migration script reconciliation report reviewed
- [ ] Every module manually verified after cutover
- [ ] Auth, RBAC, tenant isolation, branch isolation, and forbidden states verified
- [ ] Journal balancing and immutability verified with real posting scenarios
- [ ] Multi-currency decision made explicitly
- [ ] PostgreSQL backups and restore process configured
- [ ] Final Mongo dump archived
- [ ] Human sign-off obtained before Phase 7

## 10. Assistant Operating Rule

When working on this migration, state the current phase before editing. Complete only that phase, run its verification, produce its sign-off output, and stop. Do not begin the next phase without explicit human instruction.
