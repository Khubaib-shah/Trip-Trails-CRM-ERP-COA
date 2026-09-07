/**
 * proxy.ts — Edge Authentication Middleware (Parked)
 *
 * NOTE: In Next.js App Router, this middleware can be activated by renaming this file
 * to `middleware.ts` (exporting default or `middleware`). It inspects HttpOnly JWT cookies
 * (`tf_access_token`, `tf_refresh_token`) and manages redirects between /login and /dashboard.
 * It is currently parked as `proxy.ts` during local testing to prevent automatic Edge redirects.
 */

import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function proxy(request: NextRequest) {
  // The backend sets tf_access_token and tf_refresh_token as HttpOnly cookies.
  // Next.js middleware runs on the Edge and CAN read HttpOnly cookies.
  const token = request.cookies.get("tf_access_token");
  const refreshToken = request.cookies.get("tf_refresh_token");
  const isAuthenticated = !!token || !!refreshToken;
  
  const { pathname } = request.nextUrl;

  // Redirect unauthenticated users to login
  if (!isAuthenticated && !pathname.startsWith("/login")) {
    const loginUrl = new URL("/login", request.url);
    return NextResponse.redirect(loginUrl);
  }

  // Redirect authenticated users away from login
  if (isAuthenticated && pathname.startsWith("/login")) {
    const dashboardUrl = new URL("/dashboard", request.url);
    return NextResponse.redirect(dashboardUrl);
  }

  // Root redirect
  if (pathname === "/") {
    return NextResponse.redirect(
      new URL(isAuthenticated ? "/dashboard" : "/login", request.url)
    );
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico|mp4|webm|woff|woff2|ttf|otf)$).*)",
  ],
};
