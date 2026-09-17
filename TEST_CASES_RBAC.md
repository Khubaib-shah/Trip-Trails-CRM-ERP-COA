# RBAC & Permissions Verification Test Cases

This document outlines the step-by-step test cases to verify Role-Based Access Control (RBAC), dynamic permission enforcement, route protection, and clear toast notifications across TravelFlow.

---

## Pre-requisites & Test Accounts

1. **Backend Server**: Running at `http://localhost:5000`
2. **Frontend Server**: Running at `http://localhost:3000`
3. **Accounts Needed**:
   - **Admin Account**: `owner@triptrails.pk` / `Password123!` (or your system Admin credentials)
   - **Manager Account**: Any active user assigned the `Manager` role (e.g. `manager@triptrails.pk`)

---

## Test Suite 1: Configuring & Saving Role Permissions (Admin)

### Test Case 1.1: Revoke Permissions for Manager Role
- **Goal**: Confirm that unchecking permissions for a role saves cleanly and invalidates backend caches immediately.
- **Steps**:
  1. Log in as an **Admin** user.
  2. Navigate to **Administration** → **Roles** (`/roles`).
  3. Locate the **Manager** role row.
  4. Click **Permissions** to open the *Edit Permissions — Manager* drawer modal.
  5. Expand **Branches** and uncheck all actions (0 / 5).
  6. Expand **Settings** and uncheck all actions (0 / 2).
  7. Keep other modules checked (e.g. Customers, Leads, Bookings, Quotations, Invoices, Expenses, Suppliers, Users, Accounting).
  8. Click **Save Permissions**.
- **Expected Results**:
  - Toast displays: `"Permissions updated"`.
  - The modal closes.
  - The database records the updated permissions list.
  - Backend in-memory `rolePermissionsCache` is immediately cleared for the agency.

---

## Test Suite 2: Navigation & Quick Search Visibility (Manager)

### Test Case 2.1: Verify Sidebar Navigation Hides Unpermitted Modules
- **Goal**: Ensure the sidebar dynamically checks module permissions and removes inaccessible items.
- **Steps**:
  1. Log out from Admin and log in as the **Manager** user.
  2. Inspect the left-hand sidebar navigation.
- **Expected Results**:
  - Under **ADMINISTRATION**:
    - **Branches** must **NOT** be visible in the sidebar.
    - **Users** and **Roles** remain visible (if permitted).
  - Under **SETTINGS**:
    - **Settings** must **NOT** be visible in the sidebar.
  - Permitted modules (CRM: Leads, Customers, Quotations; Sales: Bookings, Invoices; Operations: Suppliers, Expenses; Accounting: Chart of Accounts, Journal Entries) remain fully accessible and visible.

### Test Case 2.2: Verify Command Palette / Quick Search (`Ctrl+K`)
- **Goal**: Ensure search doesn't leak unpermitted routes or quick actions.
- **Steps**:
  1. As the **Manager**, press `Ctrl + K` (or `Cmd + K` on Mac) to open the Quick Search dialog.
  2. Type `"Branches"` into the search box.
  3. Type `"Settings"` into the search box.
- **Expected Results**:
  - No navigation links to `/branches` or `/settings` appear in the results list.

---

## Test Suite 3: Direct URL Route Protection (Manager)

### Test Case 3.1: Direct URL Navigation to `/branches`
- **Goal**: Prevent bypass via manual URL typing.
- **Steps**:
  1. While logged in as **Manager**, type `http://localhost:3000/branches` directly into your browser address bar and press Enter.
- **Expected Results**:
  - The branches page does **NOT** render.
  - An **Access Denied** message is displayed:
    - Shield icon.
    - Headline: `"Access Denied"`.
    - Message: `"You do not have permission to access this page. If you require access, please contact your agency administrator."`
    - Button: `"Return to Accessible Page"`.
  - No sensitive branch locations, contact numbers, or agency branch data are exposed.

### Test Case 3.2: Direct URL Navigation to `/settings`
- **Goal**: Prevent access to agency settings via URL.
- **Steps**:
  1. While logged in as **Manager**, navigate directly to `http://localhost:3000/settings`.
- **Expected Results**:
  - An **Access Denied** card is displayed.
  - The agency's settings form, branding tabs, and credentials are protected.

---

## Test Suite 4: Action Button Visibility & Page Level Permissions

### Test Case 4.1: Granular Actions on Branches (When View is Allowed, Create/Edit is Revoked)
- **Goal**: Verify button-level permission guards.
- **Steps**:
  1. Log in as Admin.
  2. In `/roles`, edit Manager permissions:
     - Check **Branches: View** (1/5).
     - Leave **Branches: Create**, **Branches: Edit**, **Branches: Delete** unchecked.
  3. Click **Save Permissions**.
  4. Log in as Manager and navigate to `/branches`.
- **Expected Results**:
  - The branches list loads and is viewable.
  - The **"Add Branch"** button in the top right is **hidden**.
  - The **"Edit"** button on individual branch cards is **hidden**.
  - Manager can view branch information without any ability to modify it.

### Test Case 4.2: Settings Edit Permission Guard
- **Goal**: Verify settings cannot be modified when `Settings: Edit` is missing.
- **Steps**:
  1. As Admin, edit Manager permissions: check **Settings: View** (1/2), leave **Settings: Edit** unchecked. Save.
  2. As Manager, navigate to `/settings`.
- **Expected Results**:
  - Settings page opens in view mode.
  - The **"Save Changes"** button is **hidden**.
  - Attempting to submit changes from console or network returns HTTP 403 Forbidden.

---

## Test Suite 5: Error Handling & Toast Messages

### Test Case 5.1: Verify Clear 403 Toast Messages (No "Something went wrong")
- **Goal**: Ensure the user receives a clean, readable message when an action is forbidden.
- **Steps**:
  1. As Manager (without `Settings: Edit` permission), attempt to trigger a settings update (or directly via API PATCH `/api/v1/settings`).
- **Expected Results**:
  - The network request returns HTTP `403 Forbidden` with:
    ```json
    {
      "success": false,
      "message": "You do not have permission to perform this action. Required: Settings: Edit",
      "code": "FORBIDDEN"
    }
    ```
  - The toast popup displays:
    - **Title**: `Access Denied`
    - **Description**: `You do not have permission to perform this action. Required: Settings: Edit`
  - **CRITICAL**: The toast MUST NOT show `"Something went wrong. An unexpected error occurred. Please try again."`.

---

## Test Suite 6: Restoring Permissions (Admin)

### Test Case 6.1: Re-grant Permissions to Manager
- **Goal**: Ensure permissions can be re-enabled smoothly.
- **Steps**:
  1. Log in as Admin.
  2. In `/roles`, re-check all permissions for Manager under **Branches** (5/5) and **Settings** (2/2).
  3. Click **Save Permissions**.
  4. Switch back to Manager account and refresh the browser.
- **Expected Results**:
  - "Branches" and "Settings" reappear in the sidebar navigation immediately.
  - Full access to `/branches` and `/settings` is restored with action buttons available.
