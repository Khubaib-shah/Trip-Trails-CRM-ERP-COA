import { prisma } from "../lib/prisma";

export type RefPrefix = "BK" | "LD" | "CUS" | "INV" | "EXP" | "SUP" | "RCP" | "CU";

export async function generateRef(prefix: RefPrefix, agencyId: string): Promise<string> {
  const year = new Date().getFullYear();
  const key = `${prefix}_${agencyId}_${year}`;

  const counter = await prisma.counter.upsert({
    where: { id: key },
    update: { seq: { increment: 1 } },
    create: { id: key, seq: 1 },
  });

  return `${prefix}-${year}-${String(counter.seq).padStart(3, "0")}`;
}
