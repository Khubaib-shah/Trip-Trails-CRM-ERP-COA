import {
  LayoutDashboard,
  UserPlus,
  Users,
  Plane,
  FileText,
  Receipt,
  Building2,
  CreditCard,
  BarChart3,
  GitBranch,
  UserCog,
  ShieldCheck,
  Settings,
  FileMinus,
  BookOpen,
  ScrollText,
  LucideIcon,
} from "lucide-react";

export interface NavItem {
  title: string;
  href: string;
  icon: LucideIcon;
  badge?: string;
  roles?: string[];
  exact?: boolean;
}

export interface NavGroup {
  label: string;
  items: NavItem[];
}

export const sidebarNav: NavGroup[] = [
  {
    label: "MAIN MENU",
    items: [
      {
        title: "Dashboard",
        href: "/dashboard",
        icon: LayoutDashboard,
        roles: ["admin", "manager"],
      },
    ],
  },
  {
    label: "CRM",
    items: [
      {
        title: "Leads",
        href: "/leads",
        icon: UserPlus,
      },
      {
        title: "Customers",
        href: "/customers",
        icon: Users,
      },
      {
        title: "Quotations",
        href: "/quotations",
        icon: FileText,
        roles: ["admin", "manager"],
      },
    ],
  },
  {
    label: "SALES",
    items: [
      {
        title: "Bookings",
        href: "/bookings",
        icon: Plane,
      },
      {
        title: "Invoices",
        href: "/invoices",
        icon: FileText,
      },
      {
        title: "Credit Notes",
        href: "/credit-notes",
        icon: FileMinus,
      },
      {
        title: "Payments",
        href: "/receipts",
        icon: Receipt,
      },
    ],
  },
  {
    label: "OPERATIONS",
    items: [
      {
        title: "Suppliers",
        href: "/suppliers",
        icon: Building2,
      },
      {
        title: "Expenses",
        href: "/expenses",
        icon: CreditCard,
        roles: ["admin", "manager"],
      },
    ],
  },
  {
    label: "ACCOUNTING",
    items: [
      {
        title: "A/R Ledger",
        href: "/accounting/ar",
        icon: Users,
        roles: ["admin", "manager"],
      },
      {
        title: "A/P Ledger",
        href: "/accounting/ap",
        icon: Building2,
        roles: ["admin", "manager"],
      },
      {
        title: "Chart of Accounts",
        href: "/accounting",
        icon: BookOpen,
        roles: ["admin", "manager"],
        exact: true,
      },
      {
        title: "Journal Entries",
        href: "/accounting/journal-entries",
        icon: ScrollText,
        roles: ["admin", "manager"],
      },
    ],
  },
  {
    label: "ANALYTICS",
    items: [
      {
        title: "Reports",
        href: "/reports",
        icon: BarChart3,
        roles: ["admin", "manager"],
      },
    ],
  },
  {
    label: "ADMINISTRATION",
    items: [
      {
        title: "Branches",
        href: "/branches",
        icon: GitBranch,
        roles: ["admin", "manager"],
      },
      {
        title: "Users",
        href: "/users",
        icon: UserCog,
        roles: ["admin", "manager"],
      },
      {
        title: "Roles",
        href: "/roles",
        icon: ShieldCheck,
        roles: ["admin", "manager"],
      },
    ],
  },
  {
    label: "SETTINGS",
    items: [
      {
        title: "Settings",
        href: "/settings",
        icon: Settings,
        roles: ["admin", "manager"],
      },
    ],
  },

];
