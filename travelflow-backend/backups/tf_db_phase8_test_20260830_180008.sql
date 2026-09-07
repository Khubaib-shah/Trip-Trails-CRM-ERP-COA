--
-- PostgreSQL database dump
--

\restrict 8Lf5BDHAwBTgQ4ZErahU99mD9JL9gWBnBXFYs5hYB7iHKpPBHm0WSGTI5d6FSQt

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: AccountType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AccountType" AS ENUM (
    'ASSET',
    'LIABILITY',
    'EQUITY',
    'REVENUE',
    'EXPENSE'
);


--
-- Name: JournalEntryStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."JournalEntryStatus" AS ENUM (
    'DRAFT',
    'POSTED',
    'REVERSED'
);


--
-- Name: NormalBalance; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."NormalBalance" AS ENUM (
    'DEBIT',
    'CREDIT'
);


--
-- Name: PeriodStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PeriodStatus" AS ENUM (
    'OPEN',
    'CLOSED'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Agency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Agency" (
    id uuid NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    code text NOT NULL,
    "contactEmail" text NOT NULL,
    "contactPhone" text NOT NULL,
    address text,
    city text NOT NULL,
    country text DEFAULT 'Pakistan'::text NOT NULL,
    currency text DEFAULT 'PKR'::text NOT NULL,
    "registrationNo" text,
    "logoUrl" text,
    "primaryColor" text DEFAULT '#000000'::text NOT NULL,
    "emailAlerts" boolean DEFAULT true NOT NULL,
    "smsAlerts" boolean DEFAULT false NOT NULL,
    "dailyReports" boolean DEFAULT true NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Booking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Booking" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "bookingRef" text NOT NULL,
    pnr text DEFAULT ''::text NOT NULL,
    "ticketNumber" text,
    "customerId" uuid NOT NULL,
    "supplierId" uuid NOT NULL,
    "branchId" uuid NOT NULL,
    "agentId" uuid NOT NULL,
    "leadId" uuid,
    airline text NOT NULL,
    "departureCity" text NOT NULL,
    "arrivalCity" text NOT NULL,
    "departureDate" timestamp(3) without time zone NOT NULL,
    "returnDate" timestamp(3) without time zone,
    "costPrice" double precision NOT NULL,
    "salePrice" double precision NOT NULL,
    profit double precision NOT NULL,
    "profitMargin" double precision NOT NULL,
    "bookingStatus" text DEFAULT 'confirmed'::text NOT NULL,
    "paymentStatus" text DEFAULT 'unpaid'::text NOT NULL,
    "amountReceived" double precision NOT NULL,
    balance double precision NOT NULL,
    notes text,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: BookingActivity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingActivity" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "bookingId" uuid NOT NULL,
    type text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: BookingDocument; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."BookingDocument" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "bookingId" uuid NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type text NOT NULL,
    "uploadedBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Branch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Branch" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    city text NOT NULL,
    address text,
    phone text,
    currency text DEFAULT 'PKR'::text,
    "isHeadOffice" boolean DEFAULT false NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: ChartOfAccount; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ChartOfAccount" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    type public."AccountType" NOT NULL,
    "parentAccountId" uuid,
    "isActive" boolean DEFAULT true NOT NULL,
    "normalBalance" public."NormalBalance" NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Counter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Counter" (
    id text NOT NULL,
    seq integer DEFAULT 0 NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Customer" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "customerRef" text NOT NULL,
    type text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    "companyName" text,
    "businessType" text,
    "taxNumber" text,
    email text,
    phone text NOT NULL,
    whatsapp text,
    "dateOfBirth" timestamp(3) without time zone,
    gender text,
    cnic text,
    "passportNumber" text,
    "passportExpiry" timestamp(3) without time zone,
    nationality text,
    address text,
    city text,
    country text,
    "emergencyContactName" text,
    "emergencyContactPhone" text,
    "internalNotes" text,
    status text DEFAULT 'active'::text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CustomerDocument; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomerDocument" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "customerId" uuid NOT NULL,
    "documentType" text NOT NULL,
    "fileName" text NOT NULL,
    "fileSize" integer NOT NULL,
    "mimeType" text NOT NULL,
    "fileUrl" text NOT NULL,
    notes text,
    "uploadedBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CustomerNote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomerNote" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "customerId" uuid NOT NULL,
    note text NOT NULL,
    "addedBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Expense; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Expense" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid NOT NULL,
    "expenseRef" text NOT NULL,
    title text NOT NULL,
    category text NOT NULL,
    amount double precision NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "paidTo" text,
    "paymentMethod" text NOT NULL,
    "receiptUrl" text,
    notes text,
    "recordedById" uuid NOT NULL,
    status text DEFAULT 'approved'::text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: FiscalPeriod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."FiscalPeriod" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    name text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone NOT NULL,
    status public."PeriodStatus" DEFAULT 'OPEN'::public."PeriodStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: IdMapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."IdMapping" (
    collection text NOT NULL,
    "oldId" text NOT NULL,
    "newId" uuid NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Invoice" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid,
    "invoiceRef" text NOT NULL,
    "bookingId" uuid,
    "customerId" uuid NOT NULL,
    subtotal double precision NOT NULL,
    tax double precision NOT NULL,
    total double precision NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    "dueDate" timestamp(3) without time zone,
    "paidAt" timestamp(3) without time zone,
    notes text,
    terms text,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: InvoiceLine; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InvoiceLine" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "invoiceId" uuid NOT NULL,
    description text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    "unitPrice" double precision NOT NULL,
    amount double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: JournalEntry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."JournalEntry" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid,
    "entryNumber" text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    reference text,
    description text NOT NULL,
    status public."JournalEntryStatus" DEFAULT 'DRAFT'::public."JournalEntryStatus" NOT NULL,
    "sourceModule" text,
    "sourceId" text,
    "createdBy" uuid NOT NULL,
    "postedAt" timestamp(3) without time zone,
    "reversedAt" timestamp(3) without time zone,
    "reversingEntryId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: JournalLine; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."JournalLine" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "journalEntryId" uuid NOT NULL,
    "accountId" uuid NOT NULL,
    debit double precision NOT NULL,
    credit double precision NOT NULL,
    currency text DEFAULT 'PKR'::text NOT NULL,
    "exchangeRate" double precision NOT NULL,
    "baseDebit" double precision NOT NULL,
    "baseCredit" double precision NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Lead; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Lead" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid NOT NULL,
    "leadRef" text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    whatsapp text,
    email text,
    destination text NOT NULL,
    "travelDate" timestamp(3) without time zone,
    budget double precision,
    adults integer DEFAULT 1 NOT NULL,
    children integer DEFAULT 0 NOT NULL,
    "specialRequirements" text,
    source text NOT NULL,
    status text DEFAULT 'new'::text NOT NULL,
    "assignedAgentId" uuid,
    notes text,
    "lastContactedAt" timestamp(3) without time zone,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: LeadActivity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."LeadActivity" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "leadId" uuid NOT NULL,
    type text NOT NULL,
    description text NOT NULL,
    outcome text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Notification" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid,
    "recipientId" uuid NOT NULL,
    type text DEFAULT 'info'::text NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    "entityType" text,
    "entityId" text,
    "isRead" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Quotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Quotation" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "quotationNumber" text NOT NULL,
    title text NOT NULL,
    "leadId" uuid,
    "customerId" uuid,
    "branchId" uuid NOT NULL,
    "consultantId" uuid NOT NULL,
    "travelType" text NOT NULL,
    destination text NOT NULL,
    "departureDate" timestamp(3) without time zone,
    "returnDate" timestamp(3) without time zone,
    adults integer DEFAULT 0 NOT NULL,
    children integer DEFAULT 0 NOT NULL,
    infants integer DEFAULT 0 NOT NULL,
    currency text DEFAULT 'PKR'::text NOT NULL,
    subtotal double precision NOT NULL,
    "agencyFee" double precision NOT NULL,
    discount double precision NOT NULL,
    "taxTotal" double precision NOT NULL,
    total double precision NOT NULL,
    "estimatedProfit" double precision NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    "validUntil" timestamp(3) without time zone,
    "customerNotes" text,
    "internalNotes" text,
    "customerName" text,
    "customerPhone" text,
    "customerEmail" text,
    "termsTemplateId" uuid,
    terms text,
    "authorizedSignature" text,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: QuotationAttachment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationAttachment" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "quotationId" uuid NOT NULL,
    "fileName" text NOT NULL,
    "fileUrl" text NOT NULL,
    "mimeType" text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: QuotationItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationItem" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "quotationId" uuid NOT NULL,
    "serviceCategory" text NOT NULL,
    title text NOT NULL,
    description text,
    quantity integer DEFAULT 1 NOT NULL,
    unit text DEFAULT 'Person'::text NOT NULL,
    "costPrice" double precision NOT NULL,
    "sellingPrice" double precision NOT NULL,
    total double precision NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: QuotationTax; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationTax" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "quotationId" uuid NOT NULL,
    "taxName" text NOT NULL,
    "taxType" text NOT NULL,
    "taxValue" double precision NOT NULL,
    "taxAmount" double precision NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: QuotationVersion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."QuotationVersion" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "quotationId" uuid NOT NULL,
    version integer NOT NULL,
    changes text NOT NULL,
    "createdBy" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Receipt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Receipt" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid,
    "receiptRef" text NOT NULL,
    "bookingId" uuid NOT NULL,
    "customerId" uuid NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" text NOT NULL,
    notes text,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: RecentActivity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RecentActivity" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid,
    type text NOT NULL,
    title text NOT NULL,
    detail text NOT NULL,
    "createdBy" text NOT NULL,
    "createdByUserId" uuid,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Role" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    permissions text[],
    color text NOT NULL,
    "textColor" text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Supplier; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Supplier" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    "contactPerson" text,
    email text,
    phone text,
    website text,
    address text,
    city text,
    country text,
    "taxId" text,
    balance double precision NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: SupplierPayment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SupplierPayment" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid,
    "supplierId" uuid NOT NULL,
    "paymentRef" text NOT NULL,
    amount double precision NOT NULL,
    "paymentMethod" text NOT NULL,
    notes text,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "recordedById" uuid,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Template" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    content text NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: TokenBlacklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TokenBlacklist" (
    id uuid NOT NULL,
    token text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id uuid NOT NULL,
    "agencyId" uuid NOT NULL,
    "branchId" uuid NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    phone text,
    role text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    "avatarUrl" text,
    "lastLoginAt" timestamp(3) without time zone,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Data for Name: Agency; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Agency" (id, name, slug, code, "contactEmail", "contactPhone", address, city, country, currency, "registrationNo", "logoUrl", "primaryColor", "emailAlerts", "smsAlerts", "dailyReports", status, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
a1000000-0000-0000-0000-000000000001	TripTrails Travel & Tourism	triptrails-01	TT	info@triptrails.pk	+92-42-35789012	G-64, Al Latif Center, Main Boulevard, Gulberg III	Lahore	Pakistan	PKR	SECP-TRAILS-2014	\N	#1a56db	t	t	t	active	f	\N	2026-08-30 11:28:27.599	2026-08-30 11:28:27.599
\.


--
-- Data for Name: Booking; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Booking" (id, "agencyId", "bookingRef", pnr, "ticketNumber", "customerId", "supplierId", "branchId", "agentId", "leadId", airline, "departureCity", "arrivalCity", "departureDate", "returnDate", "costPrice", "salePrice", profit, "profitMargin", "bookingStatus", "paymentStatus", "amountReceived", balance, notes, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
70010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-001	PNRA1000	TKT-202600001	40010000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	60010000-0000-0000-0000-000000000001	Emirates	Lahore	London	2025-10-07 12:47:00	\N	185000	225000	40000	17.77777777777778	confirmed	paid	225000	0	\N	f	\N	2025-09-27 12:47:00	2026-08-30 11:28:28.672
70020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-002	PNRB1137	TKT-202600002	40030000-0000-0000-0000-000000000001	50010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222206	\N	PIA	Lahore	Karachi	2025-11-04 04:26:00	\N	35000	48000	13000	27.08333333333333	confirmed	paid	48000	0	\N	f	\N	2025-10-23 04:26:00	2026-08-30 11:28:28.684
70030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-003	PNRC1274	TKT-202600003	40050000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Emirates	Dubai	London	2025-10-16 06:59:00	\N	420000	520000	100000	19.23076923076923	confirmed	paid	520000	0	\N	f	\N	2025-10-01 06:59:00	2026-08-30 11:28:28.69
70040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-004	PNRD1411	TKT-202600004	40020000-0000-0000-0000-000000000001	50020000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	60020000-0000-0000-0000-000000000001	Airblue	Lahore	Istanbul	2025-12-03 11:34:00	\N	95000	135000	40000	29.62962962962963	confirmed	paid	135000	0	\N	f	\N	2025-11-22 11:34:00	2026-08-30 11:28:28.698
70050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-005	PNRE1548	TKT-202600005	40060000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222206	60060000-0000-0000-0000-000000000001	Emirates	Lahore	Paris	2025-12-13 09:03:00	\N	210000	275000	65000	23.63636363636364	confirmed	paid	275000	0	\N	f	\N	2025-11-24 09:03:00	2026-08-30 11:28:28.704
70060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-006	PNRF1685	TKT-202600006	40040000-0000-0000-0000-000000000001	50010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	22222222-2222-2222-2222-222222222208	60040000-0000-0000-0000-000000000001	PIA	Karachi	Jeddah	2025-12-14 07:00:00	\N	150000	195000	45000	23.07692307692308	confirmed	paid	195000	0	\N	f	\N	2025-12-07 07:00:00	2026-08-30 11:28:28.71
70070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-007	PNRG1822	TKT-202600007	40080000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Emirates	Dubai	Male	2025-12-12 05:03:00	\N	280000	380000	100000	26.31578947368421	confirmed	paid	380000	0	\N	f	\N	2025-12-02 05:03:00	2026-08-30 11:28:28.718
70080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-008	PNRH1959	TKT-202600008	40090000-0000-0000-0000-000000000001	50010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	60070000-0000-0000-0000-000000000001	PIA	Lahore	Gilgit	2026-02-05 08:00:00	\N	42000	65000	23000	35.38461538461539	confirmed	paid	65000	0	\N	f	\N	2026-01-21 08:00:00	2026-08-30 11:28:28.723
70090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-009	PNRI2096	TKT-202600009	40070000-0000-0000-0000-000000000001	50020000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222206	\N	Airblue	Lahore	Dubai	2026-01-25 06:27:00	\N	65000	88000	23000	26.13636363636364	confirmed	paid	88000	0	\N	f	\N	2026-01-04 06:27:00	2026-08-30 11:28:28.73
70100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-010	PNRJ2233	TKT-202600010	40100000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	\N	Emirates	Lahore	Singapore	2026-03-29 11:49:00	\N	175000	230000	55000	23.91304347826087	confirmed	paid	230000	0	\N	f	\N	2026-03-14 11:49:00	2026-08-30 11:28:28.737
70110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-011	PNRK2370	TKT-202600011	40110000-0000-0000-0000-000000000001	50090000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Air Arabia	Sharjah	Islamabad	2026-03-25 05:09:00	\N	95000	130000	35000	26.92307692307692	confirmed	paid	130000	0	\N	f	\N	2026-03-05 05:09:00	2026-08-30 11:28:28.742
70120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-012	PNRL2507	\N	40120000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Emirates	Dubai	Bali	2026-04-07 08:22:00	\N	310000	420000	110000	26.19047619047619	confirmed	partial	210000	210000	\N	f	\N	2026-03-23 08:22:00	2026-08-30 11:28:28.748
70130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-013	PNRM2644	TKT-202600013	40130000-0000-0000-0000-000000000001	50020000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	22222222-2222-2222-2222-222222222208	\N	Airblue	Karachi	Lahore	2026-03-20 06:16:00	\N	28000	38000	10000	26.31578947368421	confirmed	paid	38000	0	\N	f	\N	2026-03-01 06:16:00	2026-08-30 11:28:28.753
70140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-014	PNRN2781	TKT-202600014	40140000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222206	\N	Emirates	Lahore	Dubai	2026-04-10 05:15:00	\N	72000	95000	23000	24.21052631578947	confirmed	paid	95000	0	\N	f	\N	2026-03-21 05:15:00	2026-08-30 11:28:28.759
70150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-015	PNRO2918	TKT-202600015	40150000-0000-0000-0000-000000000001	50110000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	22222222-2222-2222-2222-222222222209	60190000-0000-0000-0000-000000000001	PIA	Islamabad	Skardu	2026-05-10 12:03:00	\N	55000	78000	23000	29.48717948717949	confirmed	paid	78000	0	\N	f	\N	2026-04-20 12:03:00	2026-08-30 11:28:28.765
70160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-016	PNRP3055	TKT-202600016	40160000-0000-0000-0000-000000000001	50010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	22222222-2222-2222-2222-222222222210	\N	PIA	Peshawar	Karachi	2026-05-03 12:14:00	\N	32000	45000	13000	28.88888888888889	confirmed	paid	45000	0	\N	f	\N	2026-04-22 12:14:00	2026-08-30 11:28:28.77
70170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-017	PNRQ3192	\N	40170000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	60030000-0000-0000-0000-000000000001	Emirates	Lahore	London	2026-05-15 09:03:00	\N	195000	245000	50000	20.40816326530612	confirmed	partial	120000	125000	\N	f	\N	2026-04-26 09:03:00	2026-08-30 11:28:28.775
70180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-018	PNRR3329	TKT-202600018	40180000-0000-0000-0000-000000000001	50100000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	22222222-2222-2222-2222-222222222208	\N	Thai Airways	Karachi	Bangkok	2026-05-27 10:07:00	\N	85000	115000	30000	26.08695652173913	confirmed	paid	115000	0	\N	f	\N	2026-05-20 10:07:00	2026-08-30 11:28:28.782
70190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-019	PNRS3466	TKT-202600019	40190000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Emirates	Dubai	Singapore	2026-05-29 06:24:00	\N	165000	220000	55000	25	confirmed	paid	220000	0	\N	f	\N	2026-05-12 06:24:00	2026-08-30 11:28:28.787
70200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-020	PNRT3603	TKT-202600020	40200000-0000-0000-0000-000000000001	50140000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	22222222-2222-2222-2222-222222222209	\N	Turkish Airlines	Islamabad	Istanbul	2026-05-22 06:11:00	\N	125000	170000	45000	26.47058823529412	confirmed	paid	170000	0	\N	f	\N	2026-05-13 06:11:00	2026-08-30 11:28:28.793
70210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-021	PNRU3740	\N	40210000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222206	60230000-0000-0000-0000-000000000001	Emirates	Lahore	Dubai	2026-06-22 12:37:00	\N	68000	92000	24000	26.08695652173913	confirmed	partial	50000	42000	\N	f	\N	2026-06-01 12:37:00	2026-08-30 11:28:28.8
70220000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-022	PNRV3877	TKT-202600022	40220000-0000-0000-0000-000000000001	50010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	\N	PIA	Lahore	Gilgit	2026-06-25 08:42:00	\N	45000	68000	23000	33.82352941176471	confirmed	paid	68000	0	\N	f	\N	2026-06-10 08:42:00	2026-08-30 11:28:28.805
70230000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-023	PNRW4014	\N	40230000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Emirates	Dubai	London	2026-07-10 07:34:00	\N	380000	480000	100000	20.83333333333334	confirmed	partial	240000	240000	\N	f	\N	2026-06-23 07:34:00	2026-08-30 11:28:28.813
70240000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-024	PNRX4151	TKT-202600024	40240000-0000-0000-0000-000000000001	50020000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	22222222-2222-2222-2222-222222222208	\N	Airblue	Karachi	Lahore	2026-07-06 04:59:00	\N	30000	42000	12000	28.57142857142857	confirmed	paid	42000	0	\N	f	\N	2026-06-24 04:59:00	2026-08-30 11:28:28.821
70250000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-025	PNRY4288	TKT-202600025	40250000-0000-0000-0000-000000000001	50090000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	22222222-2222-2222-2222-222222222210	\N	Air Arabia	Peshawar	Sharjah	2026-08-05 06:17:00	\N	78000	105000	27000	25.71428571428571	confirmed	paid	105000	0	\N	f	\N	2026-07-23 06:17:00	2026-08-30 11:28:28.826
70260000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-026	PNRZ4425	\N	40260000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	\N	Emirates	Lahore	Male	2026-08-04 07:39:00	\N	250000	340000	90000	26.47058823529412	confirmed	unpaid	0	340000	\N	f	\N	2026-07-21 07:39:00	2026-08-30 11:28:28.834
70270000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-027	PNRA4562	TKT-202600027	40270000-0000-0000-0000-000000000001	50140000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	22222222-2222-2222-2222-222222222209	\N	Turkish Airlines	Islamabad	London	2026-08-15 12:11:00	\N	190000	240000	50000	20.83333333333334	confirmed	paid	240000	0	\N	f	\N	2026-07-25 12:11:00	2026-08-30 11:28:28.84
70280000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-028	PNRB4699	TKT-202600028	40280000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222206	\N	Emirates	Lahore	Dubai	2026-08-16 11:10:00	\N	62000	85000	23000	27.05882352941176	confirmed	paid	85000	0	\N	f	\N	2026-08-02 11:10:00	2026-08-30 11:28:28.845
70290000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-029	PNRC4836	TKT-202600029	40290000-0000-0000-0000-000000000001	50010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	22222222-2222-2222-2222-222222222208	\N	PIA	Karachi	Islamabad	2026-08-31 08:17:00	\N	38000	52000	14000	26.92307692307692	confirmed	paid	52000	0	\N	f	\N	2026-08-16 08:17:00	2026-08-30 11:28:28.852
70300000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	BK-2026-030	PNRD4973	\N	40300000-0000-0000-0000-000000000001	50030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	22222222-2222-2222-2222-222222222207	\N	Emirates	Dubai	Bali	2026-09-06 05:03:00	\N	295000	395000	100000	25.31645569620253	confirmed	unpaid	0	395000	\N	f	\N	2026-08-26 05:03:00	2026-08-30 11:28:28.857
\.


--
-- Data for Name: BookingActivity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."BookingActivity" (id, "agencyId", "bookingId", type, title, description, "createdBy", "createdAt", "updatedAt") FROM stdin;
05f4329d-ba30-4b18-8ddc-c105c1e3e517	a1000000-0000-0000-0000-000000000001	70010000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-09-07 04:52:00	2026-08-30 11:28:28.919
50fae958-7b81-4a68-b316-b88c9f37f3dc	a1000000-0000-0000-0000-000000000001	70010000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 225,000 received	Zainab Noor	2025-09-10 04:52:00	2026-08-30 11:28:28.919
8b0a2ea0-f3bc-42ed-a1f0-6efaae12269e	a1000000-0000-0000-0000-000000000001	70010000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Sara Khan	2025-09-14 04:52:00	2026-08-30 11:28:28.919
677b8404-5850-4b6d-b6b7-97f020eaaed3	a1000000-0000-0000-0000-000000000001	70020000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-10-18 08:15:00	2026-08-30 11:28:28.919
25eb3bc0-95d5-442d-bc43-d0b88dd4f325	a1000000-0000-0000-0000-000000000001	70020000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 48,000 received	Zainab Noor	2025-10-21 08:15:00	2026-08-30 11:28:28.919
0febb96e-db11-4858-967b-19b8b40ce0a1	a1000000-0000-0000-0000-000000000001	70030000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-10-05 08:11:00	2026-08-30 11:28:28.919
73d75a4f-3d45-42f3-88bb-0777503dc2c2	a1000000-0000-0000-0000-000000000001	70030000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 520,000 received	Zainab Noor	2025-10-08 08:11:00	2026-08-30 11:28:28.919
3889339f-8b7a-4520-80e9-dde21655e443	a1000000-0000-0000-0000-000000000001	70040000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-11-06 08:30:00	2026-08-30 11:28:28.919
cdf64061-2888-4c10-ad33-52a3cde44b78	a1000000-0000-0000-0000-000000000001	70040000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 135,000 received	Zainab Noor	2025-11-09 08:30:00	2026-08-30 11:28:28.919
60120c9d-db4a-47e9-aad3-b527c239b2dc	a1000000-0000-0000-0000-000000000001	70050000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-11-21 07:43:00	2026-08-30 11:28:28.919
e0a2f21b-3f7e-419e-b18c-2b85c20bf6b3	a1000000-0000-0000-0000-000000000001	70050000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 275,000 received	Zainab Noor	2025-11-24 07:43:00	2026-08-30 11:28:28.919
eb709ad3-6347-4112-b7cc-df87c6a1ca91	a1000000-0000-0000-0000-000000000001	70050000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Sara Khan	2025-11-28 07:43:00	2026-08-30 11:28:28.919
d03427df-6786-4f19-a7e4-d85a8fdfd4fb	a1000000-0000-0000-0000-000000000001	70060000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-12-04 12:41:00	2026-08-30 11:28:28.919
a20787f1-c73d-4739-9622-ff2886120719	a1000000-0000-0000-0000-000000000001	70060000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 195,000 received	Zainab Noor	2025-12-07 12:41:00	2026-08-30 11:28:28.919
81cf3a48-5c59-4c59-b4ac-cd1a38e8bdb8	a1000000-0000-0000-0000-000000000001	70070000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2025-12-07 06:55:00	2026-08-30 11:28:28.919
c2db1bbd-9683-4b27-9b3c-5df3a8e24669	a1000000-0000-0000-0000-000000000001	70070000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 380,000 received	Zainab Noor	2025-12-10 06:55:00	2026-08-30 11:28:28.919
1c99585e-9239-4ee5-8697-9fbe115d567a	a1000000-0000-0000-0000-000000000001	70080000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-01-04 04:24:00	2026-08-30 11:28:28.919
d6f9ecdc-b86b-47ba-9d32-9eacbaf3f85d	a1000000-0000-0000-0000-000000000001	70080000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 65,000 received	Zainab Noor	2026-01-07 04:24:00	2026-08-30 11:28:28.919
4f8e9455-4f94-42c8-9a9e-190e1e8cf66d	a1000000-0000-0000-0000-000000000001	70090000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-01-15 10:14:00	2026-08-30 11:28:28.919
ed668b2e-59ad-4076-9ba4-b2747dccb6f9	a1000000-0000-0000-0000-000000000001	70090000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 88,000 received	Zainab Noor	2026-01-18 10:14:00	2026-08-30 11:28:28.919
dc90646e-1f2f-43bf-844d-b849d95f695a	a1000000-0000-0000-0000-000000000001	70090000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Ayesha Malik	2026-01-22 10:14:00	2026-08-30 11:28:28.919
18eef41e-c168-4b64-adee-d77750a13502	a1000000-0000-0000-0000-000000000001	70100000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-03-08 05:51:00	2026-08-30 11:28:28.919
be819425-f23e-4bcd-a75f-9d2be650dfd9	a1000000-0000-0000-0000-000000000001	70100000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 230,000 received	Zainab Noor	2026-03-11 05:51:00	2026-08-30 11:28:28.919
4fff6db8-e363-4516-9988-7ce862352db7	a1000000-0000-0000-0000-000000000001	70110000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-03-12 11:09:00	2026-08-30 11:28:28.919
d33f5bf6-2f27-4cf8-9ad6-dd0894d94a81	a1000000-0000-0000-0000-000000000001	70110000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 130,000 received	Zainab Noor	2026-03-15 11:09:00	2026-08-30 11:28:28.919
c7cdc2f2-32ea-4e7d-a927-a18474a389b1	a1000000-0000-0000-0000-000000000001	70120000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-03-03 05:38:00	2026-08-30 11:28:28.919
dce70e0f-1999-4a66-8cb9-60b21ff6bc6b	a1000000-0000-0000-0000-000000000001	70120000-0000-0000-0000-000000000001	payment	Partial Payment	Partial payment of Rs 210,000 received	Zainab Noor	2026-03-08 05:38:00	2026-08-30 11:28:28.919
8abb0951-ca52-4385-b4ef-b72ff409640a	a1000000-0000-0000-0000-000000000001	70130000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-03-02 11:41:00	2026-08-30 11:28:28.919
c1c6896c-686a-4b59-83e0-61c26158b45f	a1000000-0000-0000-0000-000000000001	70130000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 38,000 received	Zainab Noor	2026-03-05 11:41:00	2026-08-30 11:28:28.919
f8fb59f5-e432-4023-af4d-9f28bd604436	a1000000-0000-0000-0000-000000000001	70130000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Ayesha Malik	2026-03-09 11:41:00	2026-08-30 11:28:28.919
48793726-ba30-4bf2-8dda-10e6f8084f2d	a1000000-0000-0000-0000-000000000001	70140000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-03-02 12:26:00	2026-08-30 11:28:28.919
68eb4fee-1f2c-4eec-a53d-a6e4b2d3e912	a1000000-0000-0000-0000-000000000001	70140000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 95,000 received	Zainab Noor	2026-03-05 12:26:00	2026-08-30 11:28:28.919
1aa7d341-9295-46a7-ae94-4a99f3199a18	a1000000-0000-0000-0000-000000000001	70150000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-04-24 07:46:00	2026-08-30 11:28:28.919
a2733be2-29ff-4db5-aa08-7d9aca3bf584	a1000000-0000-0000-0000-000000000001	70150000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 78,000 received	Zainab Noor	2026-04-27 07:46:00	2026-08-30 11:28:28.919
eea42812-a40f-4fa5-b9a1-7c58a5e4f839	a1000000-0000-0000-0000-000000000001	70160000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-04-12 11:21:00	2026-08-30 11:28:28.919
924d13e7-da35-4f48-8699-d46554c63393	a1000000-0000-0000-0000-000000000001	70160000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 45,000 received	Zainab Noor	2026-04-15 11:21:00	2026-08-30 11:28:28.919
6392a49a-698b-455d-9207-53dd30f19043	a1000000-0000-0000-0000-000000000001	70170000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-04-24 12:42:00	2026-08-30 11:28:28.919
c2b30d74-bb16-4dec-8b0b-6285136bf95f	a1000000-0000-0000-0000-000000000001	70170000-0000-0000-0000-000000000001	payment	Partial Payment	Partial payment of Rs 120,000 received	Zainab Noor	2026-04-29 12:42:00	2026-08-30 11:28:28.919
6972631f-fc7b-43ac-b536-8c3355ae7443	a1000000-0000-0000-0000-000000000001	70170000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Sara Khan	2026-05-01 12:42:00	2026-08-30 11:28:28.919
e0b491d9-229e-4fee-a09c-b18d59867c90	a1000000-0000-0000-0000-000000000001	70180000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-05-10 09:48:00	2026-08-30 11:28:28.919
7b20d9be-3cfe-4d9d-a094-d5596c9245ce	a1000000-0000-0000-0000-000000000001	70180000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 115,000 received	Zainab Noor	2026-05-13 09:48:00	2026-08-30 11:28:28.919
202ab5a4-f083-4843-acff-340874c4440f	a1000000-0000-0000-0000-000000000001	70190000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-05-08 08:17:00	2026-08-30 11:28:28.919
6d079217-556b-4b46-a335-02b1ba38c047	a1000000-0000-0000-0000-000000000001	70190000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 220,000 received	Zainab Noor	2026-05-11 08:17:00	2026-08-30 11:28:28.919
b48c4346-ec1c-4079-9225-6db7b53f34f6	a1000000-0000-0000-0000-000000000001	70200000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-05-21 09:23:00	2026-08-30 11:28:28.919
d54b4cd0-5dbb-4340-8b71-5616c76a51cd	a1000000-0000-0000-0000-000000000001	70200000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 170,000 received	Zainab Noor	2026-05-24 09:23:00	2026-08-30 11:28:28.919
a0749900-f89c-4e9b-9430-367cb6f0619c	a1000000-0000-0000-0000-000000000001	70210000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-06-09 11:53:00	2026-08-30 11:28:28.919
39d9e3bb-f035-4e78-a80a-75db857b2542	a1000000-0000-0000-0000-000000000001	70210000-0000-0000-0000-000000000001	payment	Partial Payment	Partial payment of Rs 50,000 received	Zainab Noor	2026-06-14 11:53:00	2026-08-30 11:28:28.919
b8f19ad8-4391-487d-8341-4a6c6ce6f1c6	a1000000-0000-0000-0000-000000000001	70210000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Sara Khan	2026-06-16 11:53:00	2026-08-30 11:28:28.919
5a0c3baa-fdc3-46a0-a2b5-320a7bcc4e28	a1000000-0000-0000-0000-000000000001	70220000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-06-03 07:38:00	2026-08-30 11:28:28.919
cd5251d5-8afd-48ee-89d0-7bd2e9a9f9a4	a1000000-0000-0000-0000-000000000001	70220000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 68,000 received	Zainab Noor	2026-06-06 07:38:00	2026-08-30 11:28:28.919
afe6253b-033a-4825-9e9d-49c4f98cd988	a1000000-0000-0000-0000-000000000001	70230000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-06-08 04:08:00	2026-08-30 11:28:28.919
8ec1cbab-7935-4ab8-a89e-153993b2cca1	a1000000-0000-0000-0000-000000000001	70230000-0000-0000-0000-000000000001	payment	Partial Payment	Partial payment of Rs 240,000 received	Zainab Noor	2026-06-13 04:08:00	2026-08-30 11:28:28.919
589591ec-34b9-40cf-8ca2-f009681b85de	a1000000-0000-0000-0000-000000000001	70240000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-06-09 08:38:00	2026-08-30 11:28:28.919
8b2b12d7-f860-438b-b660-b6ebe3601ac8	a1000000-0000-0000-0000-000000000001	70240000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 42,000 received	Zainab Noor	2026-06-12 08:38:00	2026-08-30 11:28:28.919
428941b2-bbc0-4dfd-837e-ce9c1c68d77e	a1000000-0000-0000-0000-000000000001	70250000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-07-26 08:17:00	2026-08-30 11:28:28.919
9fec877b-cd2e-4757-a353-7f52383f5a60	a1000000-0000-0000-0000-000000000001	70250000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 105,000 received	Zainab Noor	2026-07-29 08:17:00	2026-08-30 11:28:28.919
69d1fd7c-bbd2-41b8-bb42-09827e59651c	a1000000-0000-0000-0000-000000000001	70250000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Sara Khan	2026-08-02 08:17:00	2026-08-30 11:28:28.919
b5bf7106-fb6a-4219-a539-ddc15b067363	a1000000-0000-0000-0000-000000000001	70260000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-07-01 10:28:00	2026-08-30 11:28:28.919
7f6c76f6-d9e8-4c33-89b4-6043f67ae62a	a1000000-0000-0000-0000-000000000001	70270000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-07-22 07:45:00	2026-08-30 11:28:28.919
02d6a860-8b45-484d-abf5-477fa72cf202	a1000000-0000-0000-0000-000000000001	70270000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 240,000 received	Zainab Noor	2026-07-25 07:45:00	2026-08-30 11:28:28.919
d510895c-66dc-40a6-9d55-23835fc6b7e4	a1000000-0000-0000-0000-000000000001	70280000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-08-22 10:54:00	2026-08-30 11:28:28.919
f6140da7-63f9-44b1-a57c-a3d15c4587a4	a1000000-0000-0000-0000-000000000001	70280000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 85,000 received	Zainab Noor	2026-08-25 10:54:00	2026-08-30 11:28:28.919
9990d8de-701c-4a8d-9ab3-fb6eafacbaf5	a1000000-0000-0000-0000-000000000001	70290000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-08-02 09:22:00	2026-08-30 11:28:28.919
46c49f68-59ae-49af-bb27-f06192bdac9c	a1000000-0000-0000-0000-000000000001	70290000-0000-0000-0000-000000000001	payment	Payment Received	Full payment of Rs 52,000 received	Zainab Noor	2026-08-05 09:22:00	2026-08-30 11:28:28.919
b252b1ef-8b7d-4b5e-b6d7-3fe85be412d6	a1000000-0000-0000-0000-000000000001	70290000-0000-0000-0000-000000000001	document	Ticket Uploaded	E-ticket uploaded to booking	Sara Khan	2026-08-09 09:22:00	2026-08-30 11:28:28.919
9613756d-a911-4262-9da7-4b466d4ec2bb	a1000000-0000-0000-0000-000000000001	70300000-0000-0000-0000-000000000001	created	Booking Created	Initial reservation made	System	2026-08-02 11:15:00	2026-08-30 11:28:28.919
\.


--
-- Data for Name: BookingDocument; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."BookingDocument" (id, "agencyId", "bookingId", name, url, type, "uploadedBy", "createdAt", "updatedAt") FROM stdin;
0414ce3c-2513-4414-8f15-4e0d785d3259	a1000000-0000-0000-0000-000000000001	70010000-0000-0000-0000-000000000001	booking_1_document.pdf	/uploads/bookings/bk001_doc.pdf	pdf	Sara Khan	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
294ede6a-2b70-4060-961a-2506e28aa779	a1000000-0000-0000-0000-000000000001	70020000-0000-0000-0000-000000000001	booking_2_document.pdf	/uploads/bookings/bk002_doc.pdf	pdf	Ayesha Malik	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
4aaed659-c9f4-4042-94e7-bcbffd3ce200	a1000000-0000-0000-0000-000000000001	70030000-0000-0000-0000-000000000001	booking_3_document.pdf	/uploads/bookings/bk003_doc.pdf	pdf	Sara Khan	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
9fee0939-d6ed-49cb-955b-f55dfd3c9d3f	a1000000-0000-0000-0000-000000000001	70040000-0000-0000-0000-000000000001	booking_4_document.pdf	/uploads/bookings/bk004_doc.pdf	pdf	Sara Khan	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
ff9336aa-0113-4135-9055-7a1062273ef0	a1000000-0000-0000-0000-000000000001	70050000-0000-0000-0000-000000000001	booking_5_document.pdf	/uploads/bookings/bk005_doc.pdf	pdf	Omar Farooq	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
8418d676-bf48-46f2-a642-f048282d41a3	a1000000-0000-0000-0000-000000000001	70060000-0000-0000-0000-000000000001	booking_6_document.pdf	/uploads/bookings/bk006_doc.pdf	pdf	Zainab Noor	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
09e62285-e305-4382-8e7b-c7f103750bed	a1000000-0000-0000-0000-000000000001	70070000-0000-0000-0000-000000000001	booking_7_document.pdf	/uploads/bookings/bk007_doc.pdf	pdf	Omar Farooq	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
06448b2a-4b3e-4267-9b43-d6c74bf39f5f	a1000000-0000-0000-0000-000000000001	70080000-0000-0000-0000-000000000001	booking_8_document.pdf	/uploads/bookings/bk008_doc.pdf	pdf	Omar Farooq	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
3d13e876-75ee-457b-9dd0-48fa42307f58	a1000000-0000-0000-0000-000000000001	70090000-0000-0000-0000-000000000001	booking_9_document.pdf	/uploads/bookings/bk009_doc.pdf	pdf	Ayesha Malik	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
e12c95d2-1798-48ed-97ba-1f2527942088	a1000000-0000-0000-0000-000000000001	70100000-0000-0000-0000-000000000001	booking_10_document.pdf	/uploads/bookings/bk010_doc.pdf	pdf	Sara Khan	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
0f51e677-320a-43db-b764-43847adb1924	a1000000-0000-0000-0000-000000000001	70110000-0000-0000-0000-000000000001	booking_11_document.pdf	/uploads/bookings/bk011_doc.pdf	pdf	Sara Khan	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
d1bd1258-b229-434d-82ac-07d207f931cd	a1000000-0000-0000-0000-000000000001	70120000-0000-0000-0000-000000000001	booking_12_document.pdf	/uploads/bookings/bk012_doc.pdf	pdf	Zainab Noor	2026-08-30 11:28:28.959	2026-08-30 11:28:28.959
\.


--
-- Data for Name: Branch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Branch" (id, "agencyId", name, code, city, address, phone, currency, "isHeadOffice", status, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
11111111-1111-1111-1111-111111111101	a1000000-0000-0000-0000-000000000001	Lahore Head Office	LHE	Lahore	G-64, Al Latif Center, Main Boulevard, Gulberg III, Lahore	+92-42-35789012	PKR	t	active	f	\N	2026-08-30 11:28:27.616	2026-08-30 11:28:27.616
11111111-1111-1111-1111-111111111102	a1000000-0000-0000-0000-000000000001	Karachi Branch	KHI	Karachi	Shop # G-11, Al-Haq Pride, Opp. Madinah Masjid, Block 13-D/1, Gulshan-e-Iqbal	+92-21-34891234	PKR	f	active	f	\N	2026-08-30 11:28:27.616	2026-08-30 11:28:27.616
11111111-1111-1111-1111-111111111103	a1000000-0000-0000-0000-000000000001	Islamabad Branch	ISB	Islamabad	Office 305, 3rd Floor, Sahara Mall, F-7 Markaz, Islamabad	+92-51-2654321	PKR	f	active	f	\N	2026-08-30 11:28:27.616	2026-08-30 11:28:27.616
11111111-1111-1111-1111-111111111104	a1000000-0000-0000-0000-000000000001	Peshawar Branch	PSW	Peshawar	UG 350, Deans Trade Center, Peshawar	+92-91-5701234	PKR	f	active	f	\N	2026-08-30 11:28:27.616	2026-08-30 11:28:27.616
11111111-1111-1111-1111-111111111105	a1000000-0000-0000-0000-000000000001	Dubai Branch	DXB	Dubai	Office #103, 1st Floor, Al Fajar Complex, Near Oud Metha Bus Station, Dubai, UAE	+971-4-3301234	PKR	f	active	f	\N	2026-08-30 11:28:27.616	2026-08-30 11:28:27.616
\.


--
-- Data for Name: ChartOfAccount; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ChartOfAccount" (id, "agencyId", code, name, type, "parentAccountId", "isActive", "normalBalance", description, "createdAt", "updatedAt") FROM stdin;
c0010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	1000	Cash & Bank	ASSET	\N	t	DEBIT	\N	2025-09-13 10:31:00	2026-08-30 11:28:31.52
c0020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	1100	Accounts Receivable	ASSET	\N	t	DEBIT	\N	2025-09-03 04:33:00	2026-08-30 11:28:31.528
c0030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	1200	Prepaid Expenses	ASSET	\N	t	DEBIT	\N	2025-09-17 10:51:00	2026-08-30 11:28:31.533
c0040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	2000	Accounts Payable	LIABILITY	\N	t	CREDIT	\N	2025-09-21 10:32:00	2026-08-30 11:28:31.538
c0050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	2100	Unearned Revenue	LIABILITY	\N	t	CREDIT	\N	2025-09-08 04:37:00	2026-08-30 11:28:31.543
c0060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	2200	Tax Payable	LIABILITY	\N	t	CREDIT	\N	2025-09-20 09:48:00	2026-08-30 11:28:31.548
c0070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	3000	Owner's Equity	EQUITY	\N	t	CREDIT	\N	2025-09-10 10:54:00	2026-08-30 11:28:31.553
c0080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	3100	Retained Earnings	EQUITY	\N	t	CREDIT	\N	2025-09-24 06:11:00	2026-08-30 11:28:31.559
c0090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	4000	Flight Booking Revenue	REVENUE	\N	t	CREDIT	\N	2025-09-05 04:49:00	2026-08-30 11:28:31.565
c0100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	4100	Hotel Booking Revenue	REVENUE	\N	t	CREDIT	\N	2025-09-12 07:44:00	2026-08-30 11:28:31.57
c0110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	4200	Visa Service Revenue	REVENUE	\N	t	CREDIT	\N	2025-09-03 10:45:00	2026-08-30 11:28:31.576
c0120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	4300	Insurance Commission	REVENUE	\N	t	CREDIT	\N	2025-09-21 12:48:00	2026-08-30 11:28:31.582
c0130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5000	Cost of Flights	EXPENSE	\N	t	DEBIT	\N	2025-09-26 05:17:00	2026-08-30 11:28:31.586
c0140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5100	Cost of Hotels	EXPENSE	\N	t	DEBIT	\N	2025-09-11 08:45:00	2026-08-30 11:28:31.592
c0150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5200	Office Rent	EXPENSE	\N	t	DEBIT	\N	2025-09-06 04:56:00	2026-08-30 11:28:31.598
c0160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5300	Staff Salaries	EXPENSE	\N	t	DEBIT	\N	2025-09-03 04:59:00	2026-08-30 11:28:31.602
c0170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5400	Marketing Expense	EXPENSE	\N	t	DEBIT	\N	2025-09-05 09:37:00	2026-08-30 11:28:31.607
c0180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5500	Utilities	EXPENSE	\N	t	DEBIT	\N	2025-09-20 06:51:00	2026-08-30 11:28:31.614
c0190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	5600	Office Supplies	EXPENSE	\N	t	DEBIT	\N	2025-09-10 05:43:00	2026-08-30 11:28:31.618
\.


--
-- Data for Name: Counter; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Counter" (id, seq, "updatedAt") FROM stdin;
BK_a1000000-0000-0000-0000-000000000001_2026	30	2026-08-30 11:28:31.798
CUS_a1000000-0000-0000-0000-000000000001_2026	40	2026-08-30 11:28:31.798
SUP_a1000000-0000-0000-0000-000000000001_2026	15	2026-08-30 11:28:31.798
EXP_a1000000-0000-0000-0000-000000000001_2026	216	2026-08-30 11:28:31.798
RCP_a1000000-0000-0000-0000-000000000001_2026	25	2026-08-30 11:28:31.798
INV_a1000000-0000-0000-0000-000000000001_2026	20	2026-08-30 11:28:31.798
QT_a1000000-0000-0000-0000-000000000001_2026	21	2026-08-30 11:28:31.798
LD_a1000000-0000-0000-0000-000000000001_2026	32	2026-08-30 11:55:10.006
\.


--
-- Data for Name: Customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Customer" (id, "agencyId", "customerRef", type, "firstName", "lastName", "companyName", "businessType", "taxNumber", email, phone, whatsapp, "dateOfBirth", gender, cnic, "passportNumber", "passportExpiry", nationality, address, city, country, "emergencyContactName", "emergencyContactPhone", "internalNotes", status, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
40010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-001	individual	Ahmed	Khan	\N	\N	\N	ahmed.khan@gmail.com	+92-321-1111111	\N	1977-12-31 19:00:00	male	\N	AK1234567	\N	\N	\N	Lahore	Pakistan	\N	\N	VIP customer - priority handling	active	f	\N	2025-09-26 10:09:00	2026-08-30 11:28:27.685
40020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-002	individual	Fatima	Zahra	\N	\N	\N	fatima.z@outlook.com	+92-333-2222222	\N	1979-04-01 19:00:00	female	\N	FZ2345678	\N	\N	\N	Islamabad	Pakistan	\N	\N	\N	active	f	\N	2025-09-23 07:55:00	2026-08-30 11:28:27.789
40030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-003	corporate	Muhammad	Ali	Ali & Sons Trading	\N	\N	mali@yahoo.com	+92-345-3333333	\N	1980-07-02 19:00:00	male	\N	MA3456789	\N	\N	\N	Lahore	Pakistan	\N	\N	\N	active	f	\N	2025-09-22 09:40:00	2026-08-30 11:28:27.919
40040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-004	individual	Sobia	Aslam	\N	\N	\N	sobia.aslam@gmail.com	+92-300-4444444	\N	1981-10-03 19:00:00	male	\N	SA4567890	\N	\N	\N	Karachi	Pakistan	\N	\N	\N	active	f	\N	2025-09-19 05:57:00	2026-08-30 11:28:27.95
40050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-005	corporate	Tariq	Mahmood	Mahmood Holdings LLC	\N	\N	tariq.m@hotmail.com	+971-50-5555555	\N	1982-01-04 19:00:00	female	\N	TM5678901	\N	\N	\N	Dubai	UAE	\N	\N	\N	active	f	\N	2025-10-11 08:55:00	2026-08-30 11:28:27.964
40060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-006	individual	Nadia	Pervez	\N	\N	\N	nadia.p@gmail.com	+92-321-6666666	\N	1983-04-05 19:00:00	male	\N	NP6789012	\N	\N	\N	Lahore	Pakistan	\N	\N	VIP customer - priority handling	active	f	\N	2025-10-11 06:10:00	2026-08-30 11:28:27.971
40070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-007	individual	Imran	Sheikh	\N	\N	\N	imran.s@outlook.com	+92-333-7777777	\N	1984-07-06 19:00:00	male	\N	IS7890123	\N	\N	\N	Faisalabad	Pakistan	\N	\N	\N	active	f	\N	2025-10-15 12:13:00	2026-08-30 11:28:27.981
40080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-008	individual	Amina	Rashid	\N	\N	\N	amina.r@gmail.com	+971-55-8888888	\N	1985-10-07 19:00:00	female	\N	AR8901234	\N	\N	\N	Dubai	UAE	\N	\N	Corporate account - monthly billing	active	f	\N	2025-10-27 05:35:00	2026-08-30 11:28:27.988
40090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-009	corporate	Kamran	Butt	Butt Enterprises	\N	\N	kamran.b@yahoo.com	+92-345-9999999	\N	1986-01-08 19:00:00	male	\N	KB9012345	\N	\N	\N	Lahore	Pakistan	\N	\N	\N	active	f	\N	2025-11-13 06:23:00	2026-08-30 11:28:27.999
40100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-010	individual	Hira	Saleem	\N	\N	\N	hira.saleem@gmail.com	+92-300-1010101	\N	1987-04-09 19:00:00	male	\N	HS0123456	\N	\N	\N	Rawalpindi	Pakistan	\N	\N	\N	active	f	\N	2025-11-23 04:49:00	2026-08-30 11:28:28.005
40110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-011	individual	Danish	Iqbal	\N	\N	\N	danish.i@hotmail.com	+92-321-2020202	\N	1988-07-10 19:00:00	female	\N	DI1234098	\N	\N	\N	Sialkot	Pakistan	\N	\N	VIP customer - priority handling	active	f	\N	2025-11-11 09:29:00	2026-08-30 11:28:28.011
40120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-012	individual	Mehreen	Baig	\N	\N	\N	mehreen.b@gmail.com	+971-50-3030303	\N	1989-10-11 19:00:00	male	\N	MB2345098	\N	\N	\N	Abu Dhabi	UAE	\N	\N	\N	active	f	\N	2025-11-22 12:16:00	2026-08-30 11:28:28.058
40130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-013	corporate	Saad	Nawaz	Nawaz Group	\N	\N	saad.n@outlook.com	+92-333-4040404	\N	1990-01-12 19:00:00	male	\N	SN3456098	\N	\N	\N	Multan	Pakistan	\N	\N	\N	active	f	\N	2025-12-06 10:32:00	2026-08-30 11:28:28.087
40140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-014	individual	Rabia	Chaudhry	\N	\N	\N	rabia.c@gmail.com	+92-345-5050505	\N	1991-04-13 19:00:00	female	\N	RC4567098	\N	\N	\N	Lahore	Pakistan	\N	\N	\N	active	f	\N	2025-12-09 04:15:00	2026-08-30 11:28:28.099
40150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-015	individual	Faisal	Warraich	\N	\N	\N	faisal.w@yahoo.com	+92-300-6060606	\N	1992-07-14 19:00:00	male	\N	FW5678098	\N	\N	\N	Gujranwala	Pakistan	\N	\N	Corporate account - monthly billing	active	f	\N	2025-12-25 11:07:00	2026-08-30 11:28:28.108
40160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-016	individual	Aisha	Parveen	\N	\N	\N	aisha.p@gmail.com	+92-321-7070707	\N	1993-10-15 19:00:00	male	\N	AP6789012	\N	\N	\N	Peshawar	Pakistan	\N	\N	VIP customer - priority handling	active	f	\N	2025-12-08 04:00:00	2026-08-30 11:28:28.118
40170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-017	individual	Bilal	Ahmed	\N	\N	\N	bilal.ah@gmail.com	+92-333-8080808	\N	1994-01-16 19:00:00	female	\N	BA7890123	\N	\N	\N	Karachi	Pakistan	\N	\N	\N	active	f	\N	2026-01-26 06:44:00	2026-08-30 11:28:28.126
40180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-018	individual	Sana	Ullah	\N	\N	\N	sana.u@hotmail.com	+971-55-9090909	\N	1995-04-17 19:00:00	male	\N	SU8901234	\N	\N	\N	Sharjah	UAE	\N	\N	\N	active	f	\N	2026-01-21 08:11:00	2026-08-30 11:28:28.14
40190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-019	individual	Waqas	Javed	\N	\N	\N	waqas.j@gmail.com	+92-345-1111212	\N	1996-07-18 19:00:00	male	\N	WJ9012345	\N	\N	\N	Peshawar	Pakistan	\N	\N	\N	active	f	\N	2026-01-04 05:52:00	2026-08-30 11:28:28.155
40200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-020	individual	Nazia	Irfan	\N	\N	\N	nazia.i@outlook.com	+92-300-2222323	\N	1997-10-19 19:00:00	female	\N	NI0123456	\N	\N	\N	Islamabad	Pakistan	\N	\N	\N	active	f	\N	2026-01-05 10:36:00	2026-08-30 11:28:28.162
40210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-021	corporate	Adnan	Shah	Shah Trading Co	\N	\N	adnan.s@gmail.com	+971-50-3333434	\N	1998-01-20 19:00:00	male	\N	AS1234567	\N	\N	\N	Dubai	UAE	\N	\N	VIP customer - priority handling	active	f	\N	2026-03-09 05:16:00	2026-08-30 11:28:28.169
40220000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-022	individual	Mariam	Zubair	\N	\N	\N	mariam.z@yahoo.com	+92-321-4444545	\N	1999-04-21 19:00:00	male	\N	MZ2345678	\N	\N	\N	Lahore	Pakistan	\N	\N	Corporate account - monthly billing	active	f	\N	2026-03-12 11:11:00	2026-08-30 11:28:28.174
40230000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-023	individual	Asif	Javed	\N	\N	\N	asif.j@hotmail.com	+971-55-5555656	\N	1978-07-22 19:00:00	female	\N	AJ3456789	\N	\N	\N	Dubai	UAE	\N	\N	\N	active	f	\N	2026-03-27 10:45:00	2026-08-30 11:28:28.183
40240000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-024	individual	Bushra	 Bibi	\N	\N	\N	busbra.b@gmail.com	+92-333-6666767	\N	1979-10-23 19:00:00	male	\N	BB4567890	\N	\N	\N	Karachi	Pakistan	\N	\N	\N	active	f	\N	2026-03-23 08:30:00	2026-08-30 11:28:28.191
40250000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-025	individual	Hamza	Malik	\N	\N	\N	hamza.m@outlook.com	+92-345-7777878	\N	1980-01-24 19:00:00	male	\N	HM5678901	\N	\N	\N	Rawalpindi	Pakistan	\N	\N	\N	active	f	\N	2026-03-19 06:45:00	2026-08-30 11:28:28.201
40260000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-026	individual	Rida	Hussain	\N	\N	\N	rida.h@gmail.com	+971-50-8888989	\N	1981-04-25 19:00:00	female	\N	RH6789012	\N	\N	\N	Ajman	UAE	\N	\N	VIP customer - priority handling	active	f	\N	2026-03-06 08:29:00	2026-08-30 11:28:28.207
40270000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-027	individual	Omar	Khalid	\N	\N	\N	omar.k@yahoo.com	+92-300-9999090	\N	1982-07-26 19:00:00	male	\N	OK7890123	\N	\N	\N	Peshawar	Pakistan	\N	\N	\N	active	f	\N	2026-03-28 10:29:00	2026-08-30 11:28:28.214
40280000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-028	individual	Yasmin	Rashid	\N	\N	\N	yasmin.r@gmail.com	+92-321-1010111	\N	1983-10-27 19:00:00	male	\N	YR8901234	\N	\N	\N	Islamabad	Pakistan	\N	\N	\N	active	f	\N	2026-03-17 09:13:00	2026-08-30 11:28:28.219
40290000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-029	corporate	Taimoor	Baig	Baig International	\N	\N	taimoor.b@hotmail.com	+971-55-2121212	\N	1983-12-31 19:00:00	female	\N	TB9012345	\N	\N	\N	Dubai	UAE	\N	\N	Corporate account - monthly billing	active	f	\N	2026-04-05 11:27:00	2026-08-30 11:28:28.225
40300000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-030	individual	Sidra	Ismail	\N	\N	\N	sidra.i@outlook.com	+92-333-3232323	\N	1985-04-01 19:00:00	male	\N	SI0123456	\N	\N	\N	Multan	Pakistan	\N	\N	\N	active	f	\N	2026-04-12 09:59:00	2026-08-30 11:28:28.234
40310000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-031	individual	Kashif	Naveed	\N	\N	\N	kashif.n@gmail.com	+92-345-4343434	\N	1986-07-02 19:00:00	male	\N	KN1234567	\N	\N	\N	Sialkot	Pakistan	\N	\N	VIP customer - priority handling	active	f	\N	2026-04-20 05:55:00	2026-08-30 11:28:28.24
40320000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-032	individual	Naima	Qureshi	\N	\N	\N	naima.q@yahoo.com	+971-50-5454545	\N	1987-10-03 19:00:00	female	\N	NQ2345678	\N	\N	\N	Dubai	UAE	\N	\N	\N	active	f	\N	2026-04-24 05:30:00	2026-08-30 11:28:28.249
40330000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-033	individual	Shahid	Afridi	\N	\N	\N	shahid.a@gmail.com	+92-300-6565656	\N	1988-01-04 19:00:00	male	\N	SA3456789	\N	\N	\N	Peshawar	Pakistan	\N	\N	\N	active	f	\N	2026-05-18 09:53:00	2026-08-30 11:28:28.254
40340000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-034	individual	Hina	Waseem	\N	\N	\N	hina.w@hotmail.com	+92-321-7676767	\N	1989-04-05 19:00:00	male	\N	HW4567890	\N	\N	\N	Lahore	Pakistan	\N	\N	\N	active	f	\N	2026-05-15 08:34:00	2026-08-30 11:28:28.263
40350000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-035	individual	Fahad	Iqbal	\N	\N	\N	fahad.i@outlook.com	+971-55-8787878	\N	1990-07-06 19:00:00	female	\N	FI5678901	\N	\N	\N	Sharjah	UAE	\N	\N	\N	active	f	\N	2026-05-11 09:49:00	2026-08-30 11:28:28.269
40360000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-036	individual	Ayesha	 Siddiqui	\N	\N	\N	asiddiqui@gmail.com	+92-333-9898989	\N	1991-10-07 19:00:00	male	\N	AS6789012	\N	\N	\N	Karachi	Pakistan	\N	\N	VIP customer - priority handling	active	f	\N	2026-05-12 04:03:00	2026-08-30 11:28:28.275
40370000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-037	individual	Daniyal	Saleem	\N	\N	\N	daniyal.s@yahoo.com	+92-345-0909090	\N	1992-01-08 19:00:00	male	\N	DS7890123	\N	\N	\N	Faisalabad	Pakistan	\N	\N	\N	active	f	\N	2026-06-08 04:54:00	2026-08-30 11:28:28.283
40380000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-038	individual	Mahira	Khan	\N	\N	\N	mahira.k@gmail.com	+971-50-1010101	\N	1993-04-09 19:00:00	female	\N	MK8901234	\N	\N	\N	Abu Dhabi	UAE	\N	\N	\N	active	f	\N	2026-06-10 08:44:00	2026-08-30 11:28:28.288
40390000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-039	individual	Usama	Tariq	\N	\N	\N	usama.t@outlook.com	+92-300-2121212	\N	1994-07-10 19:00:00	male	\N	UT9012345	\N	\N	\N	Lahore	Pakistan	\N	\N	\N	active	f	\N	2026-06-10 05:48:00	2026-08-30 11:28:28.295
40400000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	CUS-2026-040	individual	Zara	Ahmed	\N	\N	\N	zara.a@hotmail.com	+92-321-3232323	\N	1995-10-11 19:00:00	male	\N	ZA0123456	\N	\N	\N	Islamabad	Pakistan	\N	\N	\N	active	f	\N	2026-06-22 08:50:00	2026-08-30 11:28:28.303
\.


--
-- Data for Name: CustomerDocument; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CustomerDocument" (id, "agencyId", "customerId", "documentType", "fileName", "fileSize", "mimeType", "fileUrl", notes, "uploadedBy", "createdAt", "updatedAt") FROM stdin;
ad0718f5-124d-45a6-847c-c3760cc66338	a1000000-0000-0000-0000-000000000001	40010000-0000-0000-0000-000000000001	cnic	ahmed_cnic.pdf	240778	application/pdf	/uploads/customers/ahmed_cnic.pdf	\N	Sara Khan	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
46df3fd4-b8dc-4ba4-a46d-e147caec008d	a1000000-0000-0000-0000-000000000001	40020000-0000-0000-0000-000000000001	passport	fatima_passport.pdf	300620	application/pdf	/uploads/customers/fatima_passport.pdf	\N	Hassan Raza	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
650ec784-cd50-4034-9da5-6beef27d6aaf	a1000000-0000-0000-0000-000000000001	40030000-0000-0000-0000-000000000001	passport	muhammad_passport.pdf	354744	application/pdf	/uploads/customers/muhammad_passport.pdf	\N	Hassan Raza	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
ee1eb5a2-4217-4b27-bb9f-be6d2985d42b	a1000000-0000-0000-0000-000000000001	40040000-0000-0000-0000-000000000001	cnic	sobia_cnic.pdf	373707	application/pdf	/uploads/customers/sobia_cnic.pdf	\N	Sara Khan	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
1fb9f7b7-0f1d-4aa9-8c64-84305debaea5	a1000000-0000-0000-0000-000000000001	40050000-0000-0000-0000-000000000001	passport	tariq_passport.pdf	323387	application/pdf	/uploads/customers/tariq_passport.pdf	\N	Hassan Raza	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
5fced4d0-9c09-4709-9856-e59c61df2444	a1000000-0000-0000-0000-000000000001	40060000-0000-0000-0000-000000000001	passport	nadia_passport.pdf	164386	application/pdf	/uploads/customers/nadia_passport.pdf	\N	Sara Khan	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
fe5d5a6f-6940-45b5-bd3e-2fda93b6a7eb	a1000000-0000-0000-0000-000000000001	40070000-0000-0000-0000-000000000001	cnic	imran_cnic.pdf	275948	application/pdf	/uploads/customers/imran_cnic.pdf	\N	Sara Khan	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
9aaaf39c-897f-4c40-9f4a-52c6f977ab9d	a1000000-0000-0000-0000-000000000001	40080000-0000-0000-0000-000000000001	passport	amina_passport.pdf	176477	application/pdf	/uploads/customers/amina_passport.pdf	\N	Ayesha Malik	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
26331880-1966-4995-abf1-8c79e1103520	a1000000-0000-0000-0000-000000000001	40090000-0000-0000-0000-000000000001	passport	kamran_passport.pdf	299995	application/pdf	/uploads/customers/kamran_passport.pdf	\N	Ayesha Malik	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
49127f89-50b2-42e0-9b23-820df96e9a56	a1000000-0000-0000-0000-000000000001	40100000-0000-0000-0000-000000000001	cnic	hira_cnic.pdf	163635	application/pdf	/uploads/customers/hira_cnic.pdf	\N	Hassan Raza	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
84668ad3-41b1-4e80-964b-b899629d3d3b	a1000000-0000-0000-0000-000000000001	40110000-0000-0000-0000-000000000001	passport	danish_passport.pdf	321060	application/pdf	/uploads/customers/danish_passport.pdf	\N	Ayesha Malik	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
ce84f531-94df-4879-9d12-4a86524f8e2d	a1000000-0000-0000-0000-000000000001	40120000-0000-0000-0000-000000000001	passport	mehreen_passport.pdf	174604	application/pdf	/uploads/customers/mehreen_passport.pdf	\N	Ayesha Malik	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
952ace47-3059-4df7-9093-79c9b790cffd	a1000000-0000-0000-0000-000000000001	40130000-0000-0000-0000-000000000001	cnic	saad_cnic.pdf	252789	application/pdf	/uploads/customers/saad_cnic.pdf	\N	Sara Khan	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
0545dcb8-7fd1-40c5-a229-a678f0289a1e	a1000000-0000-0000-0000-000000000001	40140000-0000-0000-0000-000000000001	passport	rabia_passport.pdf	311996	application/pdf	/uploads/customers/rabia_passport.pdf	\N	Sara Khan	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
96346cd8-127a-4ac8-8a21-d403dc0526cf	a1000000-0000-0000-0000-000000000001	40150000-0000-0000-0000-000000000001	passport	faisal_passport.pdf	157005	application/pdf	/uploads/customers/faisal_passport.pdf	\N	Ayesha Malik	2026-08-30 11:28:28.332	2026-08-30 11:28:28.332
\.


--
-- Data for Name: CustomerNote; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CustomerNote" (id, "agencyId", "customerId", note, "addedBy", "createdAt", "updatedAt") FROM stdin;
832935b1-c897-4e71-8c83-c47b0f900d19	a1000000-0000-0000-0000-000000000001	40010000-0000-0000-0000-000000000001	Prefers direct flights. Always travels business class.	Ayesha Malik	2026-03-29 04:41:00	2026-08-30 11:28:28.309
87c38cc0-c51e-4f6d-91b8-69c342527055	a1000000-0000-0000-0000-000000000001	40020000-0000-0000-0000-000000000001	Family trip to Europe planned for December.	Hassan Raza	2026-03-06 07:46:00	2026-08-30 11:28:28.309
58a6a6d0-58a5-4404-89c0-f034fa093fd0	a1000000-0000-0000-0000-000000000001	40030000-0000-0000-0000-000000000001	First-time international traveler. Needs visa assistance.	Sara Khan	2026-07-08 12:53:00	2026-08-30 11:28:28.309
6b71797d-05c2-4c35-9517-bec440b7149e	a1000000-0000-0000-0000-000000000001	40040000-0000-0000-0000-000000000001	Corporate account - monthly billing. Net 30 terms.	Ayesha Malik	2025-12-19 09:34:00	2026-08-30 11:28:28.309
361cebd5-270b-42b8-83f0-8642eb910a89	a1000000-0000-0000-0000-000000000001	40050000-0000-0000-0000-000000000001	Frequently travels to London and Singapore.	Omar Farooq	2026-05-22 09:43:00	2026-08-30 11:28:28.309
423b8f4e-e152-495b-ab7d-193422290164	a1000000-0000-0000-0000-000000000001	40060000-0000-0000-0000-000000000001	Prefers Emirates and Singapore Airlines.	Omar Farooq	2026-06-29 07:00:00	2026-08-30 11:28:28.309
529eece9-78bd-4462-b85a-e0b209f0b380	a1000000-0000-0000-0000-000000000001	40070000-0000-0000-0000-000000000001	Honeymoon trip to Maldives. Budget flexible.	Sara Khan	2026-03-15 09:04:00	2026-08-30 11:28:28.309
520830c7-17b0-4d09-85df-77ddddb02549	a1000000-0000-0000-0000-000000000001	40080000-0000-0000-0000-000000000001	Company retreat - 25 pax to Northern Areas.	Ayesha Malik	2026-02-02 08:54:00	2026-08-30 11:28:28.309
1200af2c-e8ba-4949-897c-d72ffed49d0d	a1000000-0000-0000-0000-000000000001	40090000-0000-0000-0000-000000000001	Family of 4. Travels twice a year.	Ayesha Malik	2026-07-19 09:53:00	2026-08-30 11:28:28.309
6aef02e7-80a4-4c48-a978-4a606a0c6b49	a1000000-0000-0000-0000-000000000001	40100000-0000-0000-0000-000000000001	Recently relocated to Dubai. Needs Umrah package.	Sara Khan	2025-10-10 05:26:00	2026-08-30 11:28:28.309
f6781fbf-a5d5-43d4-b0f0-016a6baa6461	a1000000-0000-0000-0000-000000000001	40110000-0000-0000-0000-000000000001	Frequent traveler - VIP lounge access required.	Ayesha Malik	2026-04-09 04:59:00	2026-08-30 11:28:28.309
c5fabc88-b330-4178-a338-e6ad0c24e95b	a1000000-0000-0000-0000-000000000001	40120000-0000-0000-0000-000000000001	Group booking for wedding party - 12 people.	Omar Farooq	2026-03-12 10:18:00	2026-08-30 11:28:28.309
1215ce14-4e62-4cdf-9544-c2cc26609f28	a1000000-0000-0000-0000-000000000001	40130000-0000-0000-0000-000000000001	Student visa inquiry for UK universities.	Ayesha Malik	2026-04-08 05:11:00	2026-08-30 11:28:28.309
d77f211c-8d12-4a90-beb3-7e43cdcdfa69	a1000000-0000-0000-0000-000000000001	40140000-0000-0000-0000-000000000001	Annual family vacation - Europe preferred.	Sara Khan	2026-02-01 11:28:00	2026-08-30 11:28:28.309
d9b0502b-15ba-42b0-8c3d-3091f4e881a7	a1000000-0000-0000-0000-000000000001	40150000-0000-0000-0000-000000000001	Business class only - Emirates preferred.	Sara Khan	2026-01-01 04:38:00	2026-08-30 11:28:28.309
\.


--
-- Data for Name: Expense; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Expense" (id, "agencyId", "branchId", "expenseRef", title, category, amount, date, "paidTo", "paymentMethod", "receiptUrl", notes, "recordedById", status, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
80010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-001	Office Rent - 11mo ago	rent	85000	2025-09-20 04:28:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-20 04:28:00	2026-08-30 11:28:28.974
80020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-002	Office Rent - 11mo ago	rent	55000	2025-09-15 07:32:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-15 07:32:00	2026-08-30 11:28:28.987
80030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-003	Office Rent - 11mo ago	rent	65000	2025-09-01 12:39:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-01 12:39:00	2026-08-30 11:28:28.992
80040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-004	Office Rent - 11mo ago	rent	45000	2025-09-05 08:23:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-05 08:23:00	2026-08-30 11:28:29.004
80050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-005	Office Rent - 11mo ago	rent	120000	2025-09-22 12:01:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-22 12:01:00	2026-08-30 11:28:29.011
80060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-006	Electricity Bill - 11mo ago	utilities	12500	2025-09-15 08:33:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-15 08:33:00	2026-08-30 11:28:29.017
80070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-007	Internet & Phone - 11mo ago	utilities	8500	2025-09-27 05:02:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-27 05:02:00	2026-08-30 11:28:29.023
80080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-008	Internet & Phone - 11mo ago	utilities	6500	2025-09-21 10:29:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-21 10:29:00	2026-08-30 11:28:29.029
80090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-009	Internet & Phone - 11mo ago	utilities	7000	2025-09-06 07:10:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-06 07:10:00	2026-08-30 11:28:29.035
80100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-010	Internet & Phone - 11mo ago	utilities	5500	2025-09-12 08:08:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-12 08:08:00	2026-08-30 11:28:29.04
80110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-011	Internet & Phone - 11mo ago	utilities	350	2025-09-22 07:38:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-22 07:38:00	2026-08-30 11:28:29.047
80120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-012	Staff Salaries - 11mo ago	salary	450000	2025-09-25 10:33:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-25 10:33:00	2026-08-30 11:28:29.052
80130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-013	Office Supplies - 11mo ago	office_supplies	15000	2025-09-03 11:06:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-03 11:06:00	2026-08-30 11:28:29.058
80140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-014	Marketing - Social Media - 11mo ago	marketing	35000	2025-09-24 04:49:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-24 04:49:00	2026-08-30 11:28:29.074
80150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-015	Client Entertainment - 11mo ago	entertainment	22000	2025-09-08 10:47:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-08 10:47:00	2026-08-30 11:28:29.092
80160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-016	Car Fuel - 11mo ago	transport	8000	2025-09-04 07:16:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-04 07:16:00	2026-08-30 11:28:29.104
80170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-017	Website Hosting - 11mo ago	technology	5500	2025-09-09 05:36:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-09 05:36:00	2026-08-30 11:28:29.115
80180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-018	Insurance Premium - 11mo ago	insurance	45000	2025-09-18 07:55:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-09-18 07:55:00	2026-08-30 11:28:29.121
80190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-019	Office Rent - 10mo ago	rent	85000	2025-10-04 10:37:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-04 10:37:00	2026-08-30 11:28:29.141
80200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-020	Office Rent - 10mo ago	rent	55000	2025-10-21 11:31:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-21 11:31:00	2026-08-30 11:28:29.151
80210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-021	Office Rent - 10mo ago	rent	65000	2025-10-23 07:57:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-23 07:57:00	2026-08-30 11:28:29.161
80220000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-022	Office Rent - 10mo ago	rent	45000	2025-10-14 09:01:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-14 09:01:00	2026-08-30 11:28:29.171
80230000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-023	Office Rent - 10mo ago	rent	120000	2025-10-02 10:42:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-02 10:42:00	2026-08-30 11:28:29.184
80240000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-024	Electricity Bill - 10mo ago	utilities	12500	2025-10-27 09:33:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-27 09:33:00	2026-08-30 11:28:29.2
80250000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-025	Internet & Phone - 10mo ago	utilities	8500	2025-10-18 08:02:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-18 08:02:00	2026-08-30 11:28:29.208
80260000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-026	Internet & Phone - 10mo ago	utilities	6500	2025-10-11 06:43:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-11 06:43:00	2026-08-30 11:28:29.216
80270000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-027	Internet & Phone - 10mo ago	utilities	7000	2025-10-08 08:43:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-08 08:43:00	2026-08-30 11:28:29.22
80280000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-028	Internet & Phone - 10mo ago	utilities	5500	2025-10-18 08:26:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-18 08:26:00	2026-08-30 11:28:29.239
80290000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-029	Internet & Phone - 10mo ago	utilities	350	2025-10-16 10:04:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-16 10:04:00	2026-08-30 11:28:29.249
80300000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-030	Staff Salaries - 10mo ago	salary	450000	2025-10-19 07:08:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-19 07:08:00	2026-08-30 11:28:29.255
80310000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-031	Office Supplies - 10mo ago	office_supplies	15000	2025-10-18 08:11:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-18 08:11:00	2026-08-30 11:28:29.261
80320000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-032	Marketing - Social Media - 10mo ago	marketing	35000	2025-10-22 04:48:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-22 04:48:00	2026-08-30 11:28:29.27
80330000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-033	Client Entertainment - 10mo ago	entertainment	22000	2025-10-21 04:43:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-21 04:43:00	2026-08-30 11:28:29.274
80340000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-034	Car Fuel - 10mo ago	transport	8000	2025-10-09 07:31:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-09 07:31:00	2026-08-30 11:28:29.28
80350000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-035	Website Hosting - 10mo ago	technology	5500	2025-10-17 07:28:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-17 07:28:00	2026-08-30 11:28:29.285
80360000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-036	Insurance Premium - 10mo ago	insurance	45000	2025-10-03 08:37:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-10-03 08:37:00	2026-08-30 11:28:29.289
80370000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-037	Office Rent - 9mo ago	rent	85000	2025-11-15 12:24:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-15 12:24:00	2026-08-30 11:28:29.294
80380000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-038	Office Rent - 9mo ago	rent	55000	2025-11-10 10:56:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-10 10:56:00	2026-08-30 11:28:29.3
80390000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-039	Office Rent - 9mo ago	rent	65000	2025-11-27 04:06:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-27 04:06:00	2026-08-30 11:28:29.305
80400000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-040	Office Rent - 9mo ago	rent	45000	2025-11-01 04:17:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-01 04:17:00	2026-08-30 11:28:29.309
80410000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-041	Office Rent - 9mo ago	rent	120000	2025-11-06 09:54:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-06 09:54:00	2026-08-30 11:28:29.315
80420000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-042	Electricity Bill - 9mo ago	utilities	12500	2025-11-04 07:57:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-04 07:57:00	2026-08-30 11:28:29.321
80430000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-043	Internet & Phone - 9mo ago	utilities	8500	2025-11-02 04:15:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-02 04:15:00	2026-08-30 11:28:29.325
80440000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-044	Internet & Phone - 9mo ago	utilities	6500	2025-11-11 09:53:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-11 09:53:00	2026-08-30 11:28:29.33
80450000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-045	Internet & Phone - 9mo ago	utilities	7000	2025-11-25 05:22:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-25 05:22:00	2026-08-30 11:28:29.337
80460000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-046	Internet & Phone - 9mo ago	utilities	5500	2025-11-07 11:32:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-07 11:32:00	2026-08-30 11:28:29.341
80470000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-047	Internet & Phone - 9mo ago	utilities	350	2025-11-06 09:06:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-06 09:06:00	2026-08-30 11:28:29.347
80480000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-048	Staff Salaries - 9mo ago	salary	450000	2025-11-17 05:54:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-17 05:54:00	2026-08-30 11:28:29.352
80490000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-049	Office Supplies - 9mo ago	office_supplies	15000	2025-11-06 11:46:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-06 11:46:00	2026-08-30 11:28:29.357
80500000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-050	Marketing - Social Media - 9mo ago	marketing	35000	2025-11-23 05:36:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-23 05:36:00	2026-08-30 11:28:29.363
80510000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-051	Client Entertainment - 9mo ago	entertainment	22000	2025-11-24 10:15:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-24 10:15:00	2026-08-30 11:28:29.369
80520000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-052	Car Fuel - 9mo ago	transport	8000	2025-11-07 09:12:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-07 09:12:00	2026-08-30 11:28:29.374
80530000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-053	Website Hosting - 9mo ago	technology	5500	2025-11-12 08:28:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-12 08:28:00	2026-08-30 11:28:29.38
80540000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-054	Insurance Premium - 9mo ago	insurance	45000	2025-11-03 08:58:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-11-03 08:58:00	2026-08-30 11:28:29.386
80550000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-055	Office Rent - 8mo ago	rent	85000	2025-12-23 11:47:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-23 11:47:00	2026-08-30 11:28:29.391
80560000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-056	Office Rent - 8mo ago	rent	55000	2025-12-22 07:42:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-22 07:42:00	2026-08-30 11:28:29.4
80570000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-057	Office Rent - 8mo ago	rent	65000	2025-12-25 10:52:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-25 10:52:00	2026-08-30 11:28:29.408
80580000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-058	Office Rent - 8mo ago	rent	45000	2025-12-16 11:46:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-16 11:46:00	2026-08-30 11:28:29.416
80590000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-059	Office Rent - 8mo ago	rent	120000	2025-12-22 06:31:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-22 06:31:00	2026-08-30 11:28:29.422
80600000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-060	Electricity Bill - 8mo ago	utilities	12500	2025-12-18 06:20:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-18 06:20:00	2026-08-30 11:28:29.436
80610000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-061	Internet & Phone - 8mo ago	utilities	8500	2025-12-04 06:27:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-04 06:27:00	2026-08-30 11:28:29.441
80620000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-062	Internet & Phone - 8mo ago	utilities	6500	2025-12-26 08:51:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-26 08:51:00	2026-08-30 11:28:29.447
80630000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-063	Internet & Phone - 8mo ago	utilities	7000	2025-12-15 10:53:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-15 10:53:00	2026-08-30 11:28:29.452
80640000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-064	Internet & Phone - 8mo ago	utilities	5500	2025-12-04 06:45:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-04 06:45:00	2026-08-30 11:28:29.457
80650000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-065	Internet & Phone - 8mo ago	utilities	350	2025-12-12 09:08:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-12 09:08:00	2026-08-30 11:28:29.462
80660000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-066	Staff Salaries - 8mo ago	salary	450000	2025-12-11 12:21:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-11 12:21:00	2026-08-30 11:28:29.468
80670000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-067	Office Supplies - 8mo ago	office_supplies	15000	2025-12-20 09:05:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-20 09:05:00	2026-08-30 11:28:29.473
80680000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-068	Marketing - Social Media - 8mo ago	marketing	35000	2025-12-07 11:02:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-07 11:02:00	2026-08-30 11:28:29.479
80690000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-069	Client Entertainment - 8mo ago	entertainment	22000	2025-12-19 11:45:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-19 11:45:00	2026-08-30 11:28:29.485
80700000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-070	Car Fuel - 8mo ago	transport	8000	2025-12-01 11:04:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-01 11:04:00	2026-08-30 11:28:29.489
80710000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-071	Website Hosting - 8mo ago	technology	5500	2025-12-01 04:28:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-01 04:28:00	2026-08-30 11:28:29.495
80720000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-072	Insurance Premium - 8mo ago	insurance	45000	2025-12-19 06:48:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2025-12-19 06:48:00	2026-08-30 11:28:29.5
80730000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-073	Office Rent - 7mo ago	rent	85000	2026-01-08 12:20:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-08 12:20:00	2026-08-30 11:28:29.505
80740000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-074	Office Rent - 7mo ago	rent	55000	2026-01-04 11:57:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-04 11:57:00	2026-08-30 11:28:29.51
80750000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-075	Office Rent - 7mo ago	rent	65000	2026-01-19 05:19:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-19 05:19:00	2026-08-30 11:28:29.518
80760000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-076	Office Rent - 7mo ago	rent	45000	2026-01-09 05:26:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-09 05:26:00	2026-08-30 11:28:29.522
80770000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-077	Office Rent - 7mo ago	rent	120000	2026-01-21 07:31:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-21 07:31:00	2026-08-30 11:28:29.528
80780000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-078	Electricity Bill - 7mo ago	utilities	12500	2026-01-10 09:23:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-10 09:23:00	2026-08-30 11:28:29.534
80790000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-079	Internet & Phone - 7mo ago	utilities	8500	2026-01-16 04:29:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-16 04:29:00	2026-08-30 11:28:29.539
80800000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-080	Internet & Phone - 7mo ago	utilities	6500	2026-01-03 05:21:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-03 05:21:00	2026-08-30 11:28:29.547
80810000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-081	Internet & Phone - 7mo ago	utilities	7000	2026-01-09 10:09:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-09 10:09:00	2026-08-30 11:28:29.552
80820000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-082	Internet & Phone - 7mo ago	utilities	5500	2026-01-17 05:13:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-17 05:13:00	2026-08-30 11:28:29.558
80830000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-083	Internet & Phone - 7mo ago	utilities	350	2026-01-24 07:00:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-24 07:00:00	2026-08-30 11:28:29.566
80840000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-084	Staff Salaries - 7mo ago	salary	450000	2026-01-24 09:49:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-24 09:49:00	2026-08-30 11:28:29.571
80850000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-085	Office Supplies - 7mo ago	office_supplies	15000	2026-01-04 09:44:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-04 09:44:00	2026-08-30 11:28:29.576
80860000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-086	Marketing - Social Media - 7mo ago	marketing	35000	2026-01-26 09:20:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-26 09:20:00	2026-08-30 11:28:29.583
80870000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-087	Client Entertainment - 7mo ago	entertainment	22000	2026-01-11 09:19:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-11 09:19:00	2026-08-30 11:28:29.588
80880000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-088	Car Fuel - 7mo ago	transport	8000	2026-01-13 06:24:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-13 06:24:00	2026-08-30 11:28:29.593
80890000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-089	Website Hosting - 7mo ago	technology	5500	2026-01-20 06:11:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-20 06:11:00	2026-08-30 11:28:29.6
80900000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-090	Insurance Premium - 7mo ago	insurance	45000	2026-01-13 10:34:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-01-13 10:34:00	2026-08-30 11:28:29.605
80910000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-091	Office Rent - 6mo ago	rent	85000	2026-03-22 04:48:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-22 04:48:00	2026-08-30 11:28:29.609
80920000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-092	Office Rent - 6mo ago	rent	55000	2026-03-26 09:22:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-26 09:22:00	2026-08-30 11:28:29.616
80930000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-093	Office Rent - 6mo ago	rent	65000	2026-03-16 11:50:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-16 11:50:00	2026-08-30 11:28:29.621
80940000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-094	Office Rent - 6mo ago	rent	45000	2026-03-27 11:53:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-27 11:53:00	2026-08-30 11:28:29.628
80950000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-095	Office Rent - 6mo ago	rent	120000	2026-03-08 07:29:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-08 07:29:00	2026-08-30 11:28:29.634
80960000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-096	Electricity Bill - 6mo ago	utilities	12500	2026-03-02 04:29:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-02 04:29:00	2026-08-30 11:28:29.639
80970000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-097	Internet & Phone - 6mo ago	utilities	8500	2026-03-24 07:44:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-24 07:44:00	2026-08-30 11:28:29.644
80980000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-098	Internet & Phone - 6mo ago	utilities	6500	2026-03-15 04:08:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-15 04:08:00	2026-08-30 11:28:29.65
80990000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-099	Internet & Phone - 6mo ago	utilities	7000	2026-03-09 04:46:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-09 04:46:00	2026-08-30 11:28:29.655
81000000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-100	Internet & Phone - 6mo ago	utilities	5500	2026-03-05 09:47:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-05 09:47:00	2026-08-30 11:28:29.66
81010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-101	Internet & Phone - 6mo ago	utilities	350	2026-03-10 08:01:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-10 08:01:00	2026-08-30 11:28:29.666
81020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-102	Staff Salaries - 6mo ago	salary	450000	2026-03-19 10:46:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-19 10:46:00	2026-08-30 11:28:29.671
81030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-103	Office Supplies - 6mo ago	office_supplies	15000	2026-03-03 10:28:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-03 10:28:00	2026-08-30 11:28:29.677
81040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-104	Marketing - Social Media - 6mo ago	marketing	35000	2026-03-23 09:36:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-23 09:36:00	2026-08-30 11:28:29.682
81050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-105	Client Entertainment - 6mo ago	entertainment	22000	2026-03-02 05:17:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-02 05:17:00	2026-08-30 11:28:29.688
81060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-106	Car Fuel - 6mo ago	transport	8000	2026-03-03 07:47:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-03 07:47:00	2026-08-30 11:28:29.693
81070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-107	Website Hosting - 6mo ago	technology	5500	2026-03-17 08:27:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-17 08:27:00	2026-08-30 11:28:29.699
81080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-108	Insurance Premium - 6mo ago	insurance	45000	2026-03-02 09:55:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-02 09:55:00	2026-08-30 11:28:29.705
81090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-109	Office Rent - 5mo ago	rent	85000	2026-03-19 10:47:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-19 10:47:00	2026-08-30 11:28:29.711
81100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-110	Office Rent - 5mo ago	rent	55000	2026-03-16 11:11:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-16 11:11:00	2026-08-30 11:28:29.718
81110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-111	Office Rent - 5mo ago	rent	65000	2026-03-19 08:02:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-19 08:02:00	2026-08-30 11:28:29.724
81120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-112	Office Rent - 5mo ago	rent	45000	2026-03-26 10:10:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-26 10:10:00	2026-08-30 11:28:29.73
81130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-113	Office Rent - 5mo ago	rent	120000	2026-03-05 06:19:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-05 06:19:00	2026-08-30 11:28:29.735
81140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-114	Electricity Bill - 5mo ago	utilities	12500	2026-03-11 06:10:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-11 06:10:00	2026-08-30 11:28:29.74
81150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-115	Internet & Phone - 5mo ago	utilities	8500	2026-03-26 06:43:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-26 06:43:00	2026-08-30 11:28:29.747
81160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-116	Internet & Phone - 5mo ago	utilities	6500	2026-03-25 09:24:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-25 09:24:00	2026-08-30 11:28:29.752
81170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-117	Internet & Phone - 5mo ago	utilities	7000	2026-03-08 06:51:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-08 06:51:00	2026-08-30 11:28:29.757
81180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-118	Internet & Phone - 5mo ago	utilities	5500	2026-03-17 12:20:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-17 12:20:00	2026-08-30 11:28:29.763
81190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-119	Internet & Phone - 5mo ago	utilities	350	2026-03-27 11:53:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-27 11:53:00	2026-08-30 11:28:29.769
81200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-120	Staff Salaries - 5mo ago	salary	450000	2026-03-23 07:03:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-23 07:03:00	2026-08-30 11:28:29.774
81210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-121	Office Supplies - 5mo ago	office_supplies	15000	2026-03-21 11:03:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-21 11:03:00	2026-08-30 11:28:29.781
81220000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-122	Marketing - Social Media - 5mo ago	marketing	35000	2026-03-22 07:43:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-22 07:43:00	2026-08-30 11:28:29.786
81230000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-123	Client Entertainment - 5mo ago	entertainment	22000	2026-03-18 08:52:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-18 08:52:00	2026-08-30 11:28:29.79
81240000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-124	Car Fuel - 5mo ago	transport	8000	2026-03-14 04:54:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-14 04:54:00	2026-08-30 11:28:29.797
81250000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-125	Website Hosting - 5mo ago	technology	5500	2026-03-13 05:39:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-13 05:39:00	2026-08-30 11:28:29.802
81260000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-126	Insurance Premium - 5mo ago	insurance	45000	2026-03-14 04:34:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-03-14 04:34:00	2026-08-30 11:28:29.807
81270000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-127	Office Rent - 4mo ago	rent	85000	2026-04-27 05:54:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-27 05:54:00	2026-08-30 11:28:29.816
81280000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-128	Office Rent - 4mo ago	rent	55000	2026-04-27 04:41:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-27 04:41:00	2026-08-30 11:28:29.821
81290000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-129	Office Rent - 4mo ago	rent	65000	2026-04-10 11:18:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-10 11:18:00	2026-08-30 11:28:29.834
81300000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-130	Office Rent - 4mo ago	rent	45000	2026-04-03 10:38:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-03 10:38:00	2026-08-30 11:28:29.843
81310000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-131	Office Rent - 4mo ago	rent	120000	2026-04-13 08:54:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-13 08:54:00	2026-08-30 11:28:29.856
81320000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-132	Electricity Bill - 4mo ago	utilities	12500	2026-04-20 04:01:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-20 04:01:00	2026-08-30 11:28:29.866
81330000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-133	Internet & Phone - 4mo ago	utilities	8500	2026-04-11 06:51:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-11 06:51:00	2026-08-30 11:28:29.872
81340000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-134	Internet & Phone - 4mo ago	utilities	6500	2026-04-13 09:06:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-13 09:06:00	2026-08-30 11:28:29.881
81350000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-135	Internet & Phone - 4mo ago	utilities	7000	2026-04-25 11:23:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-25 11:23:00	2026-08-30 11:28:29.887
81360000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-136	Internet & Phone - 4mo ago	utilities	5500	2026-04-07 05:36:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-07 05:36:00	2026-08-30 11:28:29.893
81370000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-137	Internet & Phone - 4mo ago	utilities	350	2026-04-03 06:18:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-03 06:18:00	2026-08-30 11:28:29.902
81380000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-138	Staff Salaries - 4mo ago	salary	450000	2026-04-17 04:47:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-17 04:47:00	2026-08-30 11:28:29.913
81390000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-139	Office Supplies - 4mo ago	office_supplies	15000	2026-04-18 09:56:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-18 09:56:00	2026-08-30 11:28:29.955
81400000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-140	Marketing - Social Media - 4mo ago	marketing	35000	2026-04-13 12:05:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-13 12:05:00	2026-08-30 11:28:30.026
81410000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-141	Client Entertainment - 4mo ago	entertainment	22000	2026-04-10 06:43:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-10 06:43:00	2026-08-30 11:28:30.049
81420000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-142	Car Fuel - 4mo ago	transport	8000	2026-04-23 12:12:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-23 12:12:00	2026-08-30 11:28:30.059
81430000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-143	Website Hosting - 4mo ago	technology	5500	2026-04-03 08:07:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-03 08:07:00	2026-08-30 11:28:30.073
81440000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-144	Insurance Premium - 4mo ago	insurance	45000	2026-04-06 05:57:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-04-06 05:57:00	2026-08-30 11:28:30.082
81450000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-145	Office Rent - 3mo ago	rent	85000	2026-05-21 11:29:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-21 11:29:00	2026-08-30 11:28:30.087
81460000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-146	Office Rent - 3mo ago	rent	55000	2026-05-22 09:28:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-22 09:28:00	2026-08-30 11:28:30.092
81470000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-147	Office Rent - 3mo ago	rent	65000	2026-05-14 11:48:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-14 11:48:00	2026-08-30 11:28:30.101
81480000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-148	Office Rent - 3mo ago	rent	45000	2026-05-27 10:57:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-27 10:57:00	2026-08-30 11:28:30.106
81490000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-149	Office Rent - 3mo ago	rent	120000	2026-05-11 12:19:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-11 12:19:00	2026-08-30 11:28:30.115
81500000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-150	Electricity Bill - 3mo ago	utilities	12500	2026-05-03 09:20:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-03 09:20:00	2026-08-30 11:28:30.121
81510000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-151	Internet & Phone - 3mo ago	utilities	8500	2026-05-21 06:18:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-21 06:18:00	2026-08-30 11:28:30.126
81520000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-152	Internet & Phone - 3mo ago	utilities	6500	2026-05-27 11:55:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-27 11:55:00	2026-08-30 11:28:30.135
81530000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-153	Internet & Phone - 3mo ago	utilities	7000	2026-05-16 06:54:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-16 06:54:00	2026-08-30 11:28:30.142
81540000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-154	Internet & Phone - 3mo ago	utilities	5500	2026-05-10 07:19:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-10 07:19:00	2026-08-30 11:28:30.148
81550000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-155	Internet & Phone - 3mo ago	utilities	350	2026-05-10 08:10:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-10 08:10:00	2026-08-30 11:28:30.156
81560000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-156	Staff Salaries - 3mo ago	salary	450000	2026-05-04 06:21:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-04 06:21:00	2026-08-30 11:28:30.163
81570000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-157	Office Supplies - 3mo ago	office_supplies	15000	2026-05-12 08:26:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-12 08:26:00	2026-08-30 11:28:30.169
81580000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-158	Marketing - Social Media - 3mo ago	marketing	35000	2026-05-09 06:32:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-09 06:32:00	2026-08-30 11:28:30.176
81590000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-159	Client Entertainment - 3mo ago	entertainment	22000	2026-05-18 05:14:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-18 05:14:00	2026-08-30 11:28:30.184
81600000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-160	Car Fuel - 3mo ago	transport	8000	2026-05-06 09:03:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-06 09:03:00	2026-08-30 11:28:30.19
81610000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-161	Website Hosting - 3mo ago	technology	5500	2026-05-14 10:29:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-14 10:29:00	2026-08-30 11:28:30.201
81620000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-162	Insurance Premium - 3mo ago	insurance	45000	2026-05-14 10:46:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-05-14 10:46:00	2026-08-30 11:28:30.208
81630000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-163	Office Rent - 2mo ago	rent	85000	2026-06-19 07:17:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-19 07:17:00	2026-08-30 11:28:30.229
81640000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-164	Office Rent - 2mo ago	rent	55000	2026-06-22 11:09:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-22 11:09:00	2026-08-30 11:28:30.235
81650000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-165	Office Rent - 2mo ago	rent	65000	2026-06-19 05:32:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-19 05:32:00	2026-08-30 11:28:30.241
81660000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-166	Office Rent - 2mo ago	rent	45000	2026-06-19 11:12:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-19 11:12:00	2026-08-30 11:28:30.252
81670000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-167	Office Rent - 2mo ago	rent	120000	2026-06-25 11:42:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-25 11:42:00	2026-08-30 11:28:30.258
81680000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-168	Electricity Bill - 2mo ago	utilities	12500	2026-06-20 06:55:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-20 06:55:00	2026-08-30 11:28:30.265
81690000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-169	Internet & Phone - 2mo ago	utilities	8500	2026-06-08 06:57:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-08 06:57:00	2026-08-30 11:28:30.271
81700000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-170	Internet & Phone - 2mo ago	utilities	6500	2026-06-01 05:49:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-01 05:49:00	2026-08-30 11:28:30.278
81710000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-171	Internet & Phone - 2mo ago	utilities	7000	2026-06-26 05:33:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-26 05:33:00	2026-08-30 11:28:30.283
81720000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-172	Internet & Phone - 2mo ago	utilities	5500	2026-06-19 06:53:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-19 06:53:00	2026-08-30 11:28:30.29
81730000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-173	Internet & Phone - 2mo ago	utilities	350	2026-06-20 04:19:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-20 04:19:00	2026-08-30 11:28:30.306
81740000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-174	Staff Salaries - 2mo ago	salary	450000	2026-06-23 09:38:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-23 09:38:00	2026-08-30 11:28:30.316
81750000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-175	Office Supplies - 2mo ago	office_supplies	15000	2026-06-08 05:28:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-08 05:28:00	2026-08-30 11:28:30.322
81760000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-176	Marketing - Social Media - 2mo ago	marketing	35000	2026-06-01 05:00:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-01 05:00:00	2026-08-30 11:28:30.331
81770000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-177	Client Entertainment - 2mo ago	entertainment	22000	2026-06-18 04:53:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-18 04:53:00	2026-08-30 11:28:30.339
81780000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-178	Car Fuel - 2mo ago	transport	8000	2026-06-14 12:26:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-14 12:26:00	2026-08-30 11:28:30.344
81790000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-179	Website Hosting - 2mo ago	technology	5500	2026-06-26 11:14:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-26 11:14:00	2026-08-30 11:28:30.35
81800000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-180	Insurance Premium - 2mo ago	insurance	45000	2026-06-01 10:11:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-06-01 10:11:00	2026-08-30 11:28:30.356
81810000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-181	Office Rent - 1mo ago	rent	85000	2026-07-03 06:37:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-03 06:37:00	2026-08-30 11:28:30.361
81820000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-182	Office Rent - 1mo ago	rent	55000	2026-07-12 10:31:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-12 10:31:00	2026-08-30 11:28:30.367
81830000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-183	Office Rent - 1mo ago	rent	65000	2026-07-17 05:12:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-17 05:12:00	2026-08-30 11:28:30.371
81840000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-184	Office Rent - 1mo ago	rent	45000	2026-07-13 09:12:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-13 09:12:00	2026-08-30 11:28:30.376
81850000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-185	Office Rent - 1mo ago	rent	120000	2026-07-10 09:08:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-10 09:08:00	2026-08-30 11:28:30.381
81860000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-186	Electricity Bill - 1mo ago	utilities	12500	2026-07-19 10:14:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-19 10:14:00	2026-08-30 11:28:30.385
81870000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-187	Internet & Phone - 1mo ago	utilities	8500	2026-07-03 05:15:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-03 05:15:00	2026-08-30 11:28:30.39
81880000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-188	Internet & Phone - 1mo ago	utilities	6500	2026-07-16 11:03:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-16 11:03:00	2026-08-30 11:28:30.395
81890000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-189	Internet & Phone - 1mo ago	utilities	7000	2026-07-05 10:00:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-05 10:00:00	2026-08-30 11:28:30.4
81900000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-190	Internet & Phone - 1mo ago	utilities	5500	2026-07-03 05:50:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-03 05:50:00	2026-08-30 11:28:30.404
81910000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-191	Internet & Phone - 1mo ago	utilities	350	2026-07-27 06:31:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-27 06:31:00	2026-08-30 11:28:30.41
81920000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-192	Staff Salaries - 1mo ago	salary	450000	2026-07-18 10:15:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-18 10:15:00	2026-08-30 11:28:30.415
81930000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-193	Office Supplies - 1mo ago	office_supplies	15000	2026-07-12 05:51:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-12 05:51:00	2026-08-30 11:28:30.42
81940000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-194	Marketing - Social Media - 1mo ago	marketing	35000	2026-07-12 04:30:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-12 04:30:00	2026-08-30 11:28:30.425
81950000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-195	Client Entertainment - 1mo ago	entertainment	22000	2026-07-12 06:43:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-12 06:43:00	2026-08-30 11:28:30.43
81960000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-196	Car Fuel - 1mo ago	transport	8000	2026-07-16 12:02:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-16 12:02:00	2026-08-30 11:28:30.435
81970000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-197	Website Hosting - 1mo ago	technology	5500	2026-07-08 12:26:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-08 12:26:00	2026-08-30 11:28:30.44
81980000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-198	Insurance Premium - 1mo ago	insurance	45000	2026-07-01 12:01:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-07-01 12:01:00	2026-08-30 11:28:30.446
81990000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-199	Office Rent - Current	rent	85000	2026-08-27 08:27:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-27 08:27:00	2026-08-30 11:28:30.451
82000000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-200	Office Rent - Current	rent	55000	2026-08-25 11:19:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-25 11:19:00	2026-08-30 11:28:30.456
82010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-201	Office Rent - Current	rent	65000	2026-08-07 08:09:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-07 08:09:00	2026-08-30 11:28:30.461
82020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-202	Office Rent - Current	rent	45000	2026-08-05 10:06:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-05 10:06:00	2026-08-30 11:28:30.465
82030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-203	Office Rent - Current	rent	120000	2026-08-06 04:17:00	Property Management	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-06 04:17:00	2026-08-30 11:28:30.47
82040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-204	Electricity Bill - Current	utilities	12500	2026-08-08 10:19:00	LESCO	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-08 10:19:00	2026-08-30 11:28:30.476
82050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-205	Internet & Phone - Current	utilities	8500	2026-08-21 10:23:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-21 10:23:00	2026-08-30 11:28:30.482
82060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	EXP-2026-206	Internet & Phone - Current	utilities	6500	2026-08-24 07:29:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-24 07:29:00	2026-08-30 11:28:30.487
82070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	EXP-2026-207	Internet & Phone - Current	utilities	7000	2026-08-12 05:40:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-12 05:40:00	2026-08-30 11:28:30.493
82080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	EXP-2026-208	Internet & Phone - Current	utilities	5500	2026-08-16 08:06:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-16 08:06:00	2026-08-30 11:28:30.498
82090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	EXP-2026-209	Internet & Phone - Current	utilities	350	2026-08-10 04:28:00	PTCL	online	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-10 04:28:00	2026-08-30 11:28:30.505
82100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-210	Staff Salaries - Current	salary	450000	2026-08-03 09:24:00	Various	bank_transfer	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-03 09:24:00	2026-08-30 11:28:30.51
82110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-211	Office Supplies - Current	office_supplies	15000	2026-08-24 07:22:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-24 07:22:00	2026-08-30 11:28:30.515
82120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-212	Marketing - Social Media - Current	marketing	35000	2026-08-20 05:24:00	Meta/Google Ads	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-20 05:24:00	2026-08-30 11:28:30.521
82130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-213	Client Entertainment - Current	entertainment	22000	2026-08-27 10:50:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-27 10:50:00	2026-08-30 11:28:30.526
82140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-214	Car Fuel - Current	transport	8000	2026-08-20 04:12:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-20 04:12:00	2026-08-30 11:28:30.531
82150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-215	Website Hosting - Current	technology	5500	2026-08-19 05:08:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-19 05:08:00	2026-08-30 11:28:30.537
82160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	EXP-2026-216	Insurance Premium - Current	insurance	45000	2026-08-05 05:00:00	Various	cash	\N	\N	22222222-2222-2222-2222-222222222211	approved	f	\N	2026-08-05 05:00:00	2026-08-30 11:28:30.541
\.


--
-- Data for Name: FiscalPeriod; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."FiscalPeriod" (id, "agencyId", name, "startDate", "endDate", status, "createdAt", "updatedAt") FROM stdin;
f0010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	FY 2025-2026	2025-06-30 19:00:00	2026-06-29 19:00:00	CLOSED	2026-08-30 11:28:31.623	2026-08-30 11:28:31.623
f0010000-0000-0000-0000-000000000002	a1000000-0000-0000-0000-000000000001	FY 2026-2027	2026-06-30 19:00:00	2027-06-29 19:00:00	OPEN	2026-08-30 11:28:31.623	2026-08-30 11:28:31.623
\.


--
-- Data for Name: IdMapping; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."IdMapping" (collection, "oldId", "newId", "createdAt") FROM stdin;
\.


--
-- Data for Name: Invoice; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Invoice" (id, "agencyId", "branchId", "invoiceRef", "bookingId", "customerId", subtotal, tax, total, status, "dueDate", "paidAt", notes, terms, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
a0010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-001	70010000-0000-0000-0000-000000000001	40010000-0000-0000-0000-000000000001	225000	0	225000	paid	2026-09-04 11:27:00	2026-08-10 11:27:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-08-05 11:27:00	2026-08-30 11:28:30.692
a0020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-002	70020000-0000-0000-0000-000000000001	40030000-0000-0000-0000-000000000001	48000	0	48000	paid	2026-09-19 04:41:00	2026-08-25 04:41:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-08-20 04:41:00	2026-08-30 11:28:30.711
a0030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	INV-2026-003	70030000-0000-0000-0000-000000000001	40050000-0000-0000-0000-000000000001	520000	0	520000	paid	2026-08-26 06:31:00	2026-08-01 06:31:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-07-27 06:31:00	2026-08-30 11:28:30.722
a0040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-004	70040000-0000-0000-0000-000000000001	40020000-0000-0000-0000-000000000001	135000	0	135000	paid	2026-08-06 10:38:00	2026-07-12 10:38:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-07-07 10:38:00	2026-08-30 11:28:30.732
a0050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-005	70050000-0000-0000-0000-000000000001	40060000-0000-0000-0000-000000000001	275000	0	275000	paid	2026-07-02 10:11:00	2026-06-07 10:11:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-06-02 10:11:00	2026-08-30 11:28:30.745
a0060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	INV-2026-006	70060000-0000-0000-0000-000000000001	40040000-0000-0000-0000-000000000001	195000	0	195000	paid	2026-07-28 10:53:00	2026-07-03 10:53:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-06-28 10:53:00	2026-08-30 11:28:30.755
a0070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	INV-2026-007	70070000-0000-0000-0000-000000000001	40080000-0000-0000-0000-000000000001	380000	0	380000	paid	2026-06-05 07:58:00	2026-05-11 07:58:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-05-06 07:58:00	2026-08-30 11:28:30.766
a0080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-008	70080000-0000-0000-0000-000000000001	40090000-0000-0000-0000-000000000001	65000	0	65000	paid	2026-06-16 06:58:00	2026-05-22 06:58:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-05-17 06:58:00	2026-08-30 11:28:30.775
a0090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-009	70090000-0000-0000-0000-000000000001	40070000-0000-0000-0000-000000000001	88000	0	88000	paid	2026-05-06 06:06:00	2026-04-11 06:06:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-04-06 06:06:00	2026-08-30 11:28:30.785
a0100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-010	70100000-0000-0000-0000-000000000001	40100000-0000-0000-0000-000000000001	230000	0	230000	paid	2026-05-24 04:45:00	2026-04-29 04:45:00	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-04-24 04:45:00	2026-08-30 11:28:30.797
a0110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	INV-2026-011	70110000-0000-0000-0000-000000000001	40110000-0000-0000-0000-000000000001	130000	0	130000	sent	2026-04-04 07:33:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-03-05 07:33:00	2026-08-30 11:28:30.807
a0120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	INV-2026-012	70120000-0000-0000-0000-000000000001	40120000-0000-0000-0000-000000000001	420000	0	420000	sent	2026-04-04 10:51:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-03-05 10:51:00	2026-08-30 11:28:30.818
a0130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	INV-2026-013	70130000-0000-0000-0000-000000000001	40130000-0000-0000-0000-000000000001	38000	0	38000	sent	2026-04-07 12:26:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-03-08 12:26:00	2026-08-30 11:28:30.83
a0140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-014	70140000-0000-0000-0000-000000000001	40140000-0000-0000-0000-000000000001	95000	0	95000	sent	2026-04-14 11:16:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-03-15 11:16:00	2026-08-30 11:28:30.844
a0150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	INV-2026-015	70150000-0000-0000-0000-000000000001	40150000-0000-0000-0000-000000000001	78000	0	78000	sent	2026-02-04 10:31:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-01-05 10:31:00	2026-08-30 11:28:30.86
a0160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	INV-2026-016	70160000-0000-0000-0000-000000000001	40160000-0000-0000-0000-000000000001	45000	0	45000	sent	2026-02-05 11:20:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2026-01-06 11:20:00	2026-08-30 11:28:30.871
a0170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	INV-2026-017	70170000-0000-0000-0000-000000000001	40170000-0000-0000-0000-000000000001	245000	0	245000	draft	2026-01-24 10:33:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2025-12-25 10:33:00	2026-08-30 11:28:30.882
a0180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	INV-2026-018	70180000-0000-0000-0000-000000000001	40180000-0000-0000-0000-000000000001	115000	0	115000	draft	2026-01-06 09:07:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2025-12-07 09:07:00	2026-08-30 11:28:30.894
a0190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	INV-2026-019	70190000-0000-0000-0000-000000000001	40190000-0000-0000-0000-000000000001	220000	0	220000	draft	2025-12-22 10:26:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2025-11-22 10:26:00	2026-08-30 11:28:30.908
a0200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	INV-2026-020	70200000-0000-0000-0000-000000000001	40200000-0000-0000-0000-000000000001	170000	0	170000	draft	2025-12-03 12:04:00	\N	Thank you for choosing TripTrails Travel & Tourism	\N	f	\N	2025-11-03 12:04:00	2026-08-30 11:28:30.92
\.


--
-- Data for Name: InvoiceLine; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."InvoiceLine" (id, "agencyId", "invoiceId", description, quantity, "unitPrice", amount, "createdAt", "updatedAt") FROM stdin;
0b8e70dd-8b2f-4552-b1d8-8d43ddd50814	a1000000-0000-0000-0000-000000000001	a0010000-0000-0000-0000-000000000001	Flight Booking - Emirates (Lahore to London)	1	225000	225000	2026-08-30 11:28:30.692	2026-08-30 11:28:30.692
81df2d1e-5cd6-474a-b612-d87f2ae66d3c	a1000000-0000-0000-0000-000000000001	a0020000-0000-0000-0000-000000000001	Flight Booking - PIA (Lahore to Karachi)	1	48000	48000	2026-08-30 11:28:30.711	2026-08-30 11:28:30.711
bb0d7dee-abd3-4dad-b97b-30e24e81118c	a1000000-0000-0000-0000-000000000001	a0030000-0000-0000-0000-000000000001	Flight Booking - Emirates (Dubai to London)	1	520000	520000	2026-08-30 11:28:30.722	2026-08-30 11:28:30.722
13152fb0-a4b0-4a49-82d6-34d375934ee9	a1000000-0000-0000-0000-000000000001	a0040000-0000-0000-0000-000000000001	Flight Booking - Airblue (Lahore to Istanbul)	1	135000	135000	2026-08-30 11:28:30.732	2026-08-30 11:28:30.732
7ca6bd05-6528-47b2-a2cd-22361a2cbfeb	a1000000-0000-0000-0000-000000000001	a0050000-0000-0000-0000-000000000001	Flight Booking - Emirates (Lahore to Paris)	1	275000	275000	2026-08-30 11:28:30.745	2026-08-30 11:28:30.745
fded8a39-789b-4d6c-a9d9-a3eb44b30a9c	a1000000-0000-0000-0000-000000000001	a0060000-0000-0000-0000-000000000001	Flight Booking - PIA (Karachi to Jeddah)	1	195000	195000	2026-08-30 11:28:30.755	2026-08-30 11:28:30.755
8438734b-fb9e-457a-9bfc-0782f015c10a	a1000000-0000-0000-0000-000000000001	a0070000-0000-0000-0000-000000000001	Flight Booking - Emirates (Dubai to Male)	1	380000	380000	2026-08-30 11:28:30.766	2026-08-30 11:28:30.766
4e96be09-c010-47f7-9e88-20f4bd9e87e0	a1000000-0000-0000-0000-000000000001	a0080000-0000-0000-0000-000000000001	Flight Booking - PIA (Lahore to Gilgit)	1	65000	65000	2026-08-30 11:28:30.775	2026-08-30 11:28:30.775
1ef5a4c1-88a6-466e-a62d-dd088b0285c2	a1000000-0000-0000-0000-000000000001	a0090000-0000-0000-0000-000000000001	Flight Booking - Airblue (Lahore to Dubai)	1	88000	88000	2026-08-30 11:28:30.785	2026-08-30 11:28:30.785
372b634b-0a41-4b95-85b0-6a0df97f3545	a1000000-0000-0000-0000-000000000001	a0100000-0000-0000-0000-000000000001	Flight Booking - Emirates (Lahore to Singapore)	1	230000	230000	2026-08-30 11:28:30.797	2026-08-30 11:28:30.797
a60676a7-cd07-457b-abfa-157d24e795ba	a1000000-0000-0000-0000-000000000001	a0110000-0000-0000-0000-000000000001	Flight Booking - Air Arabia (Sharjah to Islamabad)	1	130000	130000	2026-08-30 11:28:30.807	2026-08-30 11:28:30.807
1c8626a3-36f9-48d0-b999-404f292466cd	a1000000-0000-0000-0000-000000000001	a0120000-0000-0000-0000-000000000001	Flight Booking - Emirates (Dubai to Bali)	1	420000	420000	2026-08-30 11:28:30.818	2026-08-30 11:28:30.818
5a2ec019-e1ef-458e-a1db-b2e868885932	a1000000-0000-0000-0000-000000000001	a0130000-0000-0000-0000-000000000001	Flight Booking - Airblue (Karachi to Lahore)	1	38000	38000	2026-08-30 11:28:30.83	2026-08-30 11:28:30.83
b1d7b797-105e-4c9e-90f2-a0d4b3fc2f39	a1000000-0000-0000-0000-000000000001	a0140000-0000-0000-0000-000000000001	Flight Booking - Emirates (Lahore to Dubai)	1	95000	95000	2026-08-30 11:28:30.844	2026-08-30 11:28:30.844
6bf37978-543f-4f5a-a662-e80f59481e46	a1000000-0000-0000-0000-000000000001	a0150000-0000-0000-0000-000000000001	Flight Booking - PIA (Islamabad to Skardu)	1	78000	78000	2026-08-30 11:28:30.86	2026-08-30 11:28:30.86
78cee076-81fa-4cf8-a902-bb8703fe55c0	a1000000-0000-0000-0000-000000000001	a0160000-0000-0000-0000-000000000001	Flight Booking - PIA (Peshawar to Karachi)	1	45000	45000	2026-08-30 11:28:30.871	2026-08-30 11:28:30.871
1c95e0f5-64d2-4fb5-b903-3acb779fb845	a1000000-0000-0000-0000-000000000001	a0170000-0000-0000-0000-000000000001	Flight Booking - Emirates (Lahore to London)	1	245000	245000	2026-08-30 11:28:30.882	2026-08-30 11:28:30.882
26dde61c-012b-445e-9e90-73e559923404	a1000000-0000-0000-0000-000000000001	a0180000-0000-0000-0000-000000000001	Flight Booking - Thai Airways (Karachi to Bangkok)	1	115000	115000	2026-08-30 11:28:30.894	2026-08-30 11:28:30.894
dfce07b2-37d9-4a14-9e29-64e18673772e	a1000000-0000-0000-0000-000000000001	a0190000-0000-0000-0000-000000000001	Flight Booking - Emirates (Dubai to Singapore)	1	220000	220000	2026-08-30 11:28:30.908	2026-08-30 11:28:30.908
8fe495ed-6cca-496f-92ad-8d2442827b3b	a1000000-0000-0000-0000-000000000001	a0200000-0000-0000-0000-000000000001	Flight Booking - Turkish Airlines (Islamabad to Istanbul)	1	170000	170000	2026-08-30 11:28:30.92	2026-08-30 11:28:30.92
\.


--
-- Data for Name: JournalEntry; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."JournalEntry" (id, "agencyId", "branchId", "entryNumber", date, reference, description, status, "sourceModule", "sourceId", "createdBy", "postedAt", "reversedAt", "reversingEntryId", "createdAt", "updatedAt") FROM stdin;
d0010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-001	2025-10-04 04:26:00	\N	Revenue from BK-2026-001 - London trip	POSTED	BOOKING	70010000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222201	2025-10-04 04:26:00	\N	\N	2025-10-04 04:26:00	2026-08-30 11:28:31.638
d0020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-002	2025-10-09 07:47:00	\N	Payment received from Ahmed Khan	POSTED	RECEIPT	90010000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	2025-10-09 07:47:00	\N	\N	2025-10-09 07:47:00	2026-08-30 11:28:31.669
d0030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-003	2025-10-14 04:20:00	\N	Office rent payment - Lahore HQ	POSTED	EXPENSE	80010000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	2025-10-14 04:20:00	\N	\N	2025-10-14 04:20:00	2026-08-30 11:28:31.683
d0040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-004	2025-10-24 09:46:00	\N	Staff salaries - monthly disbursement	POSTED	EXPENSE	80050000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	2025-10-24 09:46:00	\N	\N	2025-10-24 09:46:00	2026-08-30 11:28:31.696
d0050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	JE-2026-005	2025-11-03 07:12:00	\N	Revenue from BK-2026-003 - Dubai-London	POSTED	BOOKING	70030000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222204	2025-11-03 07:12:00	\N	\N	2025-11-03 07:12:00	2026-08-30 11:28:31.709
d0060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	JE-2026-006	2025-11-08 10:08:00	\N	Payment received from Tariq Mahmood	POSTED	RECEIPT	90030000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	2025-11-08 10:08:00	\N	\N	2025-11-08 10:08:00	2026-08-30 11:28:31.722
d0070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-007	2025-11-23 05:53:00	\N	Marketing expense - social media campaigns	POSTED	EXPENSE	80070000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	2025-11-23 05:53:00	\N	\N	2025-11-23 05:53:00	2026-08-30 11:28:31.737
d0080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	JE-2026-008	2025-12-23 12:32:00	\N	Revenue from BK-2026-007 - Maldives trip	POSTED	BOOKING	70070000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222204	2025-12-23 12:32:00	\N	\N	2025-12-23 12:32:00	2026-08-30 11:28:31.752
d0090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-009	2026-02-11 10:05:00	\N	Payment to Emirates Airlines	POSTED	EXPENSE	80090000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	2026-02-11 10:05:00	\N	\N	2026-02-11 10:05:00	2026-08-30 11:28:31.768
d0100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	JE-2026-010	2026-08-25 08:52:00	\N	Pending utility bills - all branches	DRAFT	EXPENSE	80110000-0000-0000-0000-000000000001	22222222-2222-2222-2222-222222222211	\N	\N	\N	2026-08-25 08:52:00	2026-08-30 11:28:31.782
\.


--
-- Data for Name: JournalLine; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."JournalLine" (id, "agencyId", "journalEntryId", "accountId", debit, credit, currency, "exchangeRate", "baseDebit", "baseCredit", description, "createdAt", "updatedAt") FROM stdin;
e0010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0010000-0000-0000-0000-000000000001	c0020000-0000-0000-0000-000000000001	225000	0	PKR	1	225000	0	AR from Ahmed Khan	2026-08-30 11:28:31.655	2026-08-30 11:28:31.655
e0020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0010000-0000-0000-0000-000000000001	c0090000-0000-0000-0000-000000000001	0	225000	PKR	1	0	225000	Flight booking revenue	2026-08-30 11:28:31.655	2026-08-30 11:28:31.655
e0030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0020000-0000-0000-0000-000000000001	c0010000-0000-0000-0000-000000000001	225000	0	PKR	1	225000	0	Bank transfer received	2026-08-30 11:28:31.675	2026-08-30 11:28:31.675
e0040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0020000-0000-0000-0000-000000000001	c0020000-0000-0000-0000-000000000001	0	225000	PKR	1	0	225000	Clear AR - Ahmed Khan	2026-08-30 11:28:31.675	2026-08-30 11:28:31.675
e0050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0030000-0000-0000-0000-000000000001	c0150000-0000-0000-0000-000000000001	85000	0	PKR	1	85000	0	Office rent expense	2026-08-30 11:28:31.688	2026-08-30 11:28:31.688
e0060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0030000-0000-0000-0000-000000000001	c0010000-0000-0000-0000-000000000001	0	85000	PKR	1	0	85000	Cash outflow	2026-08-30 11:28:31.688	2026-08-30 11:28:31.688
e0070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0040000-0000-0000-0000-000000000001	c0160000-0000-0000-0000-000000000001	450000	0	PKR	1	450000	0	Staff salaries	2026-08-30 11:28:31.702	2026-08-30 11:28:31.702
e0080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0040000-0000-0000-0000-000000000001	c0010000-0000-0000-0000-000000000001	0	450000	PKR	1	0	450000	Bank transfer - salary	2026-08-30 11:28:31.702	2026-08-30 11:28:31.702
e0090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0050000-0000-0000-0000-000000000001	c0020000-0000-0000-0000-000000000001	520000	0	PKR	1	520000	0	AR from Tariq Mahmood	2026-08-30 11:28:31.715	2026-08-30 11:28:31.715
e0100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0050000-0000-0000-0000-000000000001	c0090000-0000-0000-0000-000000000001	0	520000	PKR	1	0	520000	Flight booking revenue	2026-08-30 11:28:31.715	2026-08-30 11:28:31.715
e0110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0060000-0000-0000-0000-000000000001	c0010000-0000-0000-0000-000000000001	520000	0	PKR	1	520000	0	Bank transfer received	2026-08-30 11:28:31.728	2026-08-30 11:28:31.728
e0120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0060000-0000-0000-0000-000000000001	c0020000-0000-0000-0000-000000000001	0	520000	PKR	1	0	520000	Clear AR - Tariq Mahmood	2026-08-30 11:28:31.728	2026-08-30 11:28:31.728
e0130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0070000-0000-0000-0000-000000000001	c0170000-0000-0000-0000-000000000001	35000	0	PKR	1	35000	0	Facebook/Instagram ads	2026-08-30 11:28:31.742	2026-08-30 11:28:31.742
e0140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0070000-0000-0000-0000-000000000001	c0010000-0000-0000-0000-000000000001	0	35000	PKR	1	0	35000	Online payment	2026-08-30 11:28:31.742	2026-08-30 11:28:31.742
e0150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0080000-0000-0000-0000-000000000001	c0020000-0000-0000-0000-000000000001	380000	0	PKR	1	380000	0	AR from Amina Rashid	2026-08-30 11:28:31.758	2026-08-30 11:28:31.758
e0160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0080000-0000-0000-0000-000000000001	c0100000-0000-0000-0000-000000000001	0	380000	PKR	1	0	380000	Hotel booking revenue	2026-08-30 11:28:31.758	2026-08-30 11:28:31.758
e0170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0090000-0000-0000-0000-000000000001	c0040000-0000-0000-0000-000000000001	185000	0	PKR	1	185000	0	Supplier payment - Emirates	2026-08-30 11:28:31.773	2026-08-30 11:28:31.773
e0180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0090000-0000-0000-0000-000000000001	c0010000-0000-0000-0000-000000000001	0	185000	PKR	1	0	185000	Bank transfer to supplier	2026-08-30 11:28:31.773	2026-08-30 11:28:31.773
e0190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0100000-0000-0000-0000-000000000001	c0180000-0000-0000-0000-000000000001	42000	0	PKR	1	42000	0	Utility bills - 5 branches	2026-08-30 11:28:31.787	2026-08-30 11:28:31.787
e0200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	d0100000-0000-0000-0000-000000000001	c0040000-0000-0000-0000-000000000001	0	42000	PKR	1	0	42000	Accounts payable	2026-08-30 11:28:31.787	2026-08-30 11:28:31.787
\.


--
-- Data for Name: Lead; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Lead" (id, "agencyId", "branchId", "leadRef", name, phone, whatsapp, email, destination, "travelDate", budget, adults, children, "specialRequirements", source, status, "assignedAgentId", notes, "lastContactedAt", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
60010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-001	Zubair Ahmed	+92-300-1111001	\N	\N	London	2025-10-26 12:04:00	350000	2	0	\N	walk-in	converted	22222222-2222-2222-2222-222222222205	Walk-in customer, very interested in Europe packages	2026-08-18 08:51:00	f	\N	2025-09-08 12:04:00	2026-08-30 11:28:28.431
60020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-002	Maham Rizvi	+92-321-2222002	\N	\N	Istanbul	2025-11-04 04:35:00	180000	1	0	\N	instagram	converted	22222222-2222-2222-2222-222222222206	\N	2026-08-29 04:48:00	f	\N	2025-09-17 04:35:00	2026-08-30 11:28:28.439
60030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-003	Saifullah Niazi	+92-333-3333003	\N	\N	Maldives	2025-11-30 11:26:00	500000	2	1	\N	referral	converted	22222222-2222-2222-2222-222222222205	\N	2026-08-15 12:07:00	f	\N	2025-10-19 11:26:00	2026-08-30 11:28:28.446
60040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	LD-2026-004	Bushra Bibi	+92-345-4444004	\N	\N	Umrah	2025-11-27 06:31:00	250000	4	0	\N	website	converted	22222222-2222-2222-2222-222222222208	\N	2026-08-10 06:01:00	f	\N	2025-10-28 06:31:00	2026-08-30 11:28:28.452
60050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-005	Adnan Shah	+971-50-5555005	\N	\N	Thailand	2025-12-05 08:46:00	120000	3	0	\N	whatsapp	converted	22222222-2222-2222-2222-222222222207	\N	2026-08-04 07:03:00	f	\N	2025-11-01 08:46:00	2026-08-30 11:28:28.458
60060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-006	Komal Sharma	+92-300-6666006	\N	\N	Paris	2026-01-07 12:02:00	400000	2	0	\N	facebook	converted	22222222-2222-2222-2222-222222222206	\N	2026-08-29 12:06:00	f	\N	2025-11-23 12:02:00	2026-08-30 11:28:28.464
60070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-007	Rashid Mehmood	+92-321-7777007	\N	\N	Northern Areas	2026-01-26 08:50:00	80000	5	2	\N	walk-in	converted	22222222-2222-2222-2222-222222222205	\N	2026-07-31 06:51:00	f	\N	2025-12-22 08:50:00	2026-08-30 11:28:28.47
60080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	LD-2026-008	Shazia Kanwal	+92-333-8888008	\N	\N	China	2026-01-30 09:40:00	200000	2	0	\N	referral	converted	22222222-2222-2222-2222-222222222208	\N	2026-08-20 05:17:00	f	\N	2025-12-24 09:40:00	2026-08-30 11:28:28.476
60090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-009	Asif Javed	+971-55-9999009	\N	\N	Malaysia	2026-02-27 08:31:00	150000	2	0	\N	website	converted	22222222-2222-2222-2222-222222222207	\N	2026-08-06 06:46:00	f	\N	2026-01-23 08:31:00	2026-08-30 11:28:28.482
60100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-010	Muniba Raza	+92-345-1010010	\N	\N	Turkey	2026-02-17 08:01:00	200000	2	1	\N	instagram	converted	22222222-2222-2222-2222-222222222206	\N	2026-08-07 10:12:00	f	\N	2026-01-09 08:01:00	2026-08-30 11:28:28.488
60110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-011	Talha Qureshi	+92-300-2020020	\N	\N	Umrah	2026-04-06 04:08:00	300000	2	0	\N	walk-in	converted	22222222-2222-2222-2222-222222222205	\N	2026-08-25 10:35:00	f	\N	2026-03-07 04:08:00	2026-08-30 11:28:28.497
60120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-012	Sana Malik	+92-321-3030030	\N	\N	Bali	2026-04-07 12:34:00	280000	2	0	\N	website	converted	22222222-2222-2222-2222-222222222206	\N	2026-08-23 04:12:00	f	\N	2026-03-21 12:34:00	2026-08-30 11:28:28.504
60130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-013	Bilal Tariq	+971-50-4040040	\N	\N	London	2026-05-05 10:49:00	450000	1	0	\N	whatsapp	converted	22222222-2222-2222-2222-222222222207	\N	2026-08-24 07:21:00	f	\N	2026-03-13 10:49:00	2026-08-30 11:28:28.509
60140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	LD-2026-014	Ayesha Siddiqui	+92-333-5050050	\N	\N	Australia	2026-04-03 10:43:00	600000	2	0	\N	referral	lost	22222222-2222-2222-2222-222222222208	\N	2026-07-31 12:30:00	f	\N	2026-03-19 10:43:00	2026-08-30 11:28:28.516
60150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-015	Waleed Khan	+92-345-6060060	\N	\N	Gilgit	2026-04-10 10:35:00	60000	4	0	\N	facebook	converted	22222222-2222-2222-2222-222222222205	\N	2026-08-17 06:35:00	f	\N	2026-03-04 10:35:00	2026-08-30 11:28:28.521
60160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-016	Neha Aftab	+92-300-7070070	\N	\N	Japan	2026-05-06 08:40:00	500000	2	0	\N	instagram	contacted	22222222-2222-2222-2222-222222222206	\N	2026-08-11 07:29:00	f	\N	2026-04-04 08:40:00	2026-08-30 11:28:28.526
60170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-017	Omar Malik	+971-55-8080080	\N	\N	Singapore	2026-06-21 11:36:00	300000	3	0	\N	website	qualified	22222222-2222-2222-2222-222222222207	\N	2026-08-09 08:48:00	f	\N	2026-04-26 11:36:00	2026-08-30 11:28:28.533
60180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	LD-2026-018	Iram Basit	+92-321-9090090	\N	\N	Switzerland	2026-05-10 04:01:00	700000	2	0	\N	walk-in	new	22222222-2222-2222-2222-222222222208	\N	\N	f	\N	2026-04-02 04:01:00	2026-08-30 11:28:28.538
60190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	LD-2026-019	Farhan Abbasi	+92-333-1111212	\N	\N	Northern Areas	2026-07-02 11:23:00	90000	6	0	\N	referral	converted	22222222-2222-2222-2222-222222222209	\N	2026-08-06 12:03:00	f	\N	2026-05-16 11:23:00	2026-08-30 11:28:28.545
60200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	LD-2026-020	Saima Pervez	+92-300-2222323	\N	\N	Dubai	2026-05-31 11:58:00	150000	4	0	\N	whatsapp	contacted	22222222-2222-2222-2222-222222222210	\N	2026-08-13 08:15:00	f	\N	2026-05-03 11:58:00	2026-08-30 11:28:28.552
60210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-021	Danish Nawaz	+92-345-3333434	\N	\N	Thailand	2026-06-05 05:16:00	180000	2	0	\N	instagram	qualified	22222222-2222-2222-2222-222222222205	\N	2026-08-22 06:23:00	f	\N	2026-05-14 05:16:00	2026-08-30 11:28:28.557
60220000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-022	Amina Sheikh	+971-50-4444545	\N	\N	Maldives	2026-06-08 06:12:00	600000	2	0	\N	website	new	22222222-2222-2222-2222-222222222207	\N	\N	f	\N	2026-05-11 06:12:00	2026-08-30 11:28:28.566
60230000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-023	Kamran Ali	+92-321-5555656	\N	\N	London	2026-07-04 07:51:00	400000	2	0	\N	facebook	contacted	22222222-2222-2222-2222-222222222206	\N	2026-07-31 10:25:00	f	\N	2026-06-10 07:51:00	2026-08-30 11:28:28.571
60240000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	LD-2026-024	Fatima Noor	+92-333-6666767	\N	\N	Umrah	2026-06-29 07:27:00	280000	5	0	\N	walk-in	qualified	22222222-2222-2222-2222-222222222208	\N	2026-08-16 12:47:00	f	\N	2026-06-14 07:27:00	2026-08-30 11:28:28.578
60250000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-025	Hamza Tariq	+971-55-7777878	\N	\N	Istanbul	2026-07-16 11:47:00	200000	2	0	\N	instagram	new	22222222-2222-2222-2222-222222222207	\N	\N	f	\N	2026-06-06 11:47:00	2026-08-30 11:28:28.585
60260000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	LD-2026-026	Rida Hussain	+92-300-8888989	\N	\N	Bali	2026-06-25 11:31:00	350000	2	0	\N	referral	contacted	22222222-2222-2222-2222-222222222209	\N	2026-08-27 12:41:00	f	\N	2026-06-09 11:31:00	2026-08-30 11:28:28.591
60270000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	LD-2026-027	Taimoor Khan	+92-345-9999090	\N	\N	Paris	2026-08-15 09:35:00	500000	2	0	\N	whatsapp	new	22222222-2222-2222-2222-222222222210	\N	\N	f	\N	2026-07-06 09:35:00	2026-08-30 11:28:28.597
60280000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-028	Sidra Batool	+92-321-1010111	\N	\N	China	2026-08-14 06:09:00	250000	3	0	\N	website	new	22222222-2222-2222-2222-222222222205	\N	\N	f	\N	2026-07-06 06:09:00	2026-08-30 11:28:28.604
60290000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-029	Nasir Mehmood	+971-50-2121212	\N	\N	Singapore	2026-08-29 08:17:00	280000	2	0	\N	facebook	contacted	22222222-2222-2222-2222-222222222207	\N	2026-08-17 12:55:00	f	\N	2026-07-04 08:17:00	2026-08-30 11:28:28.608
60300000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	LD-2026-030	Hina Malik	+92-333-3232323	\N	\N	Switzerland	2026-09-17 12:30:00	800000	2	0	\N	instagram	new	22222222-2222-2222-2222-222222222206	\N	\N	f	\N	2026-08-25 12:30:00	2026-08-30 11:28:28.615
60310000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	LD-2026-031	Asad Rehman	+92-300-4343434	\N	\N	Northern Areas	2026-09-12 04:37:00	70000	4	0	\N	walk-in	new	22222222-2222-2222-2222-222222222209	\N	\N	f	\N	2026-08-26 04:37:00	2026-08-30 11:28:28.621
5ffb203b-c466-4ec5-aa3a-ff45e87bb398	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	LD-2026-032	Shah	03121212112	\N	\N	Saudi	2026-08-30 00:00:00	230000	4	5	Nothing	whatsapp	new	22222222-2222-2222-2222-222222222203	Nothingsss\n	2026-08-30 11:55:57.441	f	\N	2026-08-30 11:55:10.026	2026-08-30 11:55:57.442
\.


--
-- Data for Name: LeadActivity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."LeadActivity" (id, "agencyId", "leadId", type, description, outcome, "createdBy", "createdAt", "updatedAt") FROM stdin;
0ed33ffd-970c-4111-b36c-e721c783cd8f	a1000000-0000-0000-0000-000000000001	5ffb203b-c466-4ec5-aa3a-ff45e87bb398	note	Nothingsss\n	\N	Bilal Ahmed	2026-08-30 11:55:10.062	2026-08-30 11:55:10.062
7bc16a97-986a-400a-ab94-d2ff164ce849	a1000000-0000-0000-0000-000000000001	5ffb203b-c466-4ec5-aa3a-ff45e87bb398	whatsapp	calling dasda	no_answer	Bilal Ahmed	2026-08-30 11:55:57.433	2026-08-30 11:55:57.433
8b1a041c-34d4-4443-970e-2d3f53c9cb16	a1000000-0000-0000-0000-000000000001	60010000-0000-0000-0000-000000000001	note	Inquiry about London package	\N	Farah Noor	2025-09-18 10:17:00	2026-08-30 11:28:28.634
1c7db42a-bcec-454a-b348-4be81c9e47cf	a1000000-0000-0000-0000-000000000001	60010000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for London	\N	Ayesha Malik	2025-09-20 10:17:00	2026-08-30 11:28:28.634
543e31c2-8a55-464d-b3f8-b121e56b8b13	a1000000-0000-0000-0000-000000000001	60010000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for London	\N	Fatima Hussain	2025-09-23 10:17:00	2026-08-30 11:28:28.634
dca821a5-6e18-4a1d-aa74-46df34aee978	a1000000-0000-0000-0000-000000000001	60010000-0000-0000-0000-000000000001	booking_created	Converted to Booking - London trip	\N	Sara Khan	2025-09-28 10:17:00	2026-08-30 11:28:28.634
6e96c416-7c8e-4226-9a6b-ca5ffe5334cb	a1000000-0000-0000-0000-000000000001	60020000-0000-0000-0000-000000000001	note	Inquiry about Istanbul package	\N	Usman Ali	2025-09-14 04:48:00	2026-08-30 11:28:28.634
05b706c3-5b42-4426-a0fd-1fa37cb6f908	a1000000-0000-0000-0000-000000000001	60020000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Istanbul	\N	Hassan Raza	2025-09-16 04:48:00	2026-08-30 11:28:28.634
79bb7f85-c2eb-4620-bb70-16b8861f10a1	a1000000-0000-0000-0000-000000000001	60020000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Istanbul	\N	Ayesha Malik	2025-09-19 04:48:00	2026-08-30 11:28:28.634
73a1ca1c-2b9d-4471-be9e-578d7837197c	a1000000-0000-0000-0000-000000000001	60020000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Istanbul trip	\N	Sara Khan	2025-09-24 04:48:00	2026-08-30 11:28:28.634
e0fa88fe-591b-422d-b899-36842f970e07	a1000000-0000-0000-0000-000000000001	60030000-0000-0000-0000-000000000001	note	Inquiry about Maldives package	\N	Zain Shah	2025-10-24 09:47:00	2026-08-30 11:28:28.634
3b79c72f-3802-4339-b3cf-b661589d0854	a1000000-0000-0000-0000-000000000001	60150000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Gilgit trip	\N	Sara Khan	2026-03-25 06:39:00	2026-08-30 11:28:28.634
ed34f5c0-12fc-4193-9beb-24393e6f0482	a1000000-0000-0000-0000-000000000001	60030000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Maldives	\N	Hassan Raza	2025-10-26 09:47:00	2026-08-30 11:28:28.634
a6b00432-99a3-4f4b-a168-746e4ad7bdfc	a1000000-0000-0000-0000-000000000001	60030000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Maldives	\N	Hassan Raza	2025-10-29 09:47:00	2026-08-30 11:28:28.634
17c29ee5-de51-4f20-874d-6ccc52ada725	a1000000-0000-0000-0000-000000000001	60030000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Maldives trip	\N	Sara Khan	2025-11-03 09:47:00	2026-08-30 11:28:28.634
c326880b-6e20-44c5-88f6-ae1dc743bea8	a1000000-0000-0000-0000-000000000001	60040000-0000-0000-0000-000000000001	note	Inquiry about Umrah package	\N	Zain Shah	2025-10-01 12:09:00	2026-08-30 11:28:28.634
cc667ef5-a5f2-411c-a9ce-e01394b6f0ca	a1000000-0000-0000-0000-000000000001	60040000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Umrah	\N	Ayesha Malik	2025-10-03 12:09:00	2026-08-30 11:28:28.634
cb8e4dcb-c9b6-4122-8ea6-1de269bbb200	a1000000-0000-0000-0000-000000000001	60040000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Umrah	\N	Hassan Raza	2025-10-06 12:09:00	2026-08-30 11:28:28.634
236b52c0-a78e-4962-9d21-990d019af54c	a1000000-0000-0000-0000-000000000001	60040000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Umrah trip	\N	Sara Khan	2025-10-11 12:09:00	2026-08-30 11:28:28.634
f03f3867-035c-4cb0-8a47-dc2cd021cf20	a1000000-0000-0000-0000-000000000001	60050000-0000-0000-0000-000000000001	note	Inquiry about Thailand package	\N	Ayesha Malik	2025-11-03 12:28:00	2026-08-30 11:28:28.634
a483daa4-11a3-49ac-91e7-9c8164f1038a	a1000000-0000-0000-0000-000000000001	60050000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Thailand	\N	Ayesha Malik	2025-11-05 12:28:00	2026-08-30 11:28:28.634
3b7240d1-f406-4a0a-af92-8c3dbdcefac9	a1000000-0000-0000-0000-000000000001	60050000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Thailand	\N	Fatima Hussain	2025-11-08 12:28:00	2026-08-30 11:28:28.634
d2c79a80-dcb1-4df4-9758-2d2b90b907a8	a1000000-0000-0000-0000-000000000001	60050000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Thailand trip	\N	Sara Khan	2025-11-13 12:28:00	2026-08-30 11:28:28.634
d1753c14-f8f2-4905-8f98-e43f39aa93f3	a1000000-0000-0000-0000-000000000001	60060000-0000-0000-0000-000000000001	note	Inquiry about Paris package	\N	Fatima Hussain	2025-11-13 11:21:00	2026-08-30 11:28:28.634
baa23be9-d984-4dd1-a8ae-3f5b951db47e	a1000000-0000-0000-0000-000000000001	60060000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Paris	\N	Ayesha Malik	2025-11-15 11:21:00	2026-08-30 11:28:28.634
d735fe4f-397f-4408-9ec8-ff75869d97e0	a1000000-0000-0000-0000-000000000001	60060000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Paris	\N	Fatima Hussain	2025-11-18 11:21:00	2026-08-30 11:28:28.634
04d440ad-d0ca-4749-be21-f1e4a3bc4967	a1000000-0000-0000-0000-000000000001	60060000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Paris trip	\N	Sara Khan	2025-11-23 11:21:00	2026-08-30 11:28:28.634
f42bb712-f87b-46cf-a79a-86ae8d2f74f1	a1000000-0000-0000-0000-000000000001	60070000-0000-0000-0000-000000000001	note	Inquiry about Northern Areas package	\N	Zain Shah	2025-12-22 08:50:00	2026-08-30 11:28:28.634
c5f66595-3a29-4223-8fb0-7c821025cdf0	a1000000-0000-0000-0000-000000000001	60070000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Northern Areas	\N	Ayesha Malik	2025-12-24 08:50:00	2026-08-30 11:28:28.634
8e213a97-7be8-42bf-90ab-9e594eb65e9a	a1000000-0000-0000-0000-000000000001	60070000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Northern Areas	\N	Ayesha Malik	2025-12-27 08:50:00	2026-08-30 11:28:28.634
0967565c-cef8-4a16-9b1e-d771cfc25423	a1000000-0000-0000-0000-000000000001	60070000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Northern Areas trip	\N	Sara Khan	2026-01-01 08:50:00	2026-08-30 11:28:28.634
74dd970a-3025-4213-b660-9b5cc4b32b00	a1000000-0000-0000-0000-000000000001	60080000-0000-0000-0000-000000000001	note	Inquiry about China package	\N	Ayesha Malik	2025-12-02 11:32:00	2026-08-30 11:28:28.634
f125ecdc-c718-4370-a483-adfe64d57a04	a1000000-0000-0000-0000-000000000001	60080000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for China	\N	Ayesha Malik	2025-12-04 11:32:00	2026-08-30 11:28:28.634
407f615e-7c3a-41ae-980c-2e2634aeefc4	a1000000-0000-0000-0000-000000000001	60080000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for China	\N	Hassan Raza	2025-12-07 11:32:00	2026-08-30 11:28:28.634
54195d35-f475-4abb-a7aa-9146178b7795	a1000000-0000-0000-0000-000000000001	60080000-0000-0000-0000-000000000001	booking_created	Converted to Booking - China trip	\N	Sara Khan	2025-12-12 11:32:00	2026-08-30 11:28:28.634
9b9cfb47-c42b-4319-ad87-12245a180bed	a1000000-0000-0000-0000-000000000001	60090000-0000-0000-0000-000000000001	note	Inquiry about Malaysia package	\N	Zain Shah	2026-01-15 10:03:00	2026-08-30 11:28:28.634
79375a2a-ebcf-4a1c-af1b-ad1868967e81	a1000000-0000-0000-0000-000000000001	60090000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Malaysia	\N	Hassan Raza	2026-01-17 10:03:00	2026-08-30 11:28:28.634
db40ddfa-127d-4f26-b560-68f85cb67853	a1000000-0000-0000-0000-000000000001	60090000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Malaysia	\N	Fatima Hussain	2026-01-20 10:03:00	2026-08-30 11:28:28.634
35bf5b9c-f2b7-4eeb-b1a6-e28625c6c7c8	a1000000-0000-0000-0000-000000000001	60090000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Malaysia trip	\N	Sara Khan	2026-01-25 10:03:00	2026-08-30 11:28:28.634
671274a8-a52d-453c-9e49-ea1f3a4d120a	a1000000-0000-0000-0000-000000000001	60100000-0000-0000-0000-000000000001	note	Inquiry about Turkey package	\N	Usman Ali	2026-01-13 10:54:00	2026-08-30 11:28:28.634
94767465-cf12-4eef-b92b-13ed5d0d9189	a1000000-0000-0000-0000-000000000001	60100000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Turkey	\N	Ayesha Malik	2026-01-15 10:54:00	2026-08-30 11:28:28.634
5b3c0f06-1ab8-4860-9ae6-43c0bff7cfa7	a1000000-0000-0000-0000-000000000001	60100000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Turkey	\N	Fatima Hussain	2026-01-18 10:54:00	2026-08-30 11:28:28.634
9e2ec75e-e73d-4bd2-8982-5b685092a361	a1000000-0000-0000-0000-000000000001	60100000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Turkey trip	\N	Sara Khan	2026-01-23 10:54:00	2026-08-30 11:28:28.634
68dd3064-5005-4bfc-ab6b-fba50d5808cf	a1000000-0000-0000-0000-000000000001	60110000-0000-0000-0000-000000000001	note	Inquiry about Umrah package	\N	Usman Ali	2026-03-22 09:34:00	2026-08-30 11:28:28.634
810a8756-9ab3-4490-ac72-5e5c76230ac8	a1000000-0000-0000-0000-000000000001	60110000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Umrah	\N	Ayesha Malik	2026-03-24 09:34:00	2026-08-30 11:28:28.634
275ede18-edaa-42d8-9748-3f2cc2533e1e	a1000000-0000-0000-0000-000000000001	60110000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Umrah	\N	Fatima Hussain	2026-03-27 09:34:00	2026-08-30 11:28:28.634
9ced570e-4585-4796-80ae-658bfc963f23	a1000000-0000-0000-0000-000000000001	60110000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Umrah trip	\N	Sara Khan	2026-04-01 09:34:00	2026-08-30 11:28:28.634
2ef9e388-11f8-4a9a-8951-3d139f3a1faf	a1000000-0000-0000-0000-000000000001	60120000-0000-0000-0000-000000000001	note	Inquiry about Bali package	\N	Hassan Raza	2026-03-13 12:02:00	2026-08-30 11:28:28.634
3aae986d-0fcb-4212-a459-8055a7b98b5e	a1000000-0000-0000-0000-000000000001	60120000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Bali	\N	Ayesha Malik	2026-03-15 12:02:00	2026-08-30 11:28:28.634
9b7e6711-09ca-4d42-b113-1db113261ba8	a1000000-0000-0000-0000-000000000001	60120000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Bali	\N	Hassan Raza	2026-03-18 12:02:00	2026-08-30 11:28:28.634
2844bf5b-5cdd-4793-a3cb-97f41ba19e83	a1000000-0000-0000-0000-000000000001	60120000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Bali trip	\N	Sara Khan	2026-03-23 12:02:00	2026-08-30 11:28:28.634
f65939dc-a4af-4019-bb47-25103e633316	a1000000-0000-0000-0000-000000000001	60130000-0000-0000-0000-000000000001	note	Inquiry about London package	\N	Ayesha Malik	2026-03-14 08:42:00	2026-08-30 11:28:28.634
7d2e8095-864e-49ae-9dbe-e0f2212b3e7c	a1000000-0000-0000-0000-000000000001	60130000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for London	\N	Ayesha Malik	2026-03-16 08:42:00	2026-08-30 11:28:28.634
3fcbe0b5-8c56-4c11-a823-fb8c6949e68f	a1000000-0000-0000-0000-000000000001	60130000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for London	\N	Hassan Raza	2026-03-19 08:42:00	2026-08-30 11:28:28.634
7e75ebde-0453-4980-9fe1-4b68b2b6906b	a1000000-0000-0000-0000-000000000001	60130000-0000-0000-0000-000000000001	booking_created	Converted to Booking - London trip	\N	Sara Khan	2026-03-24 08:42:00	2026-08-30 11:28:28.634
7083ce40-8bcf-49b1-ac9a-aea47e4ebb17	a1000000-0000-0000-0000-000000000001	60140000-0000-0000-0000-000000000001	note	Inquiry about Australia package	\N	Fatima Hussain	2026-03-28 09:43:00	2026-08-30 11:28:28.634
235f7e48-15fb-4f73-8940-31a89dff7348	a1000000-0000-0000-0000-000000000001	60140000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Australia	\N	Hassan Raza	2026-03-30 09:43:00	2026-08-30 11:28:28.634
12b603ec-e3d1-4886-8faa-697f120fa30d	a1000000-0000-0000-0000-000000000001	60140000-0000-0000-0000-000000000001	note	Lead lost - budget constraints	\N	Sara Khan	2026-04-11 09:43:00	2026-08-30 11:28:28.634
3f4abf68-26bb-4e46-b2a4-8aa2cadbbdf3	a1000000-0000-0000-0000-000000000001	60150000-0000-0000-0000-000000000001	note	Inquiry about Gilgit package	\N	Fatima Hussain	2026-03-15 06:39:00	2026-08-30 11:28:28.634
8624e501-0c83-4da5-a91f-af29be44b8ab	a1000000-0000-0000-0000-000000000001	60150000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Gilgit	\N	Ayesha Malik	2026-03-17 06:39:00	2026-08-30 11:28:28.634
35942970-eaca-40b7-b0ec-dfbb5eacf22d	a1000000-0000-0000-0000-000000000001	60150000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Gilgit	\N	Hassan Raza	2026-03-20 06:39:00	2026-08-30 11:28:28.634
65e0a1f7-d10e-40f1-b5ad-0f784a113ac5	a1000000-0000-0000-0000-000000000001	60160000-0000-0000-0000-000000000001	note	Inquiry about Japan package	\N	Usman Ali	2026-04-27 09:14:00	2026-08-30 11:28:28.634
d37a1950-a68e-407f-9f48-3a743860f1ab	a1000000-0000-0000-0000-000000000001	60160000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Japan	\N	Ayesha Malik	2026-04-29 09:14:00	2026-08-30 11:28:28.634
c7b4628e-4ff2-44e5-a3f9-36dd0df4e391	a1000000-0000-0000-0000-000000000001	60170000-0000-0000-0000-000000000001	note	Inquiry about Singapore package	\N	Ayesha Malik	2026-04-09 09:08:00	2026-08-30 11:28:28.634
0c0f9cd0-409c-4ad7-9082-1bdbf0ec0119	a1000000-0000-0000-0000-000000000001	60170000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Singapore	\N	Ayesha Malik	2026-04-11 09:08:00	2026-08-30 11:28:28.634
5d4c61a4-9587-45f2-81b4-8fc82f6e6fb4	a1000000-0000-0000-0000-000000000001	60170000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Singapore	\N	Ayesha Malik	2026-04-14 09:08:00	2026-08-30 11:28:28.634
1ec19340-3e7e-4f95-8d81-658ff43b4017	a1000000-0000-0000-0000-000000000001	60180000-0000-0000-0000-000000000001	note	Inquiry about Switzerland package	\N	Ayesha Malik	2026-04-25 06:03:00	2026-08-30 11:28:28.634
6e78b62c-b63b-4cda-99a7-c1131453b010	a1000000-0000-0000-0000-000000000001	60190000-0000-0000-0000-000000000001	note	Inquiry about Northern Areas package	\N	Hassan Raza	2026-05-25 08:47:00	2026-08-30 11:28:28.634
1f9735a1-f3c9-4ae0-8760-145bd9108543	a1000000-0000-0000-0000-000000000001	60190000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Northern Areas	\N	Hassan Raza	2026-05-27 08:47:00	2026-08-30 11:28:28.634
d521da5d-2e47-488f-bb29-f7ff586033d4	a1000000-0000-0000-0000-000000000001	60190000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Northern Areas	\N	Ayesha Malik	2026-05-30 08:47:00	2026-08-30 11:28:28.634
9e511da7-343b-4056-ab46-18cce203da49	a1000000-0000-0000-0000-000000000001	60190000-0000-0000-0000-000000000001	booking_created	Converted to Booking - Northern Areas trip	\N	Sara Khan	2026-06-04 08:47:00	2026-08-30 11:28:28.634
ca6b2188-71a7-45f1-8f0a-563c44cf936e	a1000000-0000-0000-0000-000000000001	60200000-0000-0000-0000-000000000001	note	Inquiry about Dubai package	\N	Usman Ali	2026-05-26 09:02:00	2026-08-30 11:28:28.634
4dad9e9b-a331-42aa-8ea4-5fa71be5b4bc	a1000000-0000-0000-0000-000000000001	60200000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Dubai	\N	Ayesha Malik	2026-05-28 09:02:00	2026-08-30 11:28:28.634
1df28283-ebde-4f1e-95d1-3775fe64e454	a1000000-0000-0000-0000-000000000001	60210000-0000-0000-0000-000000000001	note	Inquiry about Thailand package	\N	Ayesha Malik	2026-05-16 05:58:00	2026-08-30 11:28:28.634
7603d843-f409-4264-8aa6-d4e976fba0ed	a1000000-0000-0000-0000-000000000001	60210000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Thailand	\N	Ayesha Malik	2026-05-18 05:58:00	2026-08-30 11:28:28.634
9421cb57-b969-491b-8fe4-b4f7ad8fee1c	a1000000-0000-0000-0000-000000000001	60210000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Thailand	\N	Ayesha Malik	2026-05-21 05:58:00	2026-08-30 11:28:28.634
19038231-0b54-481b-8b6e-d4c3e8880844	a1000000-0000-0000-0000-000000000001	60220000-0000-0000-0000-000000000001	note	Inquiry about Maldives package	\N	Ayesha Malik	2026-05-16 04:17:00	2026-08-30 11:28:28.634
39c90c6a-b38e-4cc7-891b-888a309ec5b5	a1000000-0000-0000-0000-000000000001	60230000-0000-0000-0000-000000000001	note	Inquiry about London package	\N	Zain Shah	2026-06-24 09:44:00	2026-08-30 11:28:28.634
2d9551b2-410e-4c6a-9c7e-c04a1f914db5	a1000000-0000-0000-0000-000000000001	60230000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for London	\N	Hassan Raza	2026-06-26 09:44:00	2026-08-30 11:28:28.634
330c6dd9-1dba-493d-8d07-033e34aa865c	a1000000-0000-0000-0000-000000000001	60240000-0000-0000-0000-000000000001	note	Inquiry about Umrah package	\N	Usman Ali	2026-06-14 10:44:00	2026-08-30 11:28:28.634
4d1ef0bc-d468-4d19-beef-496ee6ed732c	a1000000-0000-0000-0000-000000000001	60240000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Umrah	\N	Hassan Raza	2026-06-16 10:44:00	2026-08-30 11:28:28.634
6b6b495b-ae88-4489-8505-3a2feb813cd3	a1000000-0000-0000-0000-000000000001	60240000-0000-0000-0000-000000000001	whatsapp	Sent quotation via WhatsApp for Umrah	\N	Fatima Hussain	2026-06-19 10:44:00	2026-08-30 11:28:28.634
57d3d583-0def-4dfa-97e0-e52ec0f68fff	a1000000-0000-0000-0000-000000000001	60250000-0000-0000-0000-000000000001	note	Inquiry about Istanbul package	\N	Fatima Hussain	2026-06-12 05:21:00	2026-08-30 11:28:28.634
be4de766-6704-4b6c-9e57-7b3a3d0bfe23	a1000000-0000-0000-0000-000000000001	60260000-0000-0000-0000-000000000001	note	Inquiry about Bali package	\N	Ayesha Malik	2026-06-04 09:56:00	2026-08-30 11:28:28.634
4739a8d9-18ef-4a37-817e-8d660a8d427f	a1000000-0000-0000-0000-000000000001	60260000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Bali	\N	Hassan Raza	2026-06-06 09:56:00	2026-08-30 11:28:28.634
f4ef1460-59e9-44c5-b896-d09968c23f17	a1000000-0000-0000-0000-000000000001	60270000-0000-0000-0000-000000000001	note	Inquiry about Paris package	\N	Farah Noor	2026-07-26 10:57:00	2026-08-30 11:28:28.634
24c83b21-9d6e-4075-a4d3-293550a74e40	a1000000-0000-0000-0000-000000000001	60280000-0000-0000-0000-000000000001	note	Inquiry about China package	\N	Farah Noor	2026-07-13 10:21:00	2026-08-30 11:28:28.634
59cd484d-c6b9-44c3-97a9-dd9dcdac3bfb	a1000000-0000-0000-0000-000000000001	60290000-0000-0000-0000-000000000001	note	Inquiry about Singapore package	\N	Usman Ali	2026-07-09 07:04:00	2026-08-30 11:28:28.634
3d9ac7b6-e3c0-4f08-aa86-50a53f065afa	a1000000-0000-0000-0000-000000000001	60290000-0000-0000-0000-000000000001	call	Follow-up call - discussed itinerary and pricing for Singapore	\N	Hassan Raza	2026-07-11 07:04:00	2026-08-30 11:28:28.634
5eb5b91e-6b43-4533-8313-d51332063f91	a1000000-0000-0000-0000-000000000001	60300000-0000-0000-0000-000000000001	note	Inquiry about Switzerland package	\N	Farah Noor	2026-08-26 07:43:00	2026-08-30 11:28:28.634
b655ab69-3168-4f79-8840-16e86a366cba	a1000000-0000-0000-0000-000000000001	60310000-0000-0000-0000-000000000001	note	Inquiry about Northern Areas package	\N	Fatima Hussain	2026-08-17 10:35:00	2026-08-30 11:28:28.634
\.


--
-- Data for Name: Notification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Notification" (id, "agencyId", "branchId", "recipientId", type, title, body, "entityType", "entityId", "isRead", "createdAt", "updatedAt") FROM stdin;
75747632-1716-4d80-8d03-108a22aeb7f8	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222202	success	New Booking Created	BK-2026-001 created by Ayesha Malik	booking	\N	t	2026-08-14 06:17:00	2026-08-30 11:28:31.414
40c3e60f-9ba6-4f76-818e-903880d50fd5	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222202	info	New Lead Assigned	Zubair Ahmed assigned to Ayesha Malik	lead	\N	t	2026-08-17 07:40:00	2026-08-30 11:28:31.421
4bca7b0d-c70d-4ab5-88aa-4f588df5b116	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222205	success	Payment Received	Receipt RCP-2026-001 for Rs 225,000	receipt	\N	f	2026-08-27 12:03:00	2026-08-30 11:28:31.426
1da1e235-465b-471d-87b1-fbccb2617b69	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222206	warning	Quotation Expiring	QT-2026-02 expires in 3 days	quotation	\N	f	2026-08-26 05:31:00	2026-08-30 11:28:31.431
598bc46d-b72b-4da2-b629-8d5d6d7e3d4f	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222207	info	Payment Received	Partial payment of Rs 210,000 for BK-2026-012	receipt	\N	f	2026-08-11 05:26:00	2026-08-30 11:28:31.436
b075a59d-0ad6-44fa-b895-9166660340f9	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222201	error	Payment Overdue	BK-2026-026 payment is overdue	booking	\N	f	2026-08-15 12:45:00	2026-08-30 11:28:31.441
a7d74a1d-34fc-4c79-ae68-78c42c60d3d1	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222203	success	Booking Completed	BK-2026-006 - Jeddah trip completed	booking	\N	t	2026-08-03 10:43:00	2026-08-30 11:28:31.446
6e9e401f-0318-4c5e-a8ec-861191d3e734	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222208	info	New Lead	Bushra Bibi - Umrah inquiry from Karachi	lead	\N	t	2026-08-27 04:32:00	2026-08-30 11:28:31.451
6b61c828-ec2b-43c7-83a3-bbc438e22a84	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222209	success	Quotation Accepted	QT-2026-015 accepted by client	quotation	\N	f	2026-08-26 05:46:00	2026-08-30 11:28:31.455
e50a39fa-2541-44c1-9436-7fec6db8b251	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222211	warning	Invoice Overdue	INV-2026-12 payment overdue by 5 days	invoice	\N	f	2026-08-05 11:42:00	2026-08-30 11:28:31.461
de046f25-c9ea-4198-a4d3-3e4ef945f651	a1000000-0000-0000-0000-000000000001	\N	22222222-2222-2222-2222-222222222203	info	New Lead Assigned	You have been assigned a new lead: Shah	lead	5ffb203b-c466-4ec5-aa3a-ff45e87bb398	f	2026-08-30 11:55:10.096	2026-08-30 11:55:10.096
\.


--
-- Data for Name: Quotation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Quotation" (id, "agencyId", "quotationNumber", title, "leadId", "customerId", "branchId", "consultantId", "travelType", destination, "departureDate", "returnDate", adults, children, infants, currency, subtotal, "agencyFee", discount, "taxTotal", total, "estimatedProfit", status, "validUntil", "customerNotes", "internalNotes", "customerName", "customerPhone", "customerEmail", "termsTemplateId", terms, "authorizedSignature", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
b0010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-001	London Family Holiday	\N	40010000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	leisure	London	2025-11-30 07:29:00	2025-12-11 07:29:00	2	2	0	PKR	410000	25000	15000	0	450000	45000	accepted	2025-11-16 07:29:00	Looking forward to this trip!	VIP customer - priority	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2025-10-17 07:29:00	2026-08-30 11:28:30.935
b0020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-002	Istanbul Romantic Getaway	\N	40020000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222210	leisure	Istanbul	2026-01-04 08:02:00	2026-01-14 08:02:00	2	0	0	PKR	240000	15000	10000	0	265000	32000	accepted	2025-12-08 08:02:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2025-11-08 08:02:00	2026-08-30 11:28:30.961
b0030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-003	Maldives Honeymoon Package	\N	40080000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	honeymoon	Maldives	2026-01-30 09:58:00	2026-02-12 09:58:00	2	0	0	PKR	580000	25000	0	0	620000	68000	accepted	2025-12-31 09:58:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2025-12-01 09:58:00	2026-08-30 11:28:31.019
b0040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-004	Umrah Package - Family of 4	\N	40040000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	religious	Makkah	2026-02-22 04:47:00	2026-03-07 04:47:00	2	0	0	PKR	350000	20000	10000	0	380000	35000	accepted	2026-01-23 04:47:00	Looking forward to this trip!	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2025-12-24 04:47:00	2026-08-30 11:28:31.054
b0050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-005	Paris Tour - 2 Weeks	\N	40060000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	leisure	Paris	2026-03-05 05:39:00	2026-03-12 05:39:00	2	2	0	PKR	480000	25000	15000	0	520000	55000	accepted	2026-02-26 05:39:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-01-27 05:39:00	2026-08-30 11:28:31.083
b0060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-006	Dubai Shopping Festival	\N	40100000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	leisure	Dubai	2026-03-01 07:15:00	2026-03-12 07:15:00	2	0	0	PKR	170000	10000	5000	0	185000	22000	accepted	2026-02-12 07:15:00	\N	VIP customer - priority	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-01-13 07:15:00	2026-08-30 11:28:31.111
b0070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-007	Northern Areas Adventure - 10 Days	\N	40090000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	adventure	Gilgit-Baltistan	2026-04-07 12:40:00	2026-04-16 12:40:00	2	0	0	PKR	115000	8000	3000	0	125000	18000	accepted	2026-04-01 12:40:00	Looking forward to this trip!	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-03-02 12:40:00	2026-08-30 11:28:31.133
b0080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-008	China Business Trip	\N	40030000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222207	business	Shanghai	2026-04-23 07:50:00	2026-05-04 07:50:00	2	0	0	PKR	320000	20000	10000	0	350000	28000	rejected	2026-04-04 07:50:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-03-05 07:50:00	2026-08-30 11:28:31.154
b0090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-009	Thailand Beach Holiday	\N	40110000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222208	leisure	Bangkok	2026-04-03 07:55:00	2026-04-08 07:55:00	2	2	0	PKR	180000	10000	5000	0	195000	24000	accepted	2026-04-05 07:55:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-03-06 07:55:00	2026-08-30 11:28:31.17
b0100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-010	Bali Honeymoon Special	\N	40120000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222207	honeymoon	Bali	2026-05-26 08:35:00	2026-06-06 08:35:00	2	0	0	PKR	445000	25000	10000	0	480000	52000	accepted	2026-04-26 08:35:00	Looking forward to this trip!	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-03-27 08:35:00	2026-08-30 11:28:31.192
b0110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-011	Singapore Family Package	\N	40130000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	leisure	Singapore	2026-06-02 12:19:00	2026-06-15 12:19:00	2	0	0	PKR	295000	18000	8000	0	320000	38000	sent	2026-05-06 12:19:00	\N	VIP customer - priority	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-04-06 12:19:00	2026-08-30 11:28:31.213
b0120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-012	UK Student Visa Package	\N	40140000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222207	student_visa	London	2026-05-31 07:22:00	2026-06-08 07:22:00	2	0	0	PKR	700000	35000	0	0	750000	85000	sent	2026-05-13 07:22:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-04-13 07:22:00	2026-08-30 11:28:31.245
b0130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-013	Switzerland Luxury Tour	\N	40150000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222210	leisure	Zurich	2026-06-12 07:18:00	2026-06-20 07:18:00	2	2	0	PKR	800000	35000	15000	0	850000	95000	draft	2026-06-19 07:18:00	Looking forward to this trip!	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-05-20 07:18:00	2026-08-30 11:28:31.26
b0140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-014	Umrah Group Package - 8 People	\N	40160000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	religious	Makkah	2026-06-25 09:31:00	2026-07-08 09:31:00	2	0	0	PKR	480000	25000	15000	0	520000	55000	sent	2026-06-02 09:31:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-05-03 09:31:00	2026-08-30 11:28:31.275
b0150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-015	Japan Cherry Blossom Tour	\N	40170000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222208	leisure	Tokyo	2026-07-23 04:11:00	2026-07-28 04:11:00	2	0	0	PKR	640000	25000	10000	0	680000	72000	negotiation	2026-07-20 04:11:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-06-20 04:11:00	2026-08-30 11:28:31.292
b0160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-016	Malaysia & Singapore Combo	\N	40180000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222205	leisure	Kuala Lumpur	2026-07-30 12:25:00	2026-08-07 12:25:00	2	0	0	PKR	260000	12000	8000	0	280000	32000	accepted	2026-07-13 12:25:00	Looking forward to this trip!	VIP customer - priority	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-06-13 12:25:00	2026-08-30 11:28:31.308
b0170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-017	European Grand Tour - 3 Weeks	\N	40190000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	leisure	Multiple	2026-08-21 05:01:00	2026-09-01 05:01:00	2	2	0	PKR	1140000	45000	25000	0	1200000	135000	draft	2026-08-01 05:01:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-07-02 05:01:00	2026-08-30 11:28:31.327
b0180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-018	Australia Student Visa	\N	40200000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222207	student_visa	Sydney	2026-08-28 08:00:00	2026-09-11 08:00:00	2	0	0	PKR	850000	35000	0	0	900000	100000	sent	2026-08-25 08:00:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-07-26 08:00:00	2026-08-30 11:28:31.342
b0190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-019	Northern Areas Jeep Rally Tour	\N	40210000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222207	adventure	Chitral	2026-09-01 09:38:00	2026-09-14 09:38:00	2	0	0	PKR	88000	5000	2000	0	95000	12000	accepted	2026-09-06 09:38:00	Looking forward to this trip!	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-08-07 09:38:00	2026-08-30 11:28:31.358
b0200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-020	Dubai New Year Celebration	\N	40220000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222210	leisure	Dubai	2026-09-29 09:47:00	2026-10-09 09:47:00	2	0	0	PKR	205000	10000	5000	0	220000	28000	sent	2026-09-01 09:47:00	\N	\N	\N	\N	\N	\N	Payment due within 14 days of confirmation. Cancellation charges apply as per policy.	\N	f	\N	2026-08-02 09:47:00	2026-08-30 11:28:31.374
b0210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	QT-2026-021	Turkey & Georgia Tour	\N	40230000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	22222222-2222-2222-2222-222222222209	holiday_package	Istanbul	2026-10-17 05:54:00	2026-10-24 05:54:00	2	2	0	PKR	315250	18000	8000	0	325250	325250	draft	2026-09-27 00:00:00	Adventure tour includes: Return flights, Hotel/Camping accommodation, 4x4 transportation, Professional guide, All meals during trekking, and Basic first aid kit. Personal trekking gear recommended.	VIP customer - priority	\N	\N	\N	\N	1. Full payment required 14 days before departure.\n2. Cancellation charges: 30 days (10%), 15 days (25%), 7 days (50%), No-show (100%).\n3. Passport must be valid for 6 months beyond travel date.\n4. Travel insurance is mandatory and included in the package.\n5. Hotel check-in/out times are subject to hotel policy.\n6. Meal plans start from lunch on Day 1 and end at breakfast on the last day.	\N	f	\N	2026-08-28 05:54:00	2026-08-30 12:09:43.606
\.


--
-- Data for Name: QuotationAttachment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."QuotationAttachment" (id, "agencyId", "quotationId", "fileName", "fileUrl", "mimeType", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: QuotationItem; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."QuotationItem" (id, "agencyId", "quotationId", "serviceCategory", title, description, quantity, unit, "costPrice", "sellingPrice", total, "sortOrder", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
c4caca60-fef2-4d43-98e6-43d98428bcac	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Tickets	Tickets	2	Unit	0	110250	220500	0	t	2026-08-30 12:09:43.622	2026-08-30 12:07:15.242	2026-08-30 12:09:43.623
deed66ef-2c99-4d7c-ad3d-5b2ed38afbe1	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Hotel	Hotel	7	Unit	0	11250	78750	0	t	2026-08-30 12:09:43.622	2026-08-30 12:07:15.242	2026-08-30 12:09:43.623
65f0ea97-6a85-4769-bd5f-9dd4c9ba7712	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Buss	Buss	2	Unit	0	8000	16000	0	t	2026-08-30 12:09:43.622	2026-08-30 12:07:15.242	2026-08-30 12:09:43.623
0a43cbff-0af5-4693-ae3d-484a60d7e7f9	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Tickets	Tickets	2	Unit	0	110250	220500	0	t	2026-08-30 12:09:43.622	2026-08-30 12:07:54.21	2026-08-30 12:09:43.623
9f52f6d9-b573-4c4b-a961-bf5480284145	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Hotel	Hotel	7	Unit	0	11250	78750	0	t	2026-08-30 12:09:43.622	2026-08-30 12:07:54.21	2026-08-30 12:09:43.623
eaa72076-11c0-485b-8401-9561afda080e	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Buss	Buss	2	Unit	0	8000	16000	0	t	2026-08-30 12:09:43.622	2026-08-30 12:07:54.21	2026-08-30 12:09:43.623
96ed2c31-813f-4091-a2e6-da575dc00e6d	a1000000-0000-0000-0000-000000000001	b0010000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	123000	143500	287000	0	f	\N	2026-08-30 11:28:30.935	2026-08-30 11:28:30.935
502c2609-8aec-4904-bb9b-443f0393a299	a1000000-0000-0000-0000-000000000001	b0010000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	14642.85714285714	14642.85714285714	102500	1	f	\N	2026-08-30 11:28:30.935	2026-08-30 11:28:30.935
2fae6bc4-fb3d-41c3-8692-5a234063ac0b	a1000000-0000-0000-0000-000000000001	b0010000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:30.935	2026-08-30 11:28:30.935
7e8b0513-0ae3-485f-b035-e839ec176ca5	a1000000-0000-0000-0000-000000000001	b0020000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	72000	84000	168000	0	f	\N	2026-08-30 11:28:30.961	2026-08-30 11:28:30.961
40e86e64-c7d3-4431-aa6d-ad4bc24fe749	a1000000-0000-0000-0000-000000000001	b0020000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	8571.42857142857	8571.42857142857	60000	1	f	\N	2026-08-30 11:28:30.961	2026-08-30 11:28:30.961
165db314-dd3a-47cf-99a6-e308a503c8fd	a1000000-0000-0000-0000-000000000001	b0020000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:30.961	2026-08-30 11:28:30.961
6eb7d111-e1ce-460a-bbb4-82e96897a4d0	a1000000-0000-0000-0000-000000000001	b0030000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	174000	203000	406000	0	f	\N	2026-08-30 11:28:31.019	2026-08-30 11:28:31.019
6d4b9594-35dc-4071-893a-dcd22fbf6cb9	a1000000-0000-0000-0000-000000000001	b0030000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	20714.28571428571	20714.28571428571	145000	1	f	\N	2026-08-30 11:28:31.019	2026-08-30 11:28:31.019
307a1b24-223b-48a5-9824-45e56eb9da26	a1000000-0000-0000-0000-000000000001	b0030000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.019	2026-08-30 11:28:31.019
bb9ec939-07e8-463c-8529-5886f2c042f4	a1000000-0000-0000-0000-000000000001	b0040000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	105000	122500	245000	0	f	\N	2026-08-30 11:28:31.054	2026-08-30 11:28:31.054
83710da0-52c1-4686-ae7f-2608e71830d1	a1000000-0000-0000-0000-000000000001	b0040000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	12500	12500	87500	1	f	\N	2026-08-30 11:28:31.054	2026-08-30 11:28:31.054
2110aafd-9ed2-4815-9f10-545e4f454f68	a1000000-0000-0000-0000-000000000001	b0040000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.054	2026-08-30 11:28:31.054
52cc2b81-97d7-4db0-81cc-02ecd276f29c	a1000000-0000-0000-0000-000000000001	b0050000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	144000	168000	336000	0	f	\N	2026-08-30 11:28:31.083	2026-08-30 11:28:31.083
c772adbe-8d2f-42fd-b07a-715a1ba4c177	a1000000-0000-0000-0000-000000000001	b0050000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	17142.85714285714	17142.85714285714	120000	1	f	\N	2026-08-30 11:28:31.083	2026-08-30 11:28:31.083
622fd69a-5953-473a-8e43-efe9d8e04a98	a1000000-0000-0000-0000-000000000001	b0050000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.083	2026-08-30 11:28:31.083
c995309a-d5c7-4af1-bac7-6115c7aa6b82	a1000000-0000-0000-0000-000000000001	b0060000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	51000	59499.99999999999	119000	0	f	\N	2026-08-30 11:28:31.111	2026-08-30 11:28:31.111
0f6f1d5b-982c-4387-aa55-85901759d550	a1000000-0000-0000-0000-000000000001	b0060000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	6071.428571428572	6071.428571428572	42500	1	f	\N	2026-08-30 11:28:31.111	2026-08-30 11:28:31.111
4e9fdd5d-4d32-4662-9c8d-b16436b4e6e5	a1000000-0000-0000-0000-000000000001	b0060000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.111	2026-08-30 11:28:31.111
dede7ce6-dc0a-4870-9827-c0ce95e1814d	a1000000-0000-0000-0000-000000000001	b0070000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	34500	40250	80500	0	f	\N	2026-08-30 11:28:31.133	2026-08-30 11:28:31.133
fb90f4f8-3ab8-41be-87c9-e5807a26a774	a1000000-0000-0000-0000-000000000001	b0070000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	4107.142857142857	4107.142857142857	28750	1	f	\N	2026-08-30 11:28:31.133	2026-08-30 11:28:31.133
544552f4-e784-405c-9a26-d872361b2efb	a1000000-0000-0000-0000-000000000001	b0070000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.133	2026-08-30 11:28:31.133
839e5e02-fce6-44b3-8924-11f6dd5617a2	a1000000-0000-0000-0000-000000000001	b0080000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	96000	112000	224000	0	f	\N	2026-08-30 11:28:31.154	2026-08-30 11:28:31.154
e75055fc-8a16-4187-bbb6-dfb32f735ae6	a1000000-0000-0000-0000-000000000001	b0080000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	11428.57142857143	11428.57142857143	80000	1	f	\N	2026-08-30 11:28:31.154	2026-08-30 11:28:31.154
54e8220f-4612-436b-a756-7c67915c44e5	a1000000-0000-0000-0000-000000000001	b0080000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.154	2026-08-30 11:28:31.154
a3614465-1fcb-4bfb-b3c1-f22cb5866b77	a1000000-0000-0000-0000-000000000001	b0090000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	54000	62999.99999999999	126000	0	f	\N	2026-08-30 11:28:31.17	2026-08-30 11:28:31.17
a9b5d5b7-f859-41f4-9fb6-36c42391000b	a1000000-0000-0000-0000-000000000001	b0090000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	6428.571428571428	6428.571428571428	45000	1	f	\N	2026-08-30 11:28:31.17	2026-08-30 11:28:31.17
81cf38c6-b5b6-42cb-bccb-57d86df4cfb6	a1000000-0000-0000-0000-000000000001	b0090000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.17	2026-08-30 11:28:31.17
37756ca6-4d3a-448c-a256-25ca65009b9c	a1000000-0000-0000-0000-000000000001	b0100000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	133500	155750	311500	0	f	\N	2026-08-30 11:28:31.192	2026-08-30 11:28:31.192
8d51788e-2fad-44b2-85e0-a51e71106d44	a1000000-0000-0000-0000-000000000001	b0100000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	15892.85714285714	15892.85714285714	111250	1	f	\N	2026-08-30 11:28:31.192	2026-08-30 11:28:31.192
51a905d9-d50f-4ed2-953a-b22398fcc278	a1000000-0000-0000-0000-000000000001	b0100000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.192	2026-08-30 11:28:31.192
08a65a4b-8de5-44ad-b29a-0cee38e3c975	a1000000-0000-0000-0000-000000000001	b0110000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	88500	103250	206500	0	f	\N	2026-08-30 11:28:31.213	2026-08-30 11:28:31.213
57ded5c2-64ae-4173-9500-204b58b841f5	a1000000-0000-0000-0000-000000000001	b0110000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	10535.71428571429	10535.71428571429	73750	1	f	\N	2026-08-30 11:28:31.213	2026-08-30 11:28:31.213
dd73fa12-3b06-4681-b5d1-acf613bd08ad	a1000000-0000-0000-0000-000000000001	b0110000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.213	2026-08-30 11:28:31.213
9f811990-b732-4617-8239-5eb78f683a49	a1000000-0000-0000-0000-000000000001	b0120000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	210000	245000	489999.9999999999	0	f	\N	2026-08-30 11:28:31.245	2026-08-30 11:28:31.245
df25b948-851e-4a6e-a135-75887f9cbdb7	a1000000-0000-0000-0000-000000000001	b0120000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	25000	25000	175000	1	f	\N	2026-08-30 11:28:31.245	2026-08-30 11:28:31.245
0d303d9c-18a3-47dd-8b14-2b9ece0f374c	a1000000-0000-0000-0000-000000000001	b0120000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.245	2026-08-30 11:28:31.245
dfc31105-8d55-4e74-9e37-1c7b49dcc0ea	a1000000-0000-0000-0000-000000000001	b0130000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	240000	280000	560000	0	f	\N	2026-08-30 11:28:31.26	2026-08-30 11:28:31.26
69c4780e-0663-4fe4-a830-6aa66e69de82	a1000000-0000-0000-0000-000000000001	b0130000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	28571.42857142857	28571.42857142857	200000	1	f	\N	2026-08-30 11:28:31.26	2026-08-30 11:28:31.26
af64b527-d3f5-4cfc-82f4-7444227c1298	a1000000-0000-0000-0000-000000000001	b0130000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.26	2026-08-30 11:28:31.26
fdbb52ab-b657-4fa6-a281-05adc8e6633d	a1000000-0000-0000-0000-000000000001	b0140000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	144000	168000	336000	0	f	\N	2026-08-30 11:28:31.275	2026-08-30 11:28:31.275
e8817f19-acb4-49be-87e8-3de8a19900fe	a1000000-0000-0000-0000-000000000001	b0140000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	17142.85714285714	17142.85714285714	120000	1	f	\N	2026-08-30 11:28:31.275	2026-08-30 11:28:31.275
0208d193-877a-44c5-9657-ef7e54b3a793	a1000000-0000-0000-0000-000000000001	b0140000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.275	2026-08-30 11:28:31.275
feb03a5a-da41-448e-a1b9-e2043b55cb0c	a1000000-0000-0000-0000-000000000001	b0150000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	192000	224000	448000	0	f	\N	2026-08-30 11:28:31.292	2026-08-30 11:28:31.292
895e1568-eda2-4ded-9ffa-3fb0c5362004	a1000000-0000-0000-0000-000000000001	b0150000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	22857.14285714286	22857.14285714286	160000	1	f	\N	2026-08-30 11:28:31.292	2026-08-30 11:28:31.292
77a3f711-dabb-413c-933c-4305ed8f2309	a1000000-0000-0000-0000-000000000001	b0150000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.292	2026-08-30 11:28:31.292
62623b16-4231-4834-ad22-66fd831693b0	a1000000-0000-0000-0000-000000000001	b0160000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	78000	91000	182000	0	f	\N	2026-08-30 11:28:31.308	2026-08-30 11:28:31.308
a7beb981-33c6-4893-91b9-aef166dfec53	a1000000-0000-0000-0000-000000000001	b0160000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	9285.714285714286	9285.714285714286	65000	1	f	\N	2026-08-30 11:28:31.308	2026-08-30 11:28:31.308
497d3153-d5ea-4e20-8719-a2afd5db6259	a1000000-0000-0000-0000-000000000001	b0160000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.308	2026-08-30 11:28:31.308
93fb5ef8-f4ec-4f47-91dd-e796360bf431	a1000000-0000-0000-0000-000000000001	b0170000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	342000	399000	798000	0	f	\N	2026-08-30 11:28:31.327	2026-08-30 11:28:31.327
1348ed60-227d-4d76-8e0b-19cd4554809f	a1000000-0000-0000-0000-000000000001	b0170000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	40714.28571428572	40714.28571428572	285000	1	f	\N	2026-08-30 11:28:31.327	2026-08-30 11:28:31.327
2ef84024-addd-43d7-a88d-e71df18a1ceb	a1000000-0000-0000-0000-000000000001	b0170000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.327	2026-08-30 11:28:31.327
ad849e54-459b-46e2-ac92-a14414896e94	a1000000-0000-0000-0000-000000000001	b0180000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	255000	297500	595000	0	f	\N	2026-08-30 11:28:31.342	2026-08-30 11:28:31.342
12efd7af-42d8-4f26-93f7-c37bd06ff040	a1000000-0000-0000-0000-000000000001	b0180000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	30357.14285714286	30357.14285714286	212500	1	f	\N	2026-08-30 11:28:31.342	2026-08-30 11:28:31.342
f5563570-3622-4ddc-afb0-093f65ac5015	a1000000-0000-0000-0000-000000000001	b0180000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.342	2026-08-30 11:28:31.342
57214a4f-18ba-4743-9781-ba16c876b54a	a1000000-0000-0000-0000-000000000001	b0190000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	26400	30800	61599.99999999999	0	f	\N	2026-08-30 11:28:31.358	2026-08-30 11:28:31.358
5c326712-5aca-44b7-8f0c-0774ab926078	a1000000-0000-0000-0000-000000000001	b0190000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	3142.857142857143	3142.857142857143	22000	1	f	\N	2026-08-30 11:28:31.358	2026-08-30 11:28:31.358
87bf5638-34cb-47f0-802b-e7a82a357355	a1000000-0000-0000-0000-000000000001	b0190000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.358	2026-08-30 11:28:31.358
7a3a61e0-e4d0-4ea9-8ac3-875f22eb6f2a	a1000000-0000-0000-0000-000000000001	b0200000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	61500	71750	143500	0	f	\N	2026-08-30 11:28:31.374	2026-08-30 11:28:31.374
3b3e7071-522b-43f2-98de-d05ee45df84f	a1000000-0000-0000-0000-000000000001	b0200000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	7321.428571428572	7321.428571428572	51250	1	f	\N	2026-08-30 11:28:31.374	2026-08-30 11:28:31.374
7bc5262d-85eb-4050-8a6b-f1f9b529ee0c	a1000000-0000-0000-0000-000000000001	b0200000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	f	\N	2026-08-30 11:28:31.374	2026-08-30 11:28:31.374
943d3a40-3967-4bac-952c-c6317925e623	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	flight	Return Flights	\N	2	Person	94500	110250	220500	0	t	2026-08-30 12:09:43.622	2026-08-30 11:28:31.389	2026-08-30 12:09:43.623
9980ca1e-edac-4324-be75-34a4c710736c	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	hotel	Hotel Accommodation	\N	7	Night	11250	11250	78750	1	t	2026-08-30 12:09:43.622	2026-08-30 11:28:31.389	2026-08-30 12:09:43.623
3e87c1d3-a28d-4368-ac4e-1b70f6b581fa	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	transfer	Airport Transfers	\N	2	Trip	5000	8000	16000	2	t	2026-08-30 12:09:43.622	2026-08-30 11:28:31.389	2026-08-30 12:09:43.623
acc8cf32-9000-41f4-a37a-dfe0615bb331	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Tickets	Tickets	2	Unit	0	110250	220500	0	f	\N	2026-08-30 12:09:43.642	2026-08-30 12:09:43.642
459f6e77-a7c3-442f-9294-0beec26cde79	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Hotel	Hotel	7	Unit	0	11250	78750	0	f	\N	2026-08-30 12:09:43.642	2026-08-30 12:09:43.642
2a84d827-6895-4c8a-973c-6b90fd8f845d	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	general	Buss	Buss	2	Unit	0	8000	16000	0	f	\N	2026-08-30 12:09:43.642	2026-08-30 12:09:43.642
\.


--
-- Data for Name: QuotationTax; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."QuotationTax" (id, "agencyId", "quotationId", "taxName", "taxType", "taxValue", "taxAmount", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: QuotationVersion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."QuotationVersion" (id, "agencyId", "quotationId", version, changes, "createdBy", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
748b0e19-b1b3-4977-a398-d1a92164e3c4	a1000000-0000-0000-0000-000000000001	b0010000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:30.935	2026-08-30 11:28:30.935
9c31b1f4-5a4f-482d-a1d9-0e59f3d1b8db	a1000000-0000-0000-0000-000000000001	b0010000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:30.935	2026-08-30 11:28:30.935
32cababa-f636-4221-b951-378eb2c03781	a1000000-0000-0000-0000-000000000001	b0010000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:30.935	2026-08-30 11:28:30.935
ad36f59d-5d53-405a-92bf-d41c7dc73ae9	a1000000-0000-0000-0000-000000000001	b0020000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:30.961	2026-08-30 11:28:30.961
bfb7230d-3486-4617-b80d-78e91dc50e90	a1000000-0000-0000-0000-000000000001	b0020000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:30.961	2026-08-30 11:28:30.961
39815580-86a9-4818-b430-1f3b9f8ad57d	a1000000-0000-0000-0000-000000000001	b0020000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:30.961	2026-08-30 11:28:30.961
47a1f683-a2bc-444d-b6a4-8f8169f5167c	a1000000-0000-0000-0000-000000000001	b0030000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.019	2026-08-30 11:28:31.019
2676b66e-d0d2-4c4d-8216-1041fe0aeba0	a1000000-0000-0000-0000-000000000001	b0030000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.019	2026-08-30 11:28:31.019
7e5a7a73-1c62-41aa-af0b-9cec25ac76f9	a1000000-0000-0000-0000-000000000001	b0030000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.019	2026-08-30 11:28:31.019
64cfbada-fe33-4d8d-bd28-f1f19f657c45	a1000000-0000-0000-0000-000000000001	b0040000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.054	2026-08-30 11:28:31.054
60e5849c-5e43-444a-a4e0-ab63558f0c1a	a1000000-0000-0000-0000-000000000001	b0040000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.054	2026-08-30 11:28:31.054
cce44b0e-cb4a-409b-b683-65952800895d	a1000000-0000-0000-0000-000000000001	b0040000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.054	2026-08-30 11:28:31.054
b6340e1f-66b3-44e1-8aed-1529cdc19f1b	a1000000-0000-0000-0000-000000000001	b0050000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.083	2026-08-30 11:28:31.083
2f04a25d-b90a-4938-9cb0-96921e2c91d7	a1000000-0000-0000-0000-000000000001	b0050000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.083	2026-08-30 11:28:31.083
cbf6cdfe-cb8f-4dbc-b549-c91b196153c9	a1000000-0000-0000-0000-000000000001	b0050000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.083	2026-08-30 11:28:31.083
1cb7d31c-859a-4bb1-9dad-198222111d42	a1000000-0000-0000-0000-000000000001	b0060000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.111	2026-08-30 11:28:31.111
29e419cb-6e02-4296-8d0b-2ad080c580bc	a1000000-0000-0000-0000-000000000001	b0060000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.111	2026-08-30 11:28:31.111
944df411-9b23-416f-869a-f167a026e641	a1000000-0000-0000-0000-000000000001	b0060000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.111	2026-08-30 11:28:31.111
da74979e-c355-4ec2-a0fd-d1460afb3cd6	a1000000-0000-0000-0000-000000000001	b0070000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.133	2026-08-30 11:28:31.133
b70e66b3-722c-4c9c-89ee-49aae9671eb9	a1000000-0000-0000-0000-000000000001	b0070000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.133	2026-08-30 11:28:31.133
955fe28b-abae-461e-9044-5455e55994f9	a1000000-0000-0000-0000-000000000001	b0070000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.133	2026-08-30 11:28:31.133
d6ba6e46-5f3e-452f-b46d-895d78eb63a0	a1000000-0000-0000-0000-000000000001	b0080000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.154	2026-08-30 11:28:31.154
b9bdeca6-2d42-4c8b-b398-4eb95233d904	a1000000-0000-0000-0000-000000000001	b0080000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.154	2026-08-30 11:28:31.154
904d3816-febf-4aa6-89f7-21e748f30f97	a1000000-0000-0000-0000-000000000001	b0090000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.17	2026-08-30 11:28:31.17
11de4fee-c612-41c0-a3ea-77a390c16366	a1000000-0000-0000-0000-000000000001	b0090000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.17	2026-08-30 11:28:31.17
e9439612-8df5-4763-a808-c4a6a4e18e42	a1000000-0000-0000-0000-000000000001	b0090000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.17	2026-08-30 11:28:31.17
8c22d563-010f-4591-b3f7-84f36e2c4969	a1000000-0000-0000-0000-000000000001	b0100000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.192	2026-08-30 11:28:31.192
6b050b9c-8e38-4104-9050-8a1b3f3b40c3	a1000000-0000-0000-0000-000000000001	b0100000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.192	2026-08-30 11:28:31.192
455f55c5-7067-45a9-9e79-32630df598f4	a1000000-0000-0000-0000-000000000001	b0100000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.192	2026-08-30 11:28:31.192
dea394a6-c003-402d-a0d1-1041e939e778	a1000000-0000-0000-0000-000000000001	b0110000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.213	2026-08-30 11:28:31.213
12e77d1e-0e6e-4328-91e3-2bdebf4042d6	a1000000-0000-0000-0000-000000000001	b0110000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.213	2026-08-30 11:28:31.213
5d68bddf-20ed-483e-83ef-c34a793a0b6e	a1000000-0000-0000-0000-000000000001	b0120000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.245	2026-08-30 11:28:31.245
0fa5c82c-3c37-4052-86ee-58889d64efcf	a1000000-0000-0000-0000-000000000001	b0120000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.245	2026-08-30 11:28:31.245
cd2d71d0-518c-4740-b0ce-e8b5697adb3d	a1000000-0000-0000-0000-000000000001	b0130000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.26	2026-08-30 11:28:31.26
39fea5fc-f0c8-49c6-91ed-7222e5cb9262	a1000000-0000-0000-0000-000000000001	b0140000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.275	2026-08-30 11:28:31.275
80860409-ed16-4197-8b6c-a18faf26897e	a1000000-0000-0000-0000-000000000001	b0140000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.275	2026-08-30 11:28:31.275
058d1ec3-4c8a-40ae-b21e-bbc6535e4d65	a1000000-0000-0000-0000-000000000001	b0150000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.292	2026-08-30 11:28:31.292
7d3b787e-af16-4f24-bd2d-c56a3891bd56	a1000000-0000-0000-0000-000000000001	b0150000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.292	2026-08-30 11:28:31.292
eaf12338-24fa-404e-ac4c-b01cd3b14d4e	a1000000-0000-0000-0000-000000000001	b0160000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.308	2026-08-30 11:28:31.308
90d946a1-1b72-4321-9881-85a4d5ef03b7	a1000000-0000-0000-0000-000000000001	b0160000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.308	2026-08-30 11:28:31.308
716cedfe-4677-4db2-a29f-113cc06f8dfb	a1000000-0000-0000-0000-000000000001	b0160000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.308	2026-08-30 11:28:31.308
133f9547-6a68-42b2-89f1-611d1ca147ed	a1000000-0000-0000-0000-000000000001	b0170000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.327	2026-08-30 11:28:31.327
c58e8c35-165f-468b-8c0c-34c1091f92c4	a1000000-0000-0000-0000-000000000001	b0180000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.342	2026-08-30 11:28:31.342
a28e2b2e-bbd3-4f99-a750-83cccf880811	a1000000-0000-0000-0000-000000000001	b0180000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.342	2026-08-30 11:28:31.342
bb738ac0-1dbd-40ab-9d66-c3157217f8c2	a1000000-0000-0000-0000-000000000001	b0190000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.358	2026-08-30 11:28:31.358
63b280fc-9edd-4237-bbfb-0c14d94fb96d	a1000000-0000-0000-0000-000000000001	b0190000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.358	2026-08-30 11:28:31.358
1561099b-6d53-4f2c-a768-f0d9d2a06744	a1000000-0000-0000-0000-000000000001	b0190000-0000-0000-0000-000000000001	3	Quotation accepted by client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.358	2026-08-30 11:28:31.358
1f961d68-e77b-4815-af49-1e677dfb898c	a1000000-0000-0000-0000-000000000001	b0200000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222205	f	\N	2026-08-30 11:28:31.374	2026-08-30 11:28:31.374
321a5d5b-2ecb-4a4d-b3dc-3bea11aa3eb1	a1000000-0000-0000-0000-000000000001	b0200000-0000-0000-0000-000000000001	2	Quotation sent to client	22222222-2222-2222-2222-222222222206	f	\N	2026-08-30 11:28:31.374	2026-08-30 11:28:31.374
207fcebb-0275-422b-9adf-2d52e553caba	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	1	Created quotation	22222222-2222-2222-2222-222222222207	f	\N	2026-08-30 11:28:31.389	2026-08-30 11:28:31.389
d4d5497a-c6b2-4d39-a8ce-394892ee8513	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	2	Updated quotation	22222222-2222-2222-2222-222222222201	f	\N	2026-08-30 12:07:15.31	2026-08-30 12:07:15.31
53060323-d5f5-4278-96d2-64afdba1026c	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	3	Updated quotation	22222222-2222-2222-2222-222222222201	f	\N	2026-08-30 12:07:54.326	2026-08-30 12:07:54.326
567041c5-8213-487d-a5a6-cd411ffbb1d1	a1000000-0000-0000-0000-000000000001	b0210000-0000-0000-0000-000000000001	4	Updated quotation	22222222-2222-2222-2222-222222222201	f	\N	2026-08-30 12:09:43.701	2026-08-30 12:09:43.701
\.


--
-- Data for Name: Receipt; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Receipt" (id, "agencyId", "branchId", "receiptRef", "bookingId", "customerId", amount, "paymentMethod", notes, date, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
90010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-001	70010000-0000-0000-0000-000000000001	40010000-0000-0000-0000-000000000001	225000	bank_transfer	Full payment received via bank transfer	2025-10-24 11:26:00	f	\N	2025-10-17 04:25:00	2026-08-30 11:28:30.546
90020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-002	70020000-0000-0000-0000-000000000001	40030000-0000-0000-0000-000000000001	48000	cash	\N	2025-11-20 12:46:00	f	\N	2025-11-26 10:01:00	2026-08-30 11:28:30.554
90030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	RCP-2026-003	70030000-0000-0000-0000-000000000001	40050000-0000-0000-0000-000000000001	520000	bank_transfer	\N	2025-11-15 12:05:00	f	\N	2025-11-10 05:01:00	2026-08-30 11:28:30.562
90040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-004	70040000-0000-0000-0000-000000000001	40020000-0000-0000-0000-000000000001	135000	card	\N	2025-12-16 10:02:00	f	\N	2025-12-08 11:30:00	2026-08-30 11:28:30.568
90050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-005	70050000-0000-0000-0000-000000000001	40060000-0000-0000-0000-000000000001	275000	bank_transfer	\N	2025-12-06 07:01:00	f	\N	2025-12-14 04:42:00	2026-08-30 11:28:30.576
90060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	RCP-2026-006	70060000-0000-0000-0000-000000000001	40040000-0000-0000-0000-000000000001	195000	bank_transfer	\N	2026-01-26 07:51:00	f	\N	2026-01-23 05:01:00	2026-08-30 11:28:30.582
90070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	RCP-2026-007	70070000-0000-0000-0000-000000000001	40080000-0000-0000-0000-000000000001	380000	bank_transfer	\N	2026-01-13 11:09:00	f	\N	2026-01-27 05:53:00	2026-08-30 11:28:30.588
90080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-008	70080000-0000-0000-0000-000000000001	40090000-0000-0000-0000-000000000001	65000	cash	\N	2026-03-13 07:56:00	f	\N	2026-03-07 08:20:00	2026-08-30 11:28:30.594
90090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-009	70090000-0000-0000-0000-000000000001	40070000-0000-0000-0000-000000000001	88000	online	\N	2026-03-06 10:56:00	f	\N	2026-03-10 04:12:00	2026-08-30 11:28:30.601
90100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-010	70100000-0000-0000-0000-000000000001	40100000-0000-0000-0000-000000000001	230000	bank_transfer	\N	2026-03-07 11:36:00	f	\N	2026-03-27 11:11:00	2026-08-30 11:28:30.606
90110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	RCP-2026-011	70110000-0000-0000-0000-000000000001	40110000-0000-0000-0000-000000000001	130000	bank_transfer	\N	2026-03-21 09:19:00	f	\N	2026-03-07 10:41:00	2026-08-30 11:28:30.612
90120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	RCP-2026-012	70120000-0000-0000-0000-000000000001	40120000-0000-0000-0000-000000000001	210000	bank_transfer	\N	2026-04-24 08:29:00	f	\N	2026-04-27 06:54:00	2026-08-30 11:28:30.617
90130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	RCP-2026-013	70130000-0000-0000-0000-000000000001	40130000-0000-0000-0000-000000000001	38000	cash	\N	2026-04-17 11:21:00	f	\N	2026-04-20 11:36:00	2026-08-30 11:28:30.622
90140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-014	70140000-0000-0000-0000-000000000001	40140000-0000-0000-0000-000000000001	95000	bank_transfer	\N	2026-04-16 06:29:00	f	\N	2026-04-02 05:35:00	2026-08-30 11:28:30.628
90150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	RCP-2026-015	70150000-0000-0000-0000-000000000001	40150000-0000-0000-0000-000000000001	78000	cash	\N	2026-05-06 10:44:00	f	\N	2026-05-25 04:22:00	2026-08-30 11:28:30.634
90160000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	RCP-2026-016	70160000-0000-0000-0000-000000000001	40160000-0000-0000-0000-000000000001	45000	cash	\N	2026-05-11 12:14:00	f	\N	2026-05-03 09:55:00	2026-08-30 11:28:30.64
90170000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-017	70170000-0000-0000-0000-000000000001	40170000-0000-0000-0000-000000000001	120000	bank_transfer	\N	2026-05-22 08:04:00	f	\N	2026-05-13 08:32:00	2026-08-30 11:28:30.644
90180000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	RCP-2026-018	70180000-0000-0000-0000-000000000001	40180000-0000-0000-0000-000000000001	115000	bank_transfer	\N	2026-06-19 08:53:00	f	\N	2026-06-27 06:13:00	2026-08-30 11:28:30.65
90190000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	RCP-2026-019	70190000-0000-0000-0000-000000000001	40190000-0000-0000-0000-000000000001	220000	bank_transfer	\N	2026-06-18 12:24:00	f	\N	2026-06-28 07:06:00	2026-08-30 11:28:30.655
90200000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	RCP-2026-020	70200000-0000-0000-0000-000000000001	40200000-0000-0000-0000-000000000001	170000	bank_transfer	\N	2026-06-15 10:06:00	f	\N	2026-06-07 07:37:00	2026-08-30 11:28:30.66
90210000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-021	70210000-0000-0000-0000-000000000001	40210000-0000-0000-0000-000000000001	50000	card	\N	2026-07-16 08:56:00	f	\N	2026-07-16 08:28:00	2026-08-30 11:28:30.665
90220000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	RCP-2026-022	70220000-0000-0000-0000-000000000001	40220000-0000-0000-0000-000000000001	68000	cash	\N	2026-07-02 11:46:00	f	\N	2026-07-10 08:51:00	2026-08-30 11:28:30.67
90230000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	RCP-2026-023	70230000-0000-0000-0000-000000000001	40230000-0000-0000-0000-000000000001	240000	bank_transfer	\N	2026-07-16 08:04:00	f	\N	2026-07-18 07:02:00	2026-08-30 11:28:30.674
90240000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	RCP-2026-024	70240000-0000-0000-0000-000000000001	40240000-0000-0000-0000-000000000001	42000	cash	\N	2026-08-26 07:27:00	f	\N	2026-08-13 09:03:00	2026-08-30 11:28:30.68
90250000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	RCP-2026-025	70250000-0000-0000-0000-000000000001	40250000-0000-0000-0000-000000000001	105000	bank_transfer	\N	2026-08-21 06:45:00	f	\N	2026-08-01 11:33:00	2026-08-30 11:28:30.686
\.


--
-- Data for Name: RecentActivity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."RecentActivity" (id, "agencyId", "branchId", type, title, detail, "createdBy", "createdByUserId", "createdAt", "updatedAt") FROM stdin;
69bdd8f4-becc-469e-ab17-bce97f31cb56	a1000000-0000-0000-0000-000000000001	\N	booking	Booking Created	BK-2026-028 - Dubai trip for Usama Tariq	Ayesha Malik	\N	2026-08-28 06:02:00	2026-08-30 11:28:31.466
642d4e46-f22f-4c7c-9d25-dea556c9bd06	a1000000-0000-0000-0000-000000000001	\N	receipt	Payment Received	Rs 85,000 from Usama Tariq (RCP-2026-025)	Zainab Noor	\N	2026-08-28 05:39:00	2026-08-30 11:28:31.473
d3a5bd3f-29dd-4062-843e-1e08a16c1a84	a1000000-0000-0000-0000-000000000001	\N	quotation	Quotation Sent	QT-2026-021 sent to Kamran Ali	Hassan Raza	\N	2026-08-27 04:59:00	2026-08-30 11:28:31.478
0b9036d7-12b9-415b-add8-f2279ef35471	a1000000-0000-0000-0000-000000000001	\N	lead	New Lead	Hina Malik - Switzerland inquiry	Hassan Raza	\N	2026-08-27 04:30:00	2026-08-30 11:28:31.483
a4640665-a4ed-4840-9ca9-09be20ee0efb	a1000000-0000-0000-0000-000000000001	\N	booking	Booking Created	BK-2026-027 - Gilgit trip for Danish Nawaz	Ayesha Malik	\N	2026-08-26 11:05:00	2026-08-30 11:28:31.487
8662754f-f324-4528-bfcb-ee4dde23f6b6	a1000000-0000-0000-0000-000000000001	\N	expense	Expense Recorded	Office Rent Lahore - Rs 85,000	Zainab Noor	\N	2026-08-25 04:03:00	2026-08-30 11:28:31.496
944e6fa9-3520-4c91-9fac-a7c4945ad909	a1000000-0000-0000-0000-000000000001	\N	quotation	Quotation Accepted	QT-2026-016 accepted by Amina Sheikh	Fatima Hussain	\N	2026-08-24 12:37:00	2026-08-30 11:28:31.501
6ac0dada-0b1e-4b1d-a3db-9a33427d9d10	a1000000-0000-0000-0000-000000000001	\N	receipt	Payment Received	Rs 240,000 from Bilal Tariq (RCP-2026-022)	Omar Farooq	\N	2026-08-23 08:57:00	2026-08-30 11:28:31.505
e542d6ae-6418-4022-bd81-b4989e9bf517	a1000000-0000-0000-0000-000000000001	\N	booking	Booking Completed	BK-2026-024 - Sharjah trip completed	Farah Noor	\N	2026-08-22 06:03:00	2026-08-30 11:28:31.509
c25c7646-2b8a-4cf6-814b-a10764f850e6	a1000000-0000-0000-0000-000000000001	\N	lead	Lead Converted	Taimoor Khan converted to booking	Zain Shah	\N	2026-08-21 11:54:00	2026-08-30 11:28:31.514
\.


--
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Role" (id, "agencyId", name, description, permissions, color, "textColor", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
33333333-3333-3333-3333-333333333301	a1000000-0000-0000-0000-000000000001	admin	Full system access - agency owner	{all}	#dc2626	#ffffff	f	\N	2026-08-30 11:28:27.648	2026-08-30 11:28:27.648
33333333-3333-3333-3333-333333333302	a1000000-0000-0000-0000-000000000001	manager	Branch manager - full branch access	{"Bookings: View","Bookings: Create","Bookings: Edit","Bookings: Delete","Customers: View","Customers: Create","Customers: Edit","Customers: Delete","Leads: View","Leads: Create","Leads: Edit","Leads: Delete","Expenses: View","Expenses: Create","Expenses: Edit","Expenses: Delete","Quotations: View","Quotations: Create","Quotations: Edit","Quotations: Delete","Invoices: View","Invoices: Create","Invoices: Edit","Receipts: View","Receipts: Create","Receipts: Edit","Suppliers: View","Suppliers: Create","Suppliers: Edit","Suppliers: Delete","Branches: View","Branches: Edit","Users: View","Users: Create","Users: Edit","Reports: View","Reports: Export","Settings: View","Settings: Edit","Templates: View","Templates: Create","Templates: Edit","Templates: Delete","Roles: View","Roles: Edit"}	#2563eb	#ffffff	f	\N	2026-08-30 11:28:27.648	2026-08-30 11:28:27.648
33333333-3333-3333-3333-333333333303	a1000000-0000-0000-0000-000000000001	agent	Travel agent - booking and customer access	{"Bookings: View","Bookings: Create","Bookings: Edit","Customers: View","Customers: Create","Customers: Edit","Leads: View","Leads: Create","Leads: Edit","Quotations: View","Quotations: Create","Quotations: Edit","Invoices: View","Receipts: View","Receipts: Create","Suppliers: View"}	#16a34a	#ffffff	f	\N	2026-08-30 11:28:27.648	2026-08-30 11:28:27.648
33333333-3333-3333-3333-333333333304	a1000000-0000-0000-0000-000000000001	accountant	Financial and accounting access	{"Bookings: View","Customers: View","Leads: View","Expenses: View","Expenses: Create","Expenses: Edit","Invoices: View","Invoices: Create","Invoices: Edit","Receipts: View","Receipts: Create","Receipts: Edit","Suppliers: View","Suppliers: Edit","Reports: View","Reports: Export"}	#9333ea	#ffffff	f	\N	2026-08-30 11:28:27.648	2026-08-30 11:28:27.648
\.


--
-- Data for Name: Supplier; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Supplier" (id, "agencyId", name, category, "contactPerson", email, phone, website, address, city, country, "taxId", balance, status, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
50010000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	PIA - Pakistan International Airlines	airline	Reservations Desk	\N	+92-21-111786786	\N	\N	Karachi	Pakistan	\N	0	active	f	\N	2025-09-18 05:19:00	2026-08-30 11:28:28.347
50020000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Airblue	airline	Trade Desk	\N	+92-21-111247247	\N	\N	Karachi	Pakistan	\N	0	active	f	\N	2025-09-14 12:32:00	2026-08-30 11:28:28.354
50030000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Emirates Airlines	airline	Corporate Sales	\N	+971-600-555555	\N	\N	Dubai	UAE	\N	0	active	f	\N	2025-09-16 07:02:00	2026-08-30 11:28:28.36
50040000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Serena Hotels Pakistan	hotel	Group Bookings	\N	+92-51-2878070	\N	\N	Islamabad	Pakistan	\N	0	active	f	\N	2025-09-09 05:28:00	2026-08-30 11:28:28.366
50050000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Pearl Continental Hotels	hotel	MICE Desk	\N	+92-42-35781000	\N	\N	Lahore	Pakistan	\N	0	active	f	\N	2025-09-08 05:56:00	2026-08-30 11:28:28.371
50060000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Saudi Travel Agency	ground_handler	Hajj/Umrah Desk	\N	+966-11-2654321	\N	\N	Jeddah	Saudi Arabia	\N	0	active	f	\N	2025-09-26 06:20:00	2026-08-30 11:28:28.376
50070000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	VisaMaster Consultants	visa_agent	Processing Team	\N	+92-42-35678901	\N	\N	Lahore	Pakistan	\N	0	active	f	\N	2025-09-27 12:06:00	2026-08-30 11:28:28.383
50080000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	TravelGuard Insurance	insurance	Policy Sales	\N	+92-42-34567890	\N	\N	Lahore	Pakistan	\N	0	active	f	\N	2025-09-02 07:31:00	2026-08-30 11:28:28.388
50090000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Air Arabia	airline	Trade Relations	\N	+971-600-566666	\N	\N	Sharjah	UAE	\N	0	active	f	\N	2025-09-01 09:42:00	2026-08-30 11:28:28.392
50100000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Thai Airways	airline	Pakistan Office	\N	+92-21-34567890	\N	\N	Karachi	Pakistan	\N	0	active	f	\N	2025-09-22 06:46:00	2026-08-30 11:28:28.399
50110000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Marriott Hotels Pakistan	hotel	Group Sales	\N	+92-51-2826826	\N	\N	Islamabad	Pakistan	\N	0	active	f	\N	2025-09-22 05:36:00	2026-08-30 11:28:28.404
50120000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Zowaa Tours & Travels	ground_handler	Operations	\N	+92-51-4445566	\N	\N	Islamabad	Pakistan	\N	0	active	f	\N	2025-09-05 05:33:00	2026-08-30 11:28:28.409
50130000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Allianz Insurance Pakistan	insurance	Corporate Sales	\N	+92-21-35678901	\N	\N	Karachi	Pakistan	\N	0	active	f	\N	2025-09-28 05:54:00	2026-08-30 11:28:28.415
50140000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Turkish Airlines	airline	GSA Pakistan	\N	+92-21-34567891	\N	\N	Karachi	Pakistan	\N	0	active	f	\N	2025-09-24 05:58:00	2026-08-30 11:28:28.42
50150000-0000-0000-0000-000000000001	a1000000-0000-0000-0000-000000000001	Hunza Serena Inn	hotel	Reservations	\N	+92-5841-83077	\N	\N	Gilgit	Pakistan	\N	0	active	f	\N	2025-09-25 07:16:00	2026-08-30 11:28:28.424
\.


--
-- Data for Name: SupplierPayment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."SupplierPayment" (id, "agencyId", "branchId", "supplierId", "paymentRef", amount, "paymentMethod", notes, date, "recordedById", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: Template; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Template" (id, "agencyId", name, type, content, "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
5772ef1b-281e-423d-a0d4-728817f9eb5c	a1000000-0000-0000-0000-000000000001	Default Quotation Notes	quotation_notes	Thank you for choosing TripTrails Travel & Tourism. This quotation is valid for 30 days from the date of issue. Prices are subject to availability and may change without prior notice. All prices are in PKR unless otherwise specified.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
661bfbb8-ac5b-440b-bd9f-514544548722	a1000000-0000-0000-0000-000000000001	Standard Terms & Conditions	quotation_terms	1. Full payment required 14 days before departure.\n2. Cancellation charges: 30 days (10%), 15 days (25%), 7 days (50%), No-show (100%).\n3. Passport must be valid for 6 months beyond travel date.\n4. Travel insurance is mandatory and included in the package.\n5. Hotel check-in/out times are subject to hotel policy.\n6. Meal plans start from lunch on Day 1 and end at breakfast on the last day.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
602816be-e59f-40e8-8fab-f8dd64c0d8bf	a1000000-0000-0000-0000-000000000001	Default Invoice Notes	invoice_notes	Payment is due within 30 days of invoice date. Late payments will incur a 2% monthly surcharge. For payments via bank transfer, please reference the invoice number in the transfer description.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
14d44c0f-191c-40f8-8e93-ef99c936eb72	a1000000-0000-0000-0000-000000000001	Standard Invoice Terms	invoice_terms	Payment Methods: Bank Transfer, Cash, Online Payment.\nAll amounts are in PKR.\nFor queries, contact accounts@triptrails.pk or call +92-42-35789012.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
2b9c71f1-cc20-4619-9e40-c6bd3f889020	a1000000-0000-0000-0000-000000000001	Umrah Package Notes	quotation_notes	Umrah package includes: Return flights, Hotel accommodation (Makkah & Madinah), Ground transfers, Visa processing, and Ziyarat tours. Zodiac/Cisco accommodation subject to availability.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
f71bf2fe-4a73-4726-b9c8-02db2ce1f358	a1000000-0000-0000-0000-000000000001	Honeymoon Package Notes	quotation_notes	Honeymoon package includes: Return flights, Luxury hotel accommodation, Airport transfers, Special room decoration, Candlelight dinner, and Couple spa session. Additional experiences available on request.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
ddb26f2b-0b0c-4f3b-8748-abd9398cf664	a1000000-0000-0000-0000-000000000001	Adventure Tour Notes	quotation_notes	Adventure tour includes: Return flights, Hotel/Camping accommodation, 4x4 transportation, Professional guide, All meals during trekking, and Basic first aid kit. Personal trekking gear recommended.	f	\N	2026-08-30 11:28:31.404	2026-08-30 11:28:31.404
\.


--
-- Data for Name: TokenBlacklist; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TokenBlacklist" (id, token, "expiresAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, "agencyId", "branchId", "firstName", "lastName", email, password, phone, role, status, "avatarUrl", "lastLoginAt", "isDeleted", "deletedAt", "createdAt", "updatedAt") FROM stdin;
22222222-2222-2222-2222-222222222202	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	Sara	Khan	sara@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-321-2345678	manager	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222203	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	Ahmed	Raza	ahmed.razatr@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-300-9876543	manager	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222204	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	Omar	Farooq	omar@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+971-50-1234567	manager	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222205	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	Ayesha	Malik	agent1@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-333-3456789	agent	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222206	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	Hassan	Raza	hassan@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-345-4567890	agent	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222207	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111105	Fatima	Hussain	fatima@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+971-55-9876543	agent	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222208	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111102	Usman	Ali	usman@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-300-5678901	agent	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222209	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111103	Zain	Shah	zain@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-312-1112233	agent	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222210	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111104	Farah	Noor	farah@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-345-9988776	agent	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222211	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	Zainab	Noor	zainab@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-312-6789012	accountant	active	\N	\N	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:28:27.667
22222222-2222-2222-2222-222222222201	a1000000-0000-0000-0000-000000000001	11111111-1111-1111-1111-111111111101	Bilal	Ahmed	owner@triptrails.pk	$2a$12$al0JL/fOYgy6jCT03INUducXcoWHTVzUukxEXazX1odL082h2d3Fu	+92-300-1234567	admin	active	\N	2026-08-30 11:32:12.864	f	\N	2026-08-30 11:28:27.667	2026-08-30 11:32:12.867
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
eaae96fa-67f3-4f43-bfd0-6487cb3190ee	f2d98d6c6d44cc823873623d69e5ca2100b8daef738020f254a1863039ad6a3c	2026-08-30 03:05:55.278636+00	20260830004154_init	\N	\N	2026-08-30 03:05:50.365779+00	1
19b0f68d-fcb6-44fa-a32b-50742a32cbb8	99af2b3ef8a66c6eac2a3f8fbc40bf1534fb531612a98909cd794a77123db3c0	2026-08-30 03:05:55.39695+00	20260830005303_add_id_mapping	\N	\N	2026-08-30 03:05:55.291151+00	1
74ed5b37-e9d8-4119-8749-f6e868c11e9d	36997e5b437d75c02f125f231577650371b466cffc435931f7affbe3dfb5a508	2026-08-30 03:05:56.991435+00	20260830013523_decimal_to_float	\N	\N	2026-08-30 03:05:55.408657+00	1
\.


--
-- Name: Agency Agency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Agency"
    ADD CONSTRAINT "Agency_pkey" PRIMARY KEY (id);


--
-- Name: BookingActivity BookingActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingActivity"
    ADD CONSTRAINT "BookingActivity_pkey" PRIMARY KEY (id);


--
-- Name: BookingDocument BookingDocument_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingDocument"
    ADD CONSTRAINT "BookingDocument_pkey" PRIMARY KEY (id);


--
-- Name: Booking Booking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_pkey" PRIMARY KEY (id);


--
-- Name: Branch Branch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_pkey" PRIMARY KEY (id);


--
-- Name: ChartOfAccount ChartOfAccount_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChartOfAccount"
    ADD CONSTRAINT "ChartOfAccount_pkey" PRIMARY KEY (id);


--
-- Name: Counter Counter_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Counter"
    ADD CONSTRAINT "Counter_pkey" PRIMARY KEY (id);


--
-- Name: CustomerDocument CustomerDocument_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerDocument"
    ADD CONSTRAINT "CustomerDocument_pkey" PRIMARY KEY (id);


--
-- Name: CustomerNote CustomerNote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerNote"
    ADD CONSTRAINT "CustomerNote_pkey" PRIMARY KEY (id);


--
-- Name: Customer Customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "Customer_pkey" PRIMARY KEY (id);


--
-- Name: Expense Expense_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_pkey" PRIMARY KEY (id);


--
-- Name: FiscalPeriod FiscalPeriod_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FiscalPeriod"
    ADD CONSTRAINT "FiscalPeriod_pkey" PRIMARY KEY (id);


--
-- Name: IdMapping IdMapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."IdMapping"
    ADD CONSTRAINT "IdMapping_pkey" PRIMARY KEY (collection, "oldId");


--
-- Name: InvoiceLine InvoiceLine_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoiceLine"
    ADD CONSTRAINT "InvoiceLine_pkey" PRIMARY KEY (id);


--
-- Name: Invoice Invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_pkey" PRIMARY KEY (id);


--
-- Name: JournalEntry JournalEntry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalEntry"
    ADD CONSTRAINT "JournalEntry_pkey" PRIMARY KEY (id);


--
-- Name: JournalLine JournalLine_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalLine"
    ADD CONSTRAINT "JournalLine_pkey" PRIMARY KEY (id);


--
-- Name: LeadActivity LeadActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LeadActivity"
    ADD CONSTRAINT "LeadActivity_pkey" PRIMARY KEY (id);


--
-- Name: Lead Lead_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lead"
    ADD CONSTRAINT "Lead_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: QuotationAttachment QuotationAttachment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationAttachment"
    ADD CONSTRAINT "QuotationAttachment_pkey" PRIMARY KEY (id);


--
-- Name: QuotationItem QuotationItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationItem"
    ADD CONSTRAINT "QuotationItem_pkey" PRIMARY KEY (id);


--
-- Name: QuotationTax QuotationTax_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationTax"
    ADD CONSTRAINT "QuotationTax_pkey" PRIMARY KEY (id);


--
-- Name: QuotationVersion QuotationVersion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationVersion"
    ADD CONSTRAINT "QuotationVersion_pkey" PRIMARY KEY (id);


--
-- Name: Quotation Quotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_pkey" PRIMARY KEY (id);


--
-- Name: Receipt Receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Receipt"
    ADD CONSTRAINT "Receipt_pkey" PRIMARY KEY (id);


--
-- Name: RecentActivity RecentActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RecentActivity"
    ADD CONSTRAINT "RecentActivity_pkey" PRIMARY KEY (id);


--
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY (id);


--
-- Name: SupplierPayment SupplierPayment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SupplierPayment"
    ADD CONSTRAINT "SupplierPayment_pkey" PRIMARY KEY (id);


--
-- Name: Supplier Supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_pkey" PRIMARY KEY (id);


--
-- Name: Template Template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Template"
    ADD CONSTRAINT "Template_pkey" PRIMARY KEY (id);


--
-- Name: TokenBlacklist TokenBlacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TokenBlacklist"
    ADD CONSTRAINT "TokenBlacklist_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Agency_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Agency_isDeleted_idx" ON public."Agency" USING btree ("isDeleted");


--
-- Name: Agency_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Agency_slug_key" ON public."Agency" USING btree (slug);


--
-- Name: Agency_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Agency_status_idx" ON public."Agency" USING btree (status);


--
-- Name: BookingActivity_agencyId_bookingId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingActivity_agencyId_bookingId_createdAt_idx" ON public."BookingActivity" USING btree ("agencyId", "bookingId", "createdAt");


--
-- Name: BookingDocument_agencyId_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "BookingDocument_agencyId_bookingId_idx" ON public."BookingDocument" USING btree ("agencyId", "bookingId");


--
-- Name: Booking_agencyId_agentId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_agentId_idx" ON public."Booking" USING btree ("agencyId", "agentId");


--
-- Name: Booking_agencyId_bookingRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Booking_agencyId_bookingRef_key" ON public."Booking" USING btree ("agencyId", "bookingRef");


--
-- Name: Booking_agencyId_bookingStatus_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_bookingStatus_idx" ON public."Booking" USING btree ("agencyId", "bookingStatus");


--
-- Name: Booking_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_branchId_idx" ON public."Booking" USING btree ("agencyId", "branchId");


--
-- Name: Booking_agencyId_customerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_customerId_idx" ON public."Booking" USING btree ("agencyId", "customerId");


--
-- Name: Booking_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_idx" ON public."Booking" USING btree ("agencyId");


--
-- Name: Booking_agencyId_isDeleted_branchId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_isDeleted_branchId_createdAt_idx" ON public."Booking" USING btree ("agencyId", "isDeleted", "branchId", "createdAt");


--
-- Name: Booking_agencyId_isDeleted_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_isDeleted_createdAt_idx" ON public."Booking" USING btree ("agencyId", "isDeleted", "createdAt" DESC);


--
-- Name: Booking_agencyId_isDeleted_customerId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_isDeleted_customerId_createdAt_idx" ON public."Booking" USING btree ("agencyId", "isDeleted", "customerId", "createdAt");


--
-- Name: Booking_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_isDeleted_idx" ON public."Booking" USING btree ("agencyId", "isDeleted");


--
-- Name: Booking_agencyId_isDeleted_supplierId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_isDeleted_supplierId_createdAt_idx" ON public."Booking" USING btree ("agencyId", "isDeleted", "supplierId", "createdAt");


--
-- Name: Booking_agencyId_paymentStatus_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Booking_agencyId_paymentStatus_idx" ON public."Booking" USING btree ("agencyId", "paymentStatus");


--
-- Name: Branch_agencyId_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Branch_agencyId_code_key" ON public."Branch" USING btree ("agencyId", code);


--
-- Name: Branch_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Branch_agencyId_idx" ON public."Branch" USING btree ("agencyId");


--
-- Name: Branch_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Branch_agencyId_isDeleted_idx" ON public."Branch" USING btree ("agencyId", "isDeleted");


--
-- Name: ChartOfAccount_agencyId_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "ChartOfAccount_agencyId_code_key" ON public."ChartOfAccount" USING btree ("agencyId", code);


--
-- Name: ChartOfAccount_agencyId_isActive_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChartOfAccount_agencyId_isActive_idx" ON public."ChartOfAccount" USING btree ("agencyId", "isActive");


--
-- Name: ChartOfAccount_agencyId_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ChartOfAccount_agencyId_type_idx" ON public."ChartOfAccount" USING btree ("agencyId", type);


--
-- Name: CustomerDocument_agencyId_customerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CustomerDocument_agencyId_customerId_idx" ON public."CustomerDocument" USING btree ("agencyId", "customerId");


--
-- Name: CustomerNote_agencyId_customerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CustomerNote_agencyId_customerId_idx" ON public."CustomerNote" USING btree ("agencyId", "customerId");


--
-- Name: Customer_agencyId_customerRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Customer_agencyId_customerRef_key" ON public."Customer" USING btree ("agencyId", "customerRef");


--
-- Name: Customer_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Customer_agencyId_idx" ON public."Customer" USING btree ("agencyId");


--
-- Name: Customer_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Customer_agencyId_isDeleted_idx" ON public."Customer" USING btree ("agencyId", "isDeleted");


--
-- Name: Customer_agencyId_phone_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Customer_agencyId_phone_idx" ON public."Customer" USING btree ("agencyId", phone);


--
-- Name: Expense_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_agencyId_branchId_idx" ON public."Expense" USING btree ("agencyId", "branchId");


--
-- Name: Expense_agencyId_expenseRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Expense_agencyId_expenseRef_key" ON public."Expense" USING btree ("agencyId", "expenseRef");


--
-- Name: Expense_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_agencyId_idx" ON public."Expense" USING btree ("agencyId");


--
-- Name: Expense_agencyId_isDeleted_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_agencyId_isDeleted_date_idx" ON public."Expense" USING btree ("agencyId", "isDeleted", date DESC);


--
-- Name: Expense_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Expense_agencyId_isDeleted_idx" ON public."Expense" USING btree ("agencyId", "isDeleted");


--
-- Name: FiscalPeriod_agencyId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "FiscalPeriod_agencyId_status_idx" ON public."FiscalPeriod" USING btree ("agencyId", status);


--
-- Name: IdMapping_collection_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IdMapping_collection_idx" ON public."IdMapping" USING btree (collection);


--
-- Name: IdMapping_newId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IdMapping_newId_idx" ON public."IdMapping" USING btree ("newId");


--
-- Name: InvoiceLine_agencyId_invoiceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "InvoiceLine_agencyId_invoiceId_idx" ON public."InvoiceLine" USING btree ("agencyId", "invoiceId");


--
-- Name: Invoice_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invoice_agencyId_branchId_idx" ON public."Invoice" USING btree ("agencyId", "branchId");


--
-- Name: Invoice_agencyId_customerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invoice_agencyId_customerId_idx" ON public."Invoice" USING btree ("agencyId", "customerId");


--
-- Name: Invoice_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invoice_agencyId_idx" ON public."Invoice" USING btree ("agencyId");


--
-- Name: Invoice_agencyId_invoiceRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Invoice_agencyId_invoiceRef_key" ON public."Invoice" USING btree ("agencyId", "invoiceRef");


--
-- Name: Invoice_agencyId_isDeleted_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invoice_agencyId_isDeleted_createdAt_idx" ON public."Invoice" USING btree ("agencyId", "isDeleted", "createdAt" DESC);


--
-- Name: Invoice_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Invoice_agencyId_isDeleted_idx" ON public."Invoice" USING btree ("agencyId", "isDeleted");


--
-- Name: JournalEntry_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JournalEntry_agencyId_branchId_idx" ON public."JournalEntry" USING btree ("agencyId", "branchId");


--
-- Name: JournalEntry_agencyId_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JournalEntry_agencyId_date_idx" ON public."JournalEntry" USING btree ("agencyId", date);


--
-- Name: JournalEntry_agencyId_entryNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "JournalEntry_agencyId_entryNumber_key" ON public."JournalEntry" USING btree ("agencyId", "entryNumber");


--
-- Name: JournalEntry_agencyId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JournalEntry_agencyId_status_idx" ON public."JournalEntry" USING btree ("agencyId", status);


--
-- Name: JournalEntry_reversingEntryId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "JournalEntry_reversingEntryId_key" ON public."JournalEntry" USING btree ("reversingEntryId");


--
-- Name: JournalLine_agencyId_accountId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JournalLine_agencyId_accountId_idx" ON public."JournalLine" USING btree ("agencyId", "accountId");


--
-- Name: JournalLine_agencyId_journalEntryId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "JournalLine_agencyId_journalEntryId_idx" ON public."JournalLine" USING btree ("agencyId", "journalEntryId");


--
-- Name: LeadActivity_agencyId_leadId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "LeadActivity_agencyId_leadId_idx" ON public."LeadActivity" USING btree ("agencyId", "leadId");


--
-- Name: LeadActivity_leadId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "LeadActivity_leadId_createdAt_idx" ON public."LeadActivity" USING btree ("leadId", "createdAt" DESC);


--
-- Name: Lead_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Lead_agencyId_branchId_idx" ON public."Lead" USING btree ("agencyId", "branchId");


--
-- Name: Lead_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Lead_agencyId_idx" ON public."Lead" USING btree ("agencyId");


--
-- Name: Lead_agencyId_isDeleted_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Lead_agencyId_isDeleted_createdAt_idx" ON public."Lead" USING btree ("agencyId", "isDeleted", "createdAt" DESC);


--
-- Name: Lead_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Lead_agencyId_isDeleted_idx" ON public."Lead" USING btree ("agencyId", "isDeleted");


--
-- Name: Lead_agencyId_leadRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Lead_agencyId_leadRef_key" ON public."Lead" USING btree ("agencyId", "leadRef");


--
-- Name: Lead_agencyId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Lead_agencyId_status_idx" ON public."Lead" USING btree ("agencyId", status);


--
-- Name: Notification_agencyId_recipientId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Notification_agencyId_recipientId_idx" ON public."Notification" USING btree ("agencyId", "recipientId");


--
-- Name: Notification_agencyId_recipientId_isRead_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Notification_agencyId_recipientId_isRead_idx" ON public."Notification" USING btree ("agencyId", "recipientId", "isRead");


--
-- Name: QuotationAttachment_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationAttachment_agencyId_isDeleted_idx" ON public."QuotationAttachment" USING btree ("agencyId", "isDeleted");


--
-- Name: QuotationAttachment_agencyId_quotationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationAttachment_agencyId_quotationId_idx" ON public."QuotationAttachment" USING btree ("agencyId", "quotationId");


--
-- Name: QuotationItem_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationItem_agencyId_isDeleted_idx" ON public."QuotationItem" USING btree ("agencyId", "isDeleted");


--
-- Name: QuotationItem_agencyId_quotationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationItem_agencyId_quotationId_idx" ON public."QuotationItem" USING btree ("agencyId", "quotationId");


--
-- Name: QuotationTax_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationTax_agencyId_isDeleted_idx" ON public."QuotationTax" USING btree ("agencyId", "isDeleted");


--
-- Name: QuotationTax_agencyId_quotationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationTax_agencyId_quotationId_idx" ON public."QuotationTax" USING btree ("agencyId", "quotationId");


--
-- Name: QuotationVersion_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationVersion_agencyId_isDeleted_idx" ON public."QuotationVersion" USING btree ("agencyId", "isDeleted");


--
-- Name: QuotationVersion_agencyId_quotationId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "QuotationVersion_agencyId_quotationId_idx" ON public."QuotationVersion" USING btree ("agencyId", "quotationId");


--
-- Name: QuotationVersion_agencyId_quotationId_version_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "QuotationVersion_agencyId_quotationId_version_key" ON public."QuotationVersion" USING btree ("agencyId", "quotationId", version);


--
-- Name: Quotation_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Quotation_agencyId_branchId_idx" ON public."Quotation" USING btree ("agencyId", "branchId");


--
-- Name: Quotation_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Quotation_agencyId_idx" ON public."Quotation" USING btree ("agencyId");


--
-- Name: Quotation_agencyId_isDeleted_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Quotation_agencyId_isDeleted_createdAt_idx" ON public."Quotation" USING btree ("agencyId", "isDeleted", "createdAt" DESC);


--
-- Name: Quotation_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Quotation_agencyId_isDeleted_idx" ON public."Quotation" USING btree ("agencyId", "isDeleted");


--
-- Name: Quotation_agencyId_quotationNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Quotation_agencyId_quotationNumber_key" ON public."Quotation" USING btree ("agencyId", "quotationNumber");


--
-- Name: Receipt_agencyId_bookingId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_bookingId_idx" ON public."Receipt" USING btree ("agencyId", "bookingId");


--
-- Name: Receipt_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_branchId_idx" ON public."Receipt" USING btree ("agencyId", "branchId");


--
-- Name: Receipt_agencyId_customerId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_customerId_idx" ON public."Receipt" USING btree ("agencyId", "customerId");


--
-- Name: Receipt_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_idx" ON public."Receipt" USING btree ("agencyId");


--
-- Name: Receipt_agencyId_isDeleted_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_isDeleted_createdAt_idx" ON public."Receipt" USING btree ("agencyId", "isDeleted", "createdAt" DESC);


--
-- Name: Receipt_agencyId_isDeleted_customerId_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_isDeleted_customerId_date_idx" ON public."Receipt" USING btree ("agencyId", "isDeleted", "customerId", date);


--
-- Name: Receipt_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Receipt_agencyId_isDeleted_idx" ON public."Receipt" USING btree ("agencyId", "isDeleted");


--
-- Name: RecentActivity_agencyId_branchId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RecentActivity_agencyId_branchId_createdAt_idx" ON public."RecentActivity" USING btree ("agencyId", "branchId", "createdAt");


--
-- Name: RecentActivity_agencyId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "RecentActivity_agencyId_createdAt_idx" ON public."RecentActivity" USING btree ("agencyId", "createdAt");


--
-- Name: Role_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Role_agencyId_isDeleted_idx" ON public."Role" USING btree ("agencyId", "isDeleted");


--
-- Name: Role_agencyId_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Role_agencyId_name_idx" ON public."Role" USING btree ("agencyId", name);


--
-- Name: SupplierPayment_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SupplierPayment_agencyId_isDeleted_idx" ON public."SupplierPayment" USING btree ("agencyId", "isDeleted");


--
-- Name: SupplierPayment_agencyId_paymentRef_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "SupplierPayment_agencyId_paymentRef_key" ON public."SupplierPayment" USING btree ("agencyId", "paymentRef");


--
-- Name: SupplierPayment_agencyId_supplierId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "SupplierPayment_agencyId_supplierId_idx" ON public."SupplierPayment" USING btree ("agencyId", "supplierId");


--
-- Name: Supplier_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Supplier_agencyId_idx" ON public."Supplier" USING btree ("agencyId");


--
-- Name: Supplier_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Supplier_agencyId_isDeleted_idx" ON public."Supplier" USING btree ("agencyId", "isDeleted");


--
-- Name: Template_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Template_agencyId_idx" ON public."Template" USING btree ("agencyId");


--
-- Name: Template_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Template_agencyId_isDeleted_idx" ON public."Template" USING btree ("agencyId", "isDeleted");


--
-- Name: TokenBlacklist_expiresAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TokenBlacklist_expiresAt_idx" ON public."TokenBlacklist" USING btree ("expiresAt");


--
-- Name: TokenBlacklist_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TokenBlacklist_token_key" ON public."TokenBlacklist" USING btree (token);


--
-- Name: User_agencyId_branchId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_agencyId_branchId_idx" ON public."User" USING btree ("agencyId", "branchId");


--
-- Name: User_agencyId_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_agencyId_email_key" ON public."User" USING btree ("agencyId", email);


--
-- Name: User_agencyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_agencyId_idx" ON public."User" USING btree ("agencyId");


--
-- Name: User_agencyId_isDeleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_agencyId_isDeleted_idx" ON public."User" USING btree ("agencyId", "isDeleted");


--
-- Name: User_agencyId_isDeleted_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "User_agencyId_isDeleted_role_idx" ON public."User" USING btree ("agencyId", "isDeleted", role);


--
-- Name: BookingActivity BookingActivity_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingActivity"
    ADD CONSTRAINT "BookingActivity_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingActivity BookingActivity_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingActivity"
    ADD CONSTRAINT "BookingActivity_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingDocument BookingDocument_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingDocument"
    ADD CONSTRAINT "BookingDocument_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BookingDocument BookingDocument_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."BookingDocument"
    ADD CONSTRAINT "BookingDocument_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Booking Booking_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Booking Booking_agentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Booking Booking_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Booking Booking_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Booking Booking_leadId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public."Lead"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Booking Booking_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Booking"
    ADD CONSTRAINT "Booking_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Branch Branch_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Branch"
    ADD CONSTRAINT "Branch_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChartOfAccount ChartOfAccount_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChartOfAccount"
    ADD CONSTRAINT "ChartOfAccount_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ChartOfAccount ChartOfAccount_parentAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ChartOfAccount"
    ADD CONSTRAINT "ChartOfAccount_parentAccountId_fkey" FOREIGN KEY ("parentAccountId") REFERENCES public."ChartOfAccount"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: CustomerDocument CustomerDocument_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerDocument"
    ADD CONSTRAINT "CustomerDocument_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerDocument CustomerDocument_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerDocument"
    ADD CONSTRAINT "CustomerDocument_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerNote CustomerNote_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerNote"
    ADD CONSTRAINT "CustomerNote_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CustomerNote CustomerNote_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomerNote"
    ADD CONSTRAINT "CustomerNote_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Customer Customer_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "Customer_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Expense Expense_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Expense Expense_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Expense Expense_recordedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Expense"
    ADD CONSTRAINT "Expense_recordedById_fkey" FOREIGN KEY ("recordedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FiscalPeriod FiscalPeriod_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."FiscalPeriod"
    ADD CONSTRAINT "FiscalPeriod_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InvoiceLine InvoiceLine_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoiceLine"
    ADD CONSTRAINT "InvoiceLine_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InvoiceLine InvoiceLine_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InvoiceLine"
    ADD CONSTRAINT "InvoiceLine_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Invoice Invoice_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Invoice Invoice_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Invoice Invoice_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Invoice Invoice_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: JournalEntry JournalEntry_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalEntry"
    ADD CONSTRAINT "JournalEntry_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: JournalEntry JournalEntry_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalEntry"
    ADD CONSTRAINT "JournalEntry_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: JournalEntry JournalEntry_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalEntry"
    ADD CONSTRAINT "JournalEntry_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: JournalLine JournalLine_accountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalLine"
    ADD CONSTRAINT "JournalLine_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES public."ChartOfAccount"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: JournalLine JournalLine_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalLine"
    ADD CONSTRAINT "JournalLine_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: JournalLine JournalLine_journalEntryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."JournalLine"
    ADD CONSTRAINT "JournalLine_journalEntryId_fkey" FOREIGN KEY ("journalEntryId") REFERENCES public."JournalEntry"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: LeadActivity LeadActivity_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LeadActivity"
    ADD CONSTRAINT "LeadActivity_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: LeadActivity LeadActivity_leadId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."LeadActivity"
    ADD CONSTRAINT "LeadActivity_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public."Lead"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Lead Lead_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lead"
    ADD CONSTRAINT "Lead_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Lead Lead_assignedAgentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lead"
    ADD CONSTRAINT "Lead_assignedAgentId_fkey" FOREIGN KEY ("assignedAgentId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Lead Lead_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Lead"
    ADD CONSTRAINT "Lead_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Notification Notification_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Notification Notification_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Notification Notification_recipientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_recipientId_fkey" FOREIGN KEY ("recipientId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationAttachment QuotationAttachment_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationAttachment"
    ADD CONSTRAINT "QuotationAttachment_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationAttachment QuotationAttachment_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationAttachment"
    ADD CONSTRAINT "QuotationAttachment_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationItem QuotationItem_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationItem"
    ADD CONSTRAINT "QuotationItem_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationItem QuotationItem_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationItem"
    ADD CONSTRAINT "QuotationItem_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationTax QuotationTax_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationTax"
    ADD CONSTRAINT "QuotationTax_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationTax QuotationTax_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationTax"
    ADD CONSTRAINT "QuotationTax_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationVersion QuotationVersion_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationVersion"
    ADD CONSTRAINT "QuotationVersion_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationVersion QuotationVersion_createdBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationVersion"
    ADD CONSTRAINT "QuotationVersion_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuotationVersion QuotationVersion_quotationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."QuotationVersion"
    ADD CONSTRAINT "QuotationVersion_quotationId_fkey" FOREIGN KEY ("quotationId") REFERENCES public."Quotation"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Quotation Quotation_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Quotation Quotation_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Quotation Quotation_consultantId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_consultantId_fkey" FOREIGN KEY ("consultantId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Quotation Quotation_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Quotation Quotation_leadId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public."Lead"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Quotation Quotation_termsTemplateId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Quotation"
    ADD CONSTRAINT "Quotation_termsTemplateId_fkey" FOREIGN KEY ("termsTemplateId") REFERENCES public."Template"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Receipt Receipt_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Receipt"
    ADD CONSTRAINT "Receipt_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Receipt Receipt_bookingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Receipt"
    ADD CONSTRAINT "Receipt_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES public."Booking"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Receipt Receipt_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Receipt"
    ADD CONSTRAINT "Receipt_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Receipt Receipt_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Receipt"
    ADD CONSTRAINT "Receipt_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."Customer"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RecentActivity RecentActivity_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RecentActivity"
    ADD CONSTRAINT "RecentActivity_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RecentActivity RecentActivity_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RecentActivity"
    ADD CONSTRAINT "RecentActivity_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: RecentActivity RecentActivity_createdByUserId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RecentActivity"
    ADD CONSTRAINT "RecentActivity_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Role Role_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SupplierPayment SupplierPayment_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SupplierPayment"
    ADD CONSTRAINT "SupplierPayment_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SupplierPayment SupplierPayment_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SupplierPayment"
    ADD CONSTRAINT "SupplierPayment_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPayment SupplierPayment_recordedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SupplierPayment"
    ADD CONSTRAINT "SupplierPayment_recordedById_fkey" FOREIGN KEY ("recordedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SupplierPayment SupplierPayment_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SupplierPayment"
    ADD CONSTRAINT "SupplierPayment_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public."Supplier"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Supplier Supplier_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Template Template_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Template"
    ADD CONSTRAINT "Template_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_agencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES public."Agency"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_branchId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_branchId_fkey" FOREIGN KEY ("branchId") REFERENCES public."Branch"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 8Lf5BDHAwBTgQ4ZErahU99mD9JL9gWBnBXFYs5hYB7iHKpPBHm0WSGTI5d6FSQt

