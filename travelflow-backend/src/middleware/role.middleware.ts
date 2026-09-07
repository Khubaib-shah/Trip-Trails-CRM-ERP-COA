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

export function requirePermission(requiredPermission: string) {
  return async (req: Request, _res: Response, next: NextFunction) => {
    try {
      if (!req.user || !req.agencyId) {
        return next(ApiError.unauthorized());
      }
      if (req.user.role === "admin") {
        return next();
      }

      const role = await prisma.role.findFirst({
        where: { agencyId: req.agencyId, name: req.user.role, isDeleted: false },
      });
      if (!role) {
        return next(ApiError.forbidden("Role not found"));
      }

      const permissions = role.permissions as string[];
      if (!permissions.includes(requiredPermission) && !permissions.includes("all")) {
        return next(ApiError.forbidden(`Requires permission: ${requiredPermission}`));
      }

      next();
    } catch (error) {
      next(error);
    }
  };
}
