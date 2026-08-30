# TravelFlow Project Context

This document is a handoff brief for an AI coding assistant working on TravelFlow. Treat the repository code as authoritative when it differs from this document.

## 1. Product

TravelFlow is a multi-tenant travel-agency ERP and CRM. It supports the operational lifecycle of a travel agency:

- Leads and lead activities
- Customers, notes, documents, and customer ledgers
- Bookings and booking activities/documents
- Suppliers, supplier payments, and supplier statements
- Quotations, quotation versions/items/taxes/attachments
- Invoices and receipts
- Expenses
- Branches
- Users, roles, and permissions
- Templates, settings, notifications
- Dashboard statistics and analytics

The main product UI is an authenticated, desktop-first administration application with a responsive layout.

## 2. Repository Layout

The repository contains two separately installed TypeScript applications:

```text
travelflow/
  AGENTS.md                         # mandatory project/UI rules
  README.md                         # largely default Next.js README; not authoritative
  MEMORIES.md                       # tracked bug notes and fixes
  UI-UX-DESIGN-SYSTEM-BLUEPRINT.md  # frontend visual/architecture guidance
  travelflow-backend/
    package.json
    src/
      app.ts                         # Express app and global middleware
      server.ts                      # DB connection, app creation, listen
      config/                        # environment and MongoDB connection
      controllers/                   # HTTP request handlers
      middleware/                    # auth, tenant, role, validation, errors
      models/                        # Mongoose models
      routes/                        # API route registration
      services/                      # business logic and database operations
      validators/                    # Zod schemas
      utils/                         # errors, responses, JWT, serialization, helpers
      scripts/ and seeds/             # maintenance and seed code
  travelflow-frontend/
    package.json
    app/                             # Next.js App Router pages and layouts
    components/                      # layout, shared, feature, table, chart components
    components/ui/                   # shadcn/Radix UI primitives
    features/                        # feature hooks, schemas, and domain logic
    hooks/                           # shared React hooks
    lib/                             # API client, query client, serialization, utilities
    providers/                       # auth, query, theme, sidebar providers
    store/                           # Zustand stores
    types/                           # shared frontend TypeScript domain types
    constants/                       # navigation, statuses, drawer definitions
    public/                          # static assets
```

## 3. Technology Stack

### Frontend (`travelflow-frontend`)

- Next.js `16.2.9`, App Router, TypeScript
- React `19.2.4`
- Tailwind CSS `4` with CSS variables in `app/globals.css`
- shadcn/ui using Radix primitives; configuration is in `components.json`
- Lucide icons through `lucide-react`
- TanStack Query for server state, including persisted IndexedDB cache via `idb-keyval`
- Zustand for client state
- React Hook Form + Zod for forms and validation
- TanStack Table for data tables
- Recharts for charts
- Framer Motion for animation
- Sonner for toast notifications
- `next-themes` for theme support
- `@react-pdf/renderer` for PDF/print-related UI
- `date-fns` for dates

### Backend (`travelflow-backend`)

- Node.js + TypeScript
- Express `4.19`
- MongoDB through Mongoose `8`
- Zod request validation
- JWT access/refresh authentication
- HttpOnly cookies through `cookie-parser`
- `bcryptjs` password hashing
- Security middleware: Helmet, CORS, compression, Mongo sanitize, HPP, rate limiting, Morgan
- `express-async-errors` for async controller errors

### Persistence

MongoDB is the only configured database. The default local URI is:

```text
mongodb://127.0.0.1:27017/travelflow
```

Mongoose uses a connection pool with `maxPoolSize: 10`.

## 4. Runtime Topology

In local development:

```text
Browser
  -> Next.js frontend :3000
      -> same-origin /api/v1/*
          -> Next rewrite
              -> Express backend :5000/api/v1/*
                  -> MongoDB
```

The frontend API client uses `BASE = "/api/v1"`. `travelflow-frontend/next.config.ts` rewrites `/api/:path*` to `BACKEND_URL` or `http://127.0.0.1:5000`.

The backend starts by connecting to MongoDB, then listens on `PORT` (default `5000`). Its API prefix is `/api/${API_VERSION}` (default `/api/v1`).

## 5. Authentication and Authorization

Authentication is cookie-based:

- Login returns/sets `tf_access_token` and `tf_refresh_token` HttpOnly cookies.
- The access token is read only by backend middleware from `req.cookies.tf_access_token`.
- The frontend sends cookies with `credentials: "include"`.
- The frontend API client silently calls `/auth/refresh-token` once after a `401`, retries the original request once, and logs out/redirects to `/login` if refresh fails.
- `proxy.ts` checks for either auth cookie and redirects unauthenticated pages to `/login`; it excludes API and static paths.
- `AuthProvider` calls `/auth/me` on mount when `NEXT_PUBLIC_USE_API=true`.

Backend protected request flow:

```text
authMiddleware -> tenantMiddleware -> role/permission middleware -> Zod validate -> controller -> service -> Mongoose model
```

Authorization has two layers:

- `requireRole(["admin", "manager"])` checks the user's role directly.
- `requirePermission("Area: Action")` loads the agency role and checks its permission list. Admins bypass permission checks.

Never rely only on frontend route restrictions. Backend middleware must enforce access.

## 6. Multi-Tenancy and Branch Scope

Every authenticated request receives `req.agencyId` from the authenticated user. Services use a tenant context and construct Mongoose filters containing the agency ID and `isDeleted: false`.

Branch rules in `domain.service.ts`:

- Admins can see all branches by default and may filter by `branchId`.
- Non-admin users are scoped to their assigned branch.
- `domain.controller.ts` rejects a non-admin request that attempts to query another branch.
- The frontend API client reads the active branch from the persisted `tf-active-branch` Zustand state and appends `branchId` to requests unless `skipBranchScope` is requested.

New queries and mutations must preserve agency and branch isolation. Do not query a model by ID alone when the operation is tenant-scoped.

## 7. Backend Coding Pattern

### Add or change an endpoint

1. Add or update a Zod schema in `src/validators/schemas`.
2. Register the route in the appropriate file under `src/routes`.
3. Put authentication, tenant, role, and permission middleware on the route.
4. Validate body and params with the existing `validate` middleware.
5. Keep controllers thin: extract request context, call a service, and return `ApiResponse.success` or `ApiResponse.created`.
6. Put business rules and database access in a service.
7. Use existing Mongoose models and serialization/error helpers.
8. Add/update the frontend API client method and feature hook/type as needed.

The main generic domain endpoints are registered in `src/routes/index.ts`; quotations, templates, settings, notifications, and invoices have dedicated route files and controllers/services.

Typical response shape is handled by `ApiResponse`; frontend `request<T>()` expects a successful JSON response with the payload under `data`.

### Backend commands

Run from `travelflow-backend`:

```bash
npm install
npm run dev       # nodemon src/server.ts
npm run build     # tsc
npm run start     # node dist/server.js
npm run lint
npm run seed      # ts-node src/scripts/seed.ts
```

## 8. Frontend Coding Pattern

### Add a page

- Use the App Router under `travelflow-frontend/app`.
- Authenticated pages normally belong under `app/(dashboard)/` and inherit the dashboard shell.
- The shell uses `Sidebar`, `Topbar`, an `ErrorBoundary`, and client-side auth/role checks.
- Keep page composition consistent with the existing design blueprint: page header, actions, tables/forms/detail sections, loading/empty/error states.

### Add a data-backed feature

1. Add or reuse a type under `types/`.
2. Add an API method in `lib/api-client.ts`.
3. Export/use it through `lib/data-source.ts` (`API`), rather than calling `fetch` in a page.
4. Add feature-specific TanStack Query hooks under the relevant `features/<area>/` directory when appropriate.
5. Use the shared query client and invalidate after mutations. The API client already notifies the invalidation store for mutations.
6. Use React Hook Form and Zod schemas for forms.
7. Use existing components from `@/components/ui/*` and existing project components before creating new primitives.

The current `lib/data-source.ts` exports `ApiClient`. Its comments describe an environment toggle/MockAPI fallback, but the current implementation shown in the repository exports the real API client only. Verify any mock implementation before depending on it.

### Frontend commands

Run from `travelflow-frontend`:

```bash
npm install
npm run dev       # Next.js development server, normally :3000
npm run build
npm run start
npm run lint
```

## 9. Frontend State and Caching

- `AuthProvider` hydrates the Zustand auth store from `/auth/me` when API mode is enabled.
- `QueryProvider` configures TanStack Query with 30-second default stale time, 10-minute garbage collection, no mutation retries, and one retry for transient/429/5xx/network failures.
- Selected shared/dashboard queries are persisted to IndexedDB for up to seven days.
- `ThemeProvider`, `SidebarProvider`, and `QueryProvider` are nested in the root layout alongside `AuthProvider`.
- Do not store access tokens in localStorage or JavaScript-accessible state.

## 10. UI Rules

`AGENTS.md` is mandatory. Important rules:

- Reuse shadcn components from `@/components/ui/*`.
- Do not create raw buttons, inputs, selects, dialogs, cards, tables, or other primitives when an existing equivalent exists.
- Compose existing primitives instead of creating a parallel UI library.
- Use Tailwind utilities and existing CSS variables/design tokens.
- Use Lucide icons in buttons where an icon exists.
- Use shadcn Form + React Hook Form + Zod for forms.
- Use shadcn Table and TanStack Table for data tables.
- Keep the established TravelFlow visual language: operational admin UI, green primary actions, gold accent, dense tables/forms, visible borders, responsive stacking.

## 11. Environment Variables

Backend variables read by `src/config/env.ts`:

```text
NODE_ENV=development
PORT=5000
API_VERSION=v1
FRONTEND_URL=http://localhost:3000
MONGODB_URI=mongodb://127.0.0.1:27017/travelflow
JWT_SECRET=...
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=...
JWT_REFRESH_EXPIRES_IN=30d
BCRYPT_ROUNDS=12
```

Frontend variables/configuration:

```text
BACKEND_URL=http://127.0.0.1:5000   # used by Next rewrite
NEXT_PUBLIC_USE_API=true             # enables AuthProvider API hydration
```

Use strong, unique JWT secrets outside local development. Do not commit `.env` files or credentials.

## 12. Current API Areas

The registered API areas include:

```text
/api/v1/health
/api/v1/auth/*
/api/v1/dashboard/*
/api/v1/leads/*
/api/v1/customers/*
/api/v1/bookings/*
/api/v1/suppliers/*
/api/v1/branches/*
/api/v1/users/*
/api/v1/expenses/*
/api/v1/roles/*
/api/v1/receipts/*
/api/v1/quotations/*
/api/v1/templates/*
/api/v1/settings/*
/api/v1/notifications/*
/api/v1/invoices/*
```

Check the route files before adding an endpoint because route ordering matters. For example, `/users/agents` is intentionally registered before `/users/:id`.

## 13. Verification Expectations

There are build and lint scripts, but no test script is declared in either package manifest. For a change:

1. Run the narrowest relevant lint/build command.
2. Run the backend build for backend changes and frontend build/lint for frontend changes.
3. Manually verify authenticated flows when changing cookies, proxy behavior, permissions, branch scope, or API response shapes.
4. Check loading, empty, error, forbidden, and mutation-refresh states in UI work.

## 14. Known Repository Notes

`MEMORIES.md` tracks prior security/performance findings and fixes. Preserve those concerns when changing related code:

- Protected user/role routes require RBAC middleware.
- Customer lookup from leads must avoid loading all customers into memory; use a constrained database query.

This project has an `AGENTS.md` rule stating that the installed Next.js version may contain breaking changes. Before using unfamiliar Next.js APIs, inspect the relevant local Next.js documentation under `travelflow-frontend/node_modules/next/dist/docs/`.

## 15. Working Principles for Claude

- Read the nearest existing implementation before inventing a pattern.
- Keep tenant, branch, role, and permission checks server-side.
- Preserve the API client's centralized behavior: cookies, refresh, timeout, date revival, branch query, error handling, and invalidation.
- Prefer small, focused changes and existing abstractions.
- Do not reformat unrelated files or remove user changes.
- After editing, run an executable validation command and report any unrelated failures separately.
