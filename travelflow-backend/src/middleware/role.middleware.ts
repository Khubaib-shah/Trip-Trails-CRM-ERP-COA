import { Request, Response, NextFunction } from "express";
import { ApiError } from "../utils/ApiError";
import { prisma } from "../lib/prisma";

export function requireRole(allowedRoles: string[]) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(ApiError.unauthorized());
    }
    if (!allowedRoles.includes(req.user.role)) {
      return next(ApiError.forbidden("Insufficient permissions"));
    }
    next();
  };
}

interface CachedRolePermissions {
  permissions: string[];
  expiresAt: number;
}

const rolePermissionsCache = new Map<string, CachedRolePermissions>();

export function invalidateRolePermissionsCache(agencyId?: string) {
  if (agencyId) {
    for (const key of rolePermissionsCache.keys()) {
      if (key.startsWith(`${agencyId}:`)) {
        rolePermissionsCache.delete(key);
      }
    }
  } else {
    rolePermissionsCache.clear();
  }
}

export function requirePermission(requiredPermission: string) {
  return async (req: Request, _res: Response, next: NextFunction) => {
    try {
      if (!req.user || !req.agencyId) {
        return next(ApiError.unauthorized());
      }
      if (req.user.role === "admin") {
        return next();
      }

      const cacheKey = `${req.agencyId}:${req.user.role}`;
      const cached = rolePermissionsCache.get(cacheKey);
      const now = Date.now();

      let permissions: string[];
      if (cached && cached.expiresAt > now) {
        permissions = cached.permissions;
      } else {
        const role = await prisma.role.findFirst({
          where: { agencyId: req.agencyId, name: req.user.role, isDeleted: false },
        });
        if (!role) {
          return next(ApiError.forbidden("Role not found"));
        }
        permissions = role.permissions as string[];
        rolePermissionsCache.set(cacheKey, {
          permissions,
          expiresAt: now + 60_000,
        });
      }

      if (!permissions.includes(requiredPermission) && !permissions.includes("all")) {
        return next(ApiError.forbidden(`Requires permission: ${requiredPermission}`));
      }

      next();
    } catch (error) {
      next(error);
    }
  };
}
