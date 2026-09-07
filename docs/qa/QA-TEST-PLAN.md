# TravelFlow — QA Test Plan & Checklist

**Application:** TravelFlow ERP (Travel Agency Management System)  
**Version:** v2.0 (PostgreSQL Migration Complete)  
**Test Environment:** localhost:5000 (API) / localhost:3000 (Frontend)  
**Database:** PostgreSQL 17 via Docker (port 5433)  
**Seed Agency:** TripTrails Travel & Tourism  
**Date:** August 31, 2026

---

## Test Credentials

| Role | Email | Password | Branch | Expected Access |
|------|-------|----------|--------|-----------------|
| Admin | owner@triptrails.pk | Password123! | All | Full access to everything |
| Manager (Lahore) | sara@triptrails.pk | Password123! | Lahore HQ | All modules, own branch data |
| Manager (Karachi) | ahmed.razatr@triptrails.pk | Password123! | Karachi | All modules, own branch data |
| Manager (Dubai) | omar@triptrails.pk | Password123! | Dubai | All modules, own branch data |
| Agent | agent1@triptrails.pk | Password123! | Lahore HQ | Limited: bookings, customers, leads, quotations |
| Accountant | zainab@triptrails.pk | Password123! | Lahore HQ | Expenses, invoices, payments, reports |

---

## SECTION 1: AUTHENTICATION & SESSION

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 1.1 | Login with valid credentials | Enter owner@triptrails.pk / Password123!, click Login | Redirects to /dashboard, user name shown in sidebar | P0 | |
| 1.2 | Login with wrong password | Enter owner@triptrails.pk / wrongpass | Error toast "Invalid email or password" | P0 | |
| 1.3 | Login with non-existent email | Enter nobody@test.com / Password123! | Error toast "Invalid email or password" | P1 | |
| 1.4 | Login with inactive user | (If any inactive user exists) | Error toast "Account is inactive" | P1 | |
| 1.5 | Session persistence | Login, close browser tab, reopen | Session persists (cookies), redirected to dashboard | P0 | |
| 1.6 | Logout | Click user menu → Logout | Redirects to /login, cookies cleared | P0 | |
| 1.7 | Token refresh | Stay logged in for 15+ minutes, make an action | Token refreshes silently, action succeeds | P1 | |
| 1.8 | /auth/me endpoint | After login, check browser Network tab for /auth/me | Returns user object with agency, branch, permissions | P0 | |
| 1.9 | Protected route without auth | Open /dashboard in incognito (not logged in) | Redirects to /login | P0 | |
| 1.10 | RBAC: Agent cannot access admin pages | Login as agent1, try /users, /roles, /branches | Should show 403 or redirect (no permission) | P0 | |
| 1.11 | RBAC: Accountant cannot access bookings | Login as zainab, try /bookings | Should show 403 or limited access | P1 | |

---

## SECTION 2: DASHBOARD

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 2.1 | Dashboard loads | Login as admin, view /dashboard | Stats cards: Total Bookings, Revenue, Customers, Active Leads | P0 | |
| 2.2 | Dashboard stats accuracy | Compare stats with seed data | Booking count = 30, revenue matches sum of payments | P1 | |
| 2.3 | Dashboard date filter | Select date range filter | Stats update to reflect filtered period | P2 | |
| 2.4 | Recent activity feed | Check bottom of dashboard | Shows recent activities (payments, bookings, leads) | P2 | |
| 2.5 | Branch filter (admin) | Select different branch from dropdown | Dashboard shows only that branch's data | P1 | |
| 2.6 | Branch filter (non-admin) | Login as sara (manager), check dashboard | Only Lahore HQ data shown, no branch selector | P1 | |

---

## SECTION 3: LEADS (CRM)

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 3.1 | View leads list | Navigate to /leads | Table shows leads with ref, name, source, status, phone, assigned agent | P0 | |
| 3.2 | Create lead | Click "Add Lead", fill name, phone, source, save | Lead created with auto-generated LD-YYYY-NNN ref, appears in list | P0 | |
| 3.3 | Create lead — validation | Submit with empty name or phone | Zod validation errors shown | P1 | |
| 3.4 | View lead detail | Click a lead row | Shows lead info, activities timeline, conversion button | P0 | |
| 3.5 | Add lead activity | In lead detail, add a note/call/whatsapp activity | Activity appears in timeline, timestamp shown | P1 | |
| 3.6 | Update lead status | Change lead status to "contacted" | Status badge updates, activity logged | P1 | |
| 3.7 | Convert lead to booking | Click "Convert to Booking", fill booking details, submit | Lead status → "converted", booking created with BK-YYYY-NNN ref, customer created from lead | P0 | |
| 3.8 | Convert lead — duplicate customer | Convert a lead whose phone matches existing customer | Existing customer is reused, no duplicate created | P1 | |
| 3.9 | Delete lead | Delete a lead (admin/manager) | Lead removed from list (soft deleted) | P2 | |
| 3.10 | Lead search/filter | Use search or status filter on leads list | List filters correctly | P2 | |
| 3.11 | Pagination | Navigate through pages of leads | Pagination works, correct counts shown | P2 | |

---

## SECTION 4: CUSTOMERS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 4.1 | View customers list | Navigate to /customers | Table shows ref, name, type, phone, city, status, total bookings | P0 | |
| 4.2 | Create customer | Click "Add Customer", fill required fields, save | Customer created with CUS-YYYY-NNN ref | P0 | |
| 4.3 | Create corporate customer | Set type to "corporate", fill company name | Company name saved, displayed as corporate type | P1 | |
| 4.4 | View customer detail | Click a customer row | Shows profile, value metrics (total bookings, lifetime spend), tabs | P0 | |
| 4.5 | Customer booking history | Click "Booking History" tab | Lists all bookings for this customer | P0 | |
| 4.6 | Customer ledger tab | Click "Customer Ledger" tab | Shows ledger with bookings (debits) and payments (credits), running balance | P0 | |
| 4.7 | Customer documents tab | Click "Travel Documents" tab, upload a document | Document listed, can view/delete | P1 | |
| 4.8 | Customer notes tab | Click "Internal Notes" tab, add a note | Note appears in list, can delete | P1 | |
| 4.9 | Edit customer | Click "Edit Customer", modify fields, save | Changes persist, toast success | P1 | |
| 4.10 | Delete customer | Delete a customer (admin/manager) | Customer removed (soft deleted) | P2 | |
| 4.11 | Customer ledger accuracy | Compare ledger entries with seed data | Bookings = debits, payments = credits, balance correct | P1 | |
| 4.12 | Record payment from customer detail | In booking history, click "Record Payment" on a booking | Payment drawer opens, can record payment | P1 | |

---

## SECTION 5: QUOTATIONS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 5.1 | View quotations list | Navigate to /quotations | Table shows ref, customer, type, amount, status, date | P0 | |
| 5.2 | Create quotation | Click "Add Quotation", fill customer, items, save | Quotation created with QT-YYYY-NNN ref, status "draft" | P0 | |
| 5.3 | Add quotation items | Add multiple line items with prices | Items listed, subtotal calculated | P0 | |
| 5.4 | Add quotation taxes | Add tax lines | Tax amounts added to total | P1 | |
| 5.5 | View quotation detail | Click a quotation row | Shows all items, taxes, versions, actions | P0 | |
| 5.6 | Send quotation | Click "Send" action | Status changes to "sent", version created | P1 | |
| 5.7 | Edit quotation | Modify items/prices | New version created, changes tracked | P1 | |
| 5.8 | Quotation version history | Click "Versions" tab | Shows all versions with numbers and change descriptions | P2 | |
| 5.9 | Convert quotation to booking | Click "Convert to Booking" | Booking created with services from quotation items | P0 | |
| 5.10 | Print quotation | Click "Print" or view /print/quotation/:id | Printable quotation document renders correctly | P1 | |
| 5.11 | Delete quotation | Delete a draft quotation | Quotation removed | P2 | |

---

## SECTION 6: BOOKINGS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 6.1 | View bookings list | Navigate to /bookings | Table shows ref, title, customer, dates, amount, payment status, booking status | P0 | |
| 6.2 | Create booking | Click "Add Booking", fill customer, title, services, save | Booking created with BK-YYYY-NNN ref, status "confirmed" | P0 | |
| 6.3 | Add booking services | Add flight + hotel + transfer + insurance services | Services listed with cost/sell prices | P0 | |
| 6.4 | Booking total calculation | Check computed totals | totalCost = sum of costPrices, totalSell = sum of sellingPrices | P0 | |
| 6.5 | View booking detail | Click a booking row | Shows services, documents, activities, payment schedule, ledger | P0 | |
| 6.6 | Booking activity timeline | Check "Activity Log" tab | Shows created, payment, document activities | P1 | |
| 6.7 | Booking documents | Upload a document to booking | Document listed, can view/delete | P1 | |
| 6.8 | Update booking | Edit booking details | Changes persist, activity logged | P1 | |
| 6.9 | Delete booking | Delete a booking | Booking removed (soft deleted) | P2 | |
| 6.10 | Payment status auto-update | Record full payment for a booking | booking.paymentStatus changes to "paid" | P0 | |
| 6.11 | Partial payment status | Record partial payment | booking.paymentStatus changes to "partial" | P1 | |
| 6.12 | Create payment schedule | In booking detail, create a payment schedule with 3 installments | Schedule created with 3 items, status "active" | P1 | |
| 6.13 | Mark schedule item as paid | Click "Mark Paid" on a schedule item | Item status → "paid", paidAt set | P1 | |
| 6.14 | Schedule auto-completion | Mark all schedule items as paid | Schedule status → "completed" | P1 | |
| 6.15 | Delete payment schedule | Delete an active schedule | Schedule soft deleted | P2 | |

---

## SECTION 7: INVOICES

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 7.1 | View invoices list | Navigate to /invoices | Table shows ref, customer, date, total, status | P0 | |
| 7.2 | Generate invoice from booking | In booking detail, click "Generate Invoice" | Invoice created with INV-YYYY-NNN ref, lines from services | P0 | |
| 7.3 | Invoice line items | View invoice detail | Lines match booking services, amounts correct | P0 | |
| 7.4 | Invoice tax calculation | Check invoice with tax | Tax amount correct (0%/5%/10%/15% from seed) | P1 | |
| 7.5 | Update invoice | Edit invoice notes/terms | Changes persist | P1 | |
| 7.6 | Mark invoice as paid | Click "Mark Paid" | Status → "paid", paidAt set | P0 | |
| 7.7 | Update invoice status | Change status via dropdown | Status updates correctly | P1 | |
| 7.8 | Delete invoice | Delete an invoice with no credit notes | Invoice removed | P2 | |
| 7.9 | Delete invoice with credit note guard | Try to delete invoice that has issued credit notes | Error: cannot delete invoice with active credit notes | P1 | |
| 7.10 | Print invoice | View /print/invoice/:id | Printable invoice document renders correctly | P1 | |

---

## SECTION 8: CUSTOMER PAYMENTS (Receipts)

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 8.1 | View payments list | Navigate to /receipts | Table shows payment ref, customer, date, amount, method, status | P0 | |
| 8.2 | Record payment | Click "Record Payment", select booking, enter amount, method | Payment created with CPY-YYYY-NNN ref | P0 | |
| 8.3 | Payment allocation | Check that payment is allocated to booking | PaymentAllocation record created, booking paymentStatus updated | P0 | |
| 8.4 | View payment detail | Click a payment row | Shows full receipt: ref, customer, amount, method, date, allocations | P0 | |
| 8.5 | Auto-posting: customer payment | Record a payment, check accounting/journal-entries | Journal entry created: DR Cash & Bank / CR Accounts Receivable | P0 | |
| 8.6 | Payment status update | After full payment, check booking | booking.paymentStatus = "paid" | P0 | |
| 8.7 | Multiple payments | Record 2 partial payments for same booking | booking.paymentStatus = "partial" until fully paid | P1 | |
| 8.8 | Payment notification | Record payment for a booking with assigned agent | Agent receives notification | P2 | |
| 8.9 | Print receipt | View /print/receipt/:id | Printable receipt document renders | P1 | |

---

## SECTION 9: SUPPLIERS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 9.1 | View suppliers list | Navigate to /suppliers | Table shows name, category, contact, balance, status | P0 | |
| 9.2 | Create supplier | Click "Add Supplier", fill fields, save | Supplier created with SUP-YYYY-NNN ref | P0 | |
| 9.3 | View supplier detail | Click a supplier row | Shows business info, financial standing, tabs | P0 | |
| 9.4 | Supplier ledger tab | Click "Supplier Ledger" tab | Shows services (what we owe) and payments (what we paid), running balance | P0 | |
| 9.5 | Supplier related bookings | Click "Related Bookings" tab | Lists bookings where this supplier has services | P1 | |
| 9.6 | Record supplier payment | Click "Settle Balance", enter amount, method | Payment created with SPY-YYYY-NNN ref, supplier.balance updated | P0 | |
| 9.7 | Auto-posting: supplier payment | Record supplier payment, check journal entries | Journal entry: DR Accounts Payable / CR Cash & Bank | P0 | |
| 9.8 | Supplier statement accuracy | Compare statement with seed data | Services show credits (owed), payments show debits (paid) | P1 | |
| 9.9 | Print supplier statement | View /print/supplier-statement/:id | Printable statement renders | P1 | |
| 9.10 | Edit supplier | Modify supplier details | Changes persist | P2 | |
| 9.11 | Delete supplier | Delete a supplier | Supplier removed (soft deleted) | P2 | |

---

## SECTION 10: EXPENSES

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 10.1 | View expenses list | Navigate to /expenses | Table shows date, category, description, amount, supplier, status | P0 | |
| 10.2 | Create expense | Click "Add Expense", fill category, amount, description, save | Expense created with EXP-YYYY-NNN ref | P0 | |
| 10.3 | Expense categories | Create expenses in different categories | Each category maps to correct account (office_rent→5200, utilities→5300, etc.) | P1 | |
| 10.4 | Auto-posting: expense | Create expense, check journal entries | Journal entry: DR Expense Account / CR Cash & Bank | P0 | |
| 10.5 | View expense detail | Click an expense row | Shows full expense details | P1 | |
| 10.6 | Edit expense | Modify expense details | Changes persist | P2 | |
| 10.7 | Delete expense | Delete an expense | Expense removed (soft deleted) | P2 | |
| 10.8 | Expense date filter | Filter expenses by date range | List shows only expenses in range | P2 | |

---

## SECTION 11: CREDIT NOTES

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 11.1 | View credit notes list | Navigate to /credit-notes | Table shows ref, invoice, customer, amount, reason, status | P0 | |
| 11.2 | Issue credit note | In invoice list, click "Issue Credit Note" on an invoice | Credit note created with CN-YYYY-NNN ref, status "issued" | P0 | |
| 11.3 | Credit note validation | Try to create credit note exceeding invoice total | Error: credit note amount exceeds remaining invoice balance | P1 | |
| 11.4 | Apply credit note | Click "Apply" on an issued credit note | Status → "applied", appliedAt set | P0 | |
| 11.5 | Auto-posting: credit note | Issue credit note, check journal entries | Journal entry: DR Sales Returns (4400) / CR Accounts Receivable (1100) | P0 | |
| 11.6 | Invoice deletion guard | Try to delete invoice that has issued credit notes | Error: cannot delete invoice with active credit notes | P1 | |
| 11.7 | Credit note reason | Enter a reason when issuing | Reason saved and displayed | P2 | |

---

## SECTION 12: ACCOUNTING — CHART OF ACCOUNTS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 12.1 | View chart of accounts | Navigate to /accounting | Table shows code, name, type, normal balance, status | P0 | |
| 12.2 | Account count | Check total accounts | 19 seeded accounts visible | P1 | |
| 12.3 | Create account | Click "Add Account", fill code, name, type, normal balance | Account created | P1 | |
| 12.4 | Duplicate account code | Try to create account with existing code | Error: account code already in use | P1 | |
| 12.5 | Account types | Verify all 5 types present | ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE all represented | P2 | |

---

## SECTION 13: ACCOUNTING — JOURNAL ENTRIES

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 13.1 | View journal entries | Navigate to /accounting/journal-entries | Table shows entry #, date, description, status, created by | P0 | |
| 13.2 | Journal entry count | Check total entries | 10 seeded entries (9 POSTED + 1 DRAFT) | P1 | |
| 13.3 | Filter by status | Filter to POSTED only | Only POSTED entries shown | P1 | |
| 13.4 | Create manual journal entry | Click "Create Entry", add balanced debit/credit lines, submit | Entry created as DRAFT status | P0 | |
| 13.5 | Unbalanced entry validation | Create entry where debits ≠ credits | Error: "Journal entry lines do not balance" | P0 | |
| 13.6 | Reverse journal entry | Click "Reverse" on a POSTED entry | New reversing entry created (JE-YYYY-NNN), original status → "REVERSED" | P0 | |
| 13.7 | Cannot reverse DRAFT | Try to reverse a DRAFT entry | Button not shown or error | P1 | |
| 13.8 | Cannot reverse REVERSED | Try to reverse an already reversed entry | Button not shown or error | P1 | |
| 13.9 | Entry number uniqueness | Create multiple entries, check ref numbers | All refs unique (JE-YYYY-NNN format) | P1 | |

---

## SECTION 14: ACCOUNTING — TRIAL BALANCE

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 14.1 | View trial balance | Navigate to /accounting/trial-balance | Table shows code, account name, debit/credit columns | P0 | |
| 14.2 | Balance check | Compare total debits vs total credits | Total debits = Total credits, "Balanced" badge shown | P0 | |
| 14.3 | Account balances | Check individual account balances | Match the sum of journal lines per account | P1 | |
| 14.4 | After new journal entry | Create a new entry, refresh trial balance | Balances update to reflect new entry | P1 | |

---

## SECTION 15: PAYMENT SCHEDULES

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 15.1 | Create payment schedule | In booking detail, create schedule with 3 installments | Schedule created, 3 items shown | P0 | |
| 15.2 | Schedule validation | Create schedule where item amounts ≠ total | Error: items must sum to total | P1 | |
| 15.3 | Mark item as paid | Click "Mark Paid" on first installment | Item status → "paid", paidAt set | P0 | |
| 15.4 | Schedule auto-completion | Mark all items as paid | Schedule status → "completed" | P0 | |
| 15.5 | Delete schedule | Delete an active schedule | Schedule soft deleted | P2 | |
| 15.6 | Link payment to schedule item | When marking paid, link to a customerPayment | customerPaymentId set on item | P2 | |

---

## SECTION 16: ROLES & PERMISSIONS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 16.1 | View roles | Navigate to /roles | Shows 4 roles: admin, manager, agent, accountant | P0 | |
| 16.2 | View role permissions | Click on a role | Permission grid shown with toggles | P0 | |
| 16.3 | Update permissions | Toggle permissions, save | Permissions updated, toast success | P1 | |
| 16.4 | Create new role | Click "Add Role", fill name, permissions | Role created | P2 | |
| 16.5 | Delete role | Delete a custom role | Role removed | P2 | |
| 16.6 | Agent has limited access | Login as agent, check sidebar and pages | Cannot see Users, Roles, Branches, Settings | P0 | |
| 16.7 | Accountant has finance access | Login as accountant | Can see Expenses, Invoices, Payments, Reports | P1 | |

---

## SECTION 17: USERS & BRANCHES

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 17.1 | View users list | Navigate to /users | Table shows name, email, role, branch, status | P0 | |
| 17.2 | Create user | Click "Add User", fill fields, assign role/branch | User created, temp password returned | P1 | |
| 17.3 | Edit user | Modify user details | Changes persist | P1 | |
| 17.4 | Delete user | Delete a user (not yourself) | User removed | P2 | |
| 17.5 | View branches | Navigate to /branches | Shows 5 branches: Lahore, Karachi, Islamabad, Peshawar, Dubai | P0 | |
| 17.6 | Create branch | Click "Add Branch", fill fields | Branch created | P2 | |
| 17.7 | Edit branch | Modify branch details | Changes persist | P2 | |

---

## SECTION 18: NOTIFICATIONS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 18.1 | Notification dropdown | Click bell icon in topbar | Dropdown shows recent notifications | P1 | |
| 18.2 | Unread count | Check badge on bell icon | Shows unread notification count | P2 | |
| 18.3 | Mark as read | Click a notification | Notification marked as read, count decreases | P1 | |
| 18.4 | Mark all as read | Click "Mark all as read" | All notifications marked as read | P2 | |
| 18.5 | Delete notification | Delete a notification | Notification removed | P2 | |

---

## SECTION 19: SETTINGS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 19.1 | View settings | Navigate to /settings | Settings page loads with tabs | P1 | |
| 19.2 | Update company settings | Modify company name, contact info, save | Settings persisted | P1 | |
| 19.3 | Templates management | Go to Settings → Templates tab | List of templates shown (7 seeded) | P1 | |
| 19.4 | Create template | Add a new template | Template created | P2 | |
| 19.5 | Update template | Edit template content | Changes persist | P2 | |
| 19.6 | Delete template | Delete a template | Template removed | P2 | |

---

## SECTION 20: REPORTS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 20.1 | View reports | Navigate to /reports | Analytics page loads with charts | P1 | |
| 20.2 | Revenue chart | Check revenue chart | Shows revenue data from payments | P2 | |
| 20.3 | Branch performance | Check branch performance section | Shows data per branch | P2 | |
| 20.4 | Date range filter | Filter reports by date range | Charts update | P2 | |

---

## SECTION 21: PRINT DOCUMENTS

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 21.1 | Print quotation | Navigate to /print/quotation/:id | Printable quotation renders with items, taxes, totals | P1 | |
| 21.2 | Print invoice | Navigate to /print/invoice/:id | Printable invoice renders with lines, tax, total | P1 | |
| 21.3 | Print receipt | Navigate to /print/receipt/:id | Printable receipt renders with payment details | P1 | |
| 21.4 | Print customer ledger | Navigate to /print/ledger/:id | Printable ledger with entries and running balance | P1 | |
| 21.5 | Print supplier statement | Navigate to /print/supplier-statement/:id | Printable statement with services and payments | P1 | |

---

## SECTION 22: END-TO-END DATA FLOW TESTS

These tests verify the complete lifecycle of business processes.

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| **E2E-1** | **Lead → Booking → Invoice → Payment** | 1. Create lead (LD-xxx) | Lead created | P0 | |
| | | 2. Convert lead to booking | Booking created (BK-xxx), customer created (CUS-xxx) | | |
| | | 3. Add services to booking | Services added with cost/sell prices | | |
| | | 4. Generate invoice from booking | Invoice created (INV-xxx) with line items | | |
| | | 5. Record customer payment | Payment created (CPY-xxx), allocated to booking | | |
| | | 6. Check booking payment status | paymentStatus = "paid" (if full amount) | | |
| | | 7. Check journal entries | Auto-posted: DR Cash & Bank / CR Accounts Receivable | | |
| | | 8. Check customer ledger | Booking = debit, Payment = credit, balance = 0 | | |
| | | 9. Check trial balance | Still balanced after all entries | | |
| **E2E-2** | **Quotation → Booking → Multi-Payment** | 1. Create quotation with 3 items | QT-xxx created, draft status | P0 | |
| | | 2. Send quotation | Status → "sent" | | |
| | | 3. Convert to booking | Booking created with services from quotation | | |
| | | 4. Create payment schedule (3 installments) | Schedule created, 3 items pending | | |
| | | 5. Pay first installment | Item 1 → "paid", schedule still "active" | | |
| | | 6. Pay second installment | Item 2 → "paid", schedule still "active" | | |
| | | 7. Pay third installment | Item 3 → "paid", schedule → "completed" | | |
| | | 8. Check booking payment status | paymentStatus = "paid" | | |
| **E2E-3** | **Supplier Payment → Accounting** | 1. Select supplier with balance | Supplier has balance > 0 | P0 | |
| | | 2. Record supplier payment | Payment created (SPY-xxx), supplier.balance reduced | | |
| | | 3. Check journal entry | DR Accounts Payable / CR Cash & Bank | | |
| | | 4. Check supplier statement | Payment appears as debit entry | | |
| | | 5. Check trial balance | Still balanced | | |
| **E2E-4** | **Expense → Accounting** | 1. Create expense (office_rent) | EXP-xxx created | P0 | |
| | | 2. Check journal entry | DR Office Rent (5200) / CR Cash & Bank (1000) | | |
| | | 3. Create expense (utilities) | EXP-xxx created | | |
| | | 4. Check journal entry | DR Staff Salaries (5300) / CR Cash & Bank (1000) | | |
| | | 5. Check trial balance | Still balanced | | |
| **E2E-5** | **Credit Note → Accounting** | 1. Generate invoice from booking | INV-xxx created | P0 | |
| | | 2. Issue credit note for partial amount | CN-xxx created, status "issued" | | |
| | | 3. Check journal entry | DR Sales Returns (4400) / CR Accounts Receivable (1100) | | |
| | | 4. Apply credit note | CN-xxx status → "applied" | | |
| | | 5. Try to delete invoice | Error: cannot delete with active credit notes | | |
| **E2E-6** | **Multi-Tenant Isolation** | 1. Login as admin (TripTrails) | Sees all TripTrails data | P0 | |
| | | 2. Check customer count | 40 customers (TripTrails only) | | |
| | | 3. Check booking count | 30 bookings (TripTrails only) | | |
| | | 4. Branch filter: Lahore only | Only Lahore bookings shown | | |
| | | 5. Branch filter: Karachi only | Only Karachi bookings shown | | |
| **E2E-7** | **RBAC Enforcement** | 1. Login as agent (agent1@triptrails.pk) | Limited sidebar | P0 | |
| | | 2. Try accessing /users via URL | 403 Forbidden or redirect | | |
| | | 3. Try accessing /roles via URL | 403 Forbidden or redirect | | |
| | | 4. Can access /bookings | Allowed | | |
| | | 5. Can access /customers | Allowed | | |
| | | 6. Can create a lead | Allowed (Leads: Create permission) | | |
| | | 7. Cannot delete a lead | No delete permission | | |

---

## SECTION 23: EDGE CASES & ERROR HANDLING

| # | Test Case | Steps | Expected Result | Priority | Status |
|---|-----------|-------|-----------------|----------|--------|
| 23.1 | Concurrent token refresh | Open 2 tabs, both idle 15+ min, make action in both | Only one refresh fires (singleton lock), both succeed | P2 | |
| 23.2 | Network timeout | Disconnect network, try to load data | 20-second timeout, error toast shown | P2 | |
| 23.3 | Invalid UUID param | Navigate to /bookings/invalid-id | 400 error or "not found" | P1 | |
| 23.4 | Non-existent resource | Navigate to /bookings/00000000-0000-0000-0000-000000000000 | "Not found" message | P1 | |
| 23.5 | Double-submit prevention | Click "Save" button twice rapidly | Only one request fires, button shows loading state | P1 | |
| 23.6 | Empty form submission | Submit any form with all fields empty | Validation errors shown, no API call | P1 | |
| 23.7 | XSS in input fields | Enter `<script>alert(1)</script>` in name field | Input saved as plain text, no script execution | P1 | |
| 23.8 | Large file upload | Upload a 50MB file as booking document | Appropriate error or success depending on limits | P2 | |
| 23.9 | Soft-deleted record access | Delete a customer, try to access /customers/:id | Returns null or "not found" | P1 | |
| 23.10 | Cross-tenant data leak | Query with agencyId of another tenant | Returns empty (RLS + app-level filter) | P0 | |

---

## SECTION 24: SEED DATA VERIFICATION

After running `npx prisma db seed`, verify:

| # | Entity | Expected Count | Query to Verify |
|---|--------|---------------|-----------------|
| S1 | Agency | 1 | `SELECT COUNT(*) FROM "Agency"` |
| S2 | Branch | 5 | `SELECT COUNT(*) FROM "Branch"` |
| S3 | Role | 4 | `SELECT COUNT(*) FROM "Role"` |
| S4 | User | 11 | `SELECT COUNT(*) FROM "User"` |
| S5 | Customer | 40 | `SELECT COUNT(*) FROM "Customer"` |
| S6 | Supplier | 15 | `SELECT COUNT(*) FROM "Supplier"` |
| S7 | Lead | 31+ | `SELECT COUNT(*) FROM "Lead"` |
| S8 | Booking | 30 | `SELECT COUNT(*) FROM "Booking"` |
| S9 | BookingService | 60+ | `SELECT COUNT(*) FROM "BookingService"` |
| S10 | Expense | 120+ | `SELECT COUNT(*) FROM "Expense"` |
| S11 | CustomerPayment | 25 | `SELECT COUNT(*) FROM "CustomerPayment"` |
| S12 | PaymentAllocation | 25 | `SELECT COUNT(*) FROM "PaymentAllocation"` |
| S13 | SupplierPayment | 10 | `SELECT COUNT(*) FROM "SupplierPayment"` |
| S14 | Invoice | 20 | `SELECT COUNT(*) FROM "Invoice"` |
| S15 | InvoiceLine | 20+ | `SELECT COUNT(*) FROM "InvoiceLine"` |
| S16 | Quotation | 21 | `SELECT COUNT(*) FROM "Quotation"` |
| S17 | ChartOfAccount | 19 | `SELECT COUNT(*) FROM "ChartOfAccount"` |
| S18 | JournalEntry | 10 | `SELECT COUNT(*) FROM "JournalEntry"` |
| S19 | JournalLine | 20+ | `SELECT COUNT(*) FROM "JournalLine"` |
| S20 | FiscalPeriod | 2 | `SELECT COUNT(*) FROM "FiscalPeriod"` |

---

## SECTION 25: API ENDPOINT SMOKE TESTS

Quick check that every endpoint group returns 200:

| # | Endpoint | Method | Expected |
|---|----------|--------|----------|
| A1 | /api/v1/health | GET | 200 |
| A2 | /api/v1/auth/login | POST | 200 (with credentials) |
| A3 | /api/v1/auth/me | GET | 200 (with cookie) |
| A4 | /api/v1/dashboard/stats | GET | 200 |
| A5 | /api/v1/leads | GET | 200 |
| A6 | /api/v1/customers | GET | 200 |
| A7 | /api/v1/bookings | GET | 200 |
| A8 | /api/v1/suppliers | GET | 200 |
| A9 | /api/v1/expenses | GET | 200 |
| A10 | /api/v1/quotations | GET | 200 |
| A11 | /api/v1/invoices | GET | 200 |
| A12 | /api/v1/payments | GET | 200 |
| A13 | /api/v1/creditnotes | GET | 200 |
| A14 | /api/v1/payment-schedules | GET | 200 |
| A15 | /api/v1/accounting/accounts | GET | 200 |
| A16 | /api/v1/accounting/journal-entries | GET | 200 |
| A17 | /api/v1/accounting/trial-balance | GET | 200 |
| A18 | /api/v1/branches | GET | 200 |
| A19 | /api/v1/users | GET | 200 |
| A20 | /api/v1/roles | GET | 200 |
| A21 | /api/v1/templates | GET | 200 |
| A22 | /api/v1/notifications | GET | 200 |
| A23 | /api/v1/settings | GET | 200 |

---

## TEST EXECUTION SUMMARY

| Section | Total Tests | P0 | P1 | P2 | Passed | Failed | Blocked |
|---------|-------------|-----|-----|-----|--------|--------|---------|
| 1. Authentication | 11 | 6 | 4 | 1 | | | |
| 2. Dashboard | 6 | 1 | 4 | 1 | | | |
| 3. Leads | 11 | 4 | 4 | 3 | | | |
| 4. Customers | 12 | 4 | 6 | 2 | | | |
| 5. Quotations | 11 | 3 | 4 | 4 | | | |
| 6. Bookings | 15 | 5 | 6 | 4 | | | |
| 7. Invoices | 10 | 3 | 5 | 2 | | | |
| 8. Payments | 9 | 4 | 3 | 2 | | | |
| 9. Suppliers | 11 | 4 | 3 | 4 | | | |
| 10. Expenses | 8 | 2 | 2 | 4 | | | |
| 11. Credit Notes | 7 | 3 | 2 | 2 | | | |
| 12. Chart of Accounts | 5 | 1 | 2 | 2 | | | |
| 13. Journal Entries | 9 | 4 | 3 | 2 | | | |
| 14. Trial Balance | 4 | 2 | 2 | 0 | | | |
| 15. Payment Schedules | 6 | 3 | 1 | 2 | | | |
| 16. Roles & Permissions | 7 | 2 | 2 | 3 | | | |
| 17. Users & Branches | 7 | 2 | 3 | 2 | | | |
| 18. Notifications | 5 | 0 | 2 | 3 | | | |
| 19. Settings | 6 | 0 | 3 | 3 | | | |
| 20. Reports | 4 | 0 | 1 | 3 | | | |
| 21. Print Documents | 5 | 0 | 5 | 0 | | | |
| 22. E2E Flows | 7 | 7 | 0 | 0 | | | |
| 23. Edge Cases | 10 | 2 | 5 | 3 | | | |
| 24. Seed Verification | 20 | 0 | 0 | 0 | | | |
| 25. API Smoke | 23 | 23 | 0 | 0 | | | |
| **TOTAL** | **244** | **82** | **72** | **54** | | | |

---

## HOW TO USE THIS DOCUMENT

1. **Start with Section 25** (API Smoke Tests) — run via Node.js script to verify backend is up
2. **Then Section 24** (Seed Data) — run SQL queries to verify database state
3. **Then Section 1** (Authentication) — login with each role
4. **Then Section 22** (E2E Flows) — these are the most critical business processes
5. **Then Sections 3-21** — module-by-module testing
6. **Finally Section 23** (Edge Cases) — defensive testing

Mark each row's **Status** column as:
- ✅ PASS — test passed
- ❌ FAIL — test failed (note the issue)
- ⏭️ SKIP — not applicable or blocked
- 🔄 RETEST — after fix, retest needed
