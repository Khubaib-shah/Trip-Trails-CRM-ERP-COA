import { Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { ApiError } from "../utils/ApiError";
import { verifyToken } from "../utils/jwt";

interface CachedSession {
  user: any;
  agencyId: string;
  expiresAt: number;
}

// In-memory cache for validated sessions (300s / 5m TTL) to prevent DB roundtrips on every HTTP request
const sessionCache = new Map<string, CachedSession>();
const revokedTokens = new Set<string>();

export function invalidateUserSession(token?: string) {
  if (token) {
    sessionCache.delete(token);
    revokedTokens.add(token);
  }
}

export async function authMiddleware(req: Request, _res: Response, next: NextFunction) {
  try {
    const token = req.cookies?.tf_access_token as string | undefined;

    if (!token) {
      throw ApiError.unauthorized("Authentication required");
    }

    if (revokedTokens.has(token)) {
      throw ApiError.unauthorized("Token has been revoked");
    }

    // Check in-memory cache first
    const cached = sessionCache.get(token);
    const now = Date.now();
    if (cached && cached.expiresAt > now) {
      (req as any).user = cached.user;
      req.agencyId = cached.agencyId;
      console.log(`[AUTH] Cache HIT (${Date.now() - now}ms) for ${cached.user.email}`);
      return next();
    }
    const dbStart = Date.now();

    const isBlacklisted = await prisma.tokenBlacklist.findUnique({ where: { token } });
    if (isBlacklisted) {
      revokedTokens.add(token);
      sessionCache.delete(token);
      throw ApiError.unauthorized("Token has been revoked");
    }

    const payload = verifyToken(token);
    const user = await prisma.user.findFirst({
      where: {
        id: payload.userId,
        agencyId: payload.agencyId,
        isDeleted: false,
        status: "active",
      },
      select: {
        id: true,
        agencyId: true,
        branchId: true,
        firstName: true,
        lastName: true,
        email: true,
        role: true,
        status: true,
        phone: true,
        avatarUrl: true,
        lastLoginAt: true,
      },
    });

    if (!user) {
      throw ApiError.unauthorized("Invalid or expired token");
    }

    // Cache session for 300 seconds (5 minutes, or until token expiry)
    sessionCache.set(token, {
      user,
      agencyId: user.agencyId,
      expiresAt: now + 300_000,
    });

    console.log(`[AUTH] DB lookup took ${Date.now() - dbStart}ms for ${user.email}`);

    (req as any).user = user;
    req.agencyId = user.agencyId;
    next();
  } catch (err) {
    if (err instanceof ApiError) {
      next(err);
      return;
    }
    next(ApiError.unauthorized("Invalid or expired token"));
  }
}
