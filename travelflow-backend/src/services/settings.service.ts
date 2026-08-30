import { prisma } from "../lib/prisma";
import { ApiError } from "../utils/ApiError";

export async function getSettings(agencyId: string) {
  const agency = await prisma.agency.findUnique({ where: { id: agencyId } });
  if (!agency) throw ApiError.notFound("Agency");
  return agency;
}

export async function updateSettings(agencyId: string, data: Record<string, unknown>) {
  const agency = await prisma.agency.findUnique({ where: { id: agencyId } });
  if (!agency) throw ApiError.notFound("Agency");
  return prisma.agency.update({ where: { id: agencyId }, data });
}
