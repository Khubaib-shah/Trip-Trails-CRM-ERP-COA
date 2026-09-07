"use client";

import { useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { Sidebar } from "@/components/layout/Sidebar";
import { Topbar } from "@/components/layout/Topbar";
import { useSidebarStore } from "@/store/sidebar.store";
import { useAuthStore } from "@/store/auth.store";
import { ErrorBoundary } from "@/components/shared/ErrorBoundary";
import { Button } from "@/components/ui/button";
import { WifiOff, Users, Target, FileText, Calendar, ArrowRight } from "lucide-react";
import Link from "next/link";

// Pages that are restricted by role
const ROLE_RESTRICTIONS: Record<string, string[]> = {
  "/dashboard": ["admin", "manager"],
  "/settings": ["admin", "manager"],
  "/users": ["admin", "manager"],
  "/roles": ["admin", "manager"],
  "/reports": ["admin", "manager"],
  "/expenses": ["admin", "manager"],
  "/branches": ["admin", "manager"],
  "/quotations": ["admin", "manager"],
};

function getRequiredRoles(path: string): string[] | null {
  // Check exact match first, then prefix match
  for (const [route, roles] of Object.entries(ROLE_RESTRICTIONS)) {
    if (path === route || path.startsWith(route + "/")) {
      return roles;
    }
  }
  return null; // No restriction
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isOpen } = useSidebarStore();
  const { user, isAuthenticated, isLoading, serverError } = useAuthStore();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (serverError) return;
    if (isLoading) return; // Wait for initial auth check

    // Redirect unauthenticated users to login
    if (!isAuthenticated || !user) {
      router.replace("/login");
      return;
    }

    // Enforce role-based page access
    const requiredRoles = getRequiredRoles(pathname);
    if (requiredRoles && !requiredRoles.includes(user.role)) {
      // Redirect to leads page (agents' default landing page)
      router.replace("/leads");
    }
  }, [isAuthenticated, user, isLoading, pathname, router, serverError]);

  // Show server error state if backend is down
  if (serverError) {
    return (
      <div className="flex min-h-screen w-full flex-col items-center justify-center bg-[var(--tf-bg)] p-6">
        <div className="max-w-md w-full text-center space-y-8">
          <div className="mx-auto w-20 h-20 bg-red-500/10 rounded-full flex items-center justify-center mb-6">
            <WifiOff className="w-10 h-10 text-red-500" />
          </div>
          
          <div className="space-y-3">
            <h2 className="text-3xl font-bold text-tf-text-primary tracking-tight">Can't connect right now</h2>
            <p className="text-tf-text-secondary text-lg">We're having trouble reaching the server. Please check your connection or try again.</p>
          </div>

          <Button 
            size="lg"
            onClick={() => window.location.reload()} 
            className="w-full bg-tf-primary text-white hover:bg-tf-primary-hover font-semibold h-12"
          >
            Try Again
          </Button>

          <div className="pt-8 border-t border-tf-border text-left">
            <h3 className="text-sm font-semibold text-tf-text-secondary uppercase tracking-wider mb-4">Quick Links</h3>
            <div className="grid grid-cols-2 gap-3">
              <Link href="/leads" prefetch={false} className="flex items-center p-3 rounded-xl border border-tf-border bg-tf-surface hover:bg-tf-surface-hover transition-colors group">
                <Target className="w-5 h-5 text-tf-primary mr-3" />
                <span className="text-sm font-medium text-tf-text-primary group-hover:text-tf-primary transition-colors">Leads</span>
              </Link>
              <Link href="/customers" prefetch={false} className="flex items-center p-3 rounded-xl border border-tf-border bg-tf-surface hover:bg-tf-surface-hover transition-colors group">
                <Users className="w-5 h-5 text-tf-primary mr-3" />
                <span className="text-sm font-medium text-tf-text-primary group-hover:text-tf-primary transition-colors">Customers</span>
              </Link>
              <Link href="/quotations" prefetch={false} className="flex items-center p-3 rounded-xl border border-tf-border bg-tf-surface hover:bg-tf-surface-hover transition-colors group">
                <FileText className="w-5 h-5 text-tf-primary mr-3" />
                <span className="text-sm font-medium text-tf-text-primary group-hover:text-tf-primary transition-colors">Quotations</span>
              </Link>
              <Link href="/bookings" prefetch={false} className="flex items-center p-3 rounded-xl border border-tf-border bg-tf-surface hover:bg-tf-surface-hover transition-colors group">
                <Calendar className="w-5 h-5 text-tf-primary mr-3" />
                <span className="text-sm font-medium text-tf-text-primary group-hover:text-tf-primary transition-colors">Bookings</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Don't render layout until auth is confirmed, but show a spinner instead of blank page
  if (isLoading || !isAuthenticated || !user) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-[var(--tf-bg)]">
        <div className="text-tf-text-secondary flex flex-col items-center gap-4">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-tf-primary border-t-transparent"></div>
          <p>Redirecting to login...</p>
        </div>
      </div>
    );
  }

  // Check if current page is allowed for this user
  const requiredRoles = getRequiredRoles(pathname);
  if (requiredRoles && !requiredRoles.includes(user.role)) return null;

  return (
    <div className="flex h-screen w-full bg-[var(--tf-bg)]">
      <Sidebar />
      <div
        className={`flex flex-col flex-1 transition-all duration-300 ease-out ${
          isOpen
            ? "ml-[var(--tf-sidebar-width)]"
            : "ml-[var(--tf-sidebar-collapsed-width)]"
        }`}
      >
        <Topbar />
        <main className="flex-1 overflow-y-auto bg-[var(--tf-bg)] p-6">
          <ErrorBoundary>
            {children}
          </ErrorBoundary>
        </main>
      </div>
    </div>
  );
}
