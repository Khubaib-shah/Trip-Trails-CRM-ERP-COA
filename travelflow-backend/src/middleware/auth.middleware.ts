import { Request, Response, NextFunction } from "express";
import { prisma } from "../lib/prisma";
import { ApiError } from "../utils/ApiError";
import { verifyToken } from "../utils/jwt";

export async function authMiddleware(req: Request, _res: Response, next: NextFunction) {
  try {
    const token = req.cookies?.tf_access_token as string | undefined;

    if (!token) {
      throw ApiError.unauthorized("Authentication required");
    }

    const isBlacklisted = await prisma.tokenBlacklist.findUnique({ where: { token } });
    if (isBlacklisted) {
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
