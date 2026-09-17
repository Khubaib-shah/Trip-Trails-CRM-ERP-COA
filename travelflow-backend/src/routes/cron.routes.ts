import { Router, Request, Response } from "express";
import { runDailyDemoCron } from "../demo/cron-runner";
import { DEMO_CONFIG } from "../demo/config";
import { ApiResponse } from "../utils/ApiResponse";
import { ApiError } from "../utils/ApiError";

const router = Router();

/**
 * POST /api/v1/cron/demo-activity
 * Secure scheduled endpoint for cloud cron providers (Render, Vercel Cron, GitHub Actions).
 * Protected via x-cron-secret or Authorization Bearer header.
 */
router.post("/demo-activity", async (req: Request, res: Response) => {
  const incomingSecret =
    req.headers["x-cron-secret"] ||
    (req.headers.authorization?.startsWith("Bearer ")
      ? req.headers.authorization.slice(7)
      : undefined);

  if (!incomingSecret || incomingSecret !== DEMO_CONFIG.cronSecret) {
    throw ApiError.unauthorized("Invalid or missing cron authorization secret");
  }

  const isForce = req.query.force === "true" || req.body?.force === true;
  const targetDateStr = req.query.date as string | undefined || req.body?.date as string | undefined;
  const targetDate = targetDateStr ? new Date(targetDateStr) : new Date();

  const result = await runDailyDemoCron({ targetDate, force: isForce });

  if (!result.success) {
    throw ApiError.internal(`Daily demo cron failed: ${result.error}`);
  }

  ApiResponse.success(
    res,
    result,
    result.skipped ? `Demo activity skipped: ${result.reason}` : `Demo activity generated for ${result.date}`
  );
});

export default router;
