import { prisma } from "../lib/prisma";
import { ApiError } from "../utils/ApiError";
import { generateRef } from "../utils/refGenerator";
import { buildIdOrRefFilter } from "../utils/serialize";
import { countryForCity, normalizePhone, userDisplayName } from "../utils/helpers";
import * as notificationService from "./notification.service";
import type { z } from "zod";
import type {
  leadSchema,
  leadActivitySchema,
  customerSchema,
  bookingSchema,
  supplierSchema,
  expenseSchema,
  userSchema,
  convertLeadSchema,
} from "../validators/schemas";

type LeadInput = z.infer<typeof leadSchema>;
type LeadActivityInput = z.infer<typeof leadActivitySchema>;
type CustomerInput = z.infer<typeof customerSchema>;
type BookingInput = z.infer<typeof bookingSchema>;
type ConvertLeadInput = z.infer<typeof convertLeadSchema>;
type SupplierInput = z.infer<typeof supplierSchema>;
type ExpenseInput = z.infer<typeof expenseSchema>;
type UserInput = z.infer<typeof userSchema>;

import type { branchSchema } from "../validators/schemas";
type BranchInput = z.infer<typeof branchSchema>;

export interface PaginationOptions {
  page: number;
  limit: number;
}

export interface DateFilterOptions {
  startDate?: string;
  endDate?: string;
}

export interface TenantContext {
  agencyId: string;
  branchId?: string;
  userRole?: string;
  userBranchId?: string;
  callerId?: string;
  callerRole?: string;
}

export function tenant(ctx: string | TenantContext) {
  if (typeof ctx === "string") {
    return { agencyId: ctx, isDeleted: false } as const;
  }
  const filter: { agencyId: string; isDeleted: boolean; branchId?: string } = {
    agencyId: ctx.agencyId,
    isDeleted: false,
  };

  if (ctx.userRole === "admin") {
    if (ctx.branchId && ctx.branchId !== "all") {
      filter.branchId = ctx.branchId;
    }
  } else {
    if (ctx.userBranchId) {
      filter.branchId = ctx.userBranchId;
    }
  }

  return filter;
}

async function getDefaultBranchId(agencyId: string): Promise<string> {
  const branch = await prisma.branch.findFirst({
    where: { agencyId, isDeleted: false, isHeadOffice: true },
  });
  if (branch) return branch.id;
  const anyBranch = await prisma.branch.findFirst({
    where: { agencyId, isDeleted: false },
  });
  if (!anyBranch) throw ApiError.badRequest("No branch configured for this agency");
  return anyBranch.id;
}

async function enrichLead(doc: any) {
  const leadId = doc.id;
  const activities = await prisma.leadActivity.findMany({
    where: { leadId },
    orderBy: { createdAt: "desc" },
  });
  return { ...doc, activities };
}

async function enrichLeadsBatch(docs: any[]) {
  const leadIds = docs.map((j) => j.id);

  const activities = await prisma.leadActivity.findMany({
    where: { leadId: { in: leadIds } },
    orderBy: { createdAt: "desc" },
  });

  const activitiesMap = new Map<string, any[]>();
  for (const act of activities) {
    if (!activitiesMap.has(act.leadId)) {
      activitiesMap.set(act.leadId, []);
    }
    activitiesMap.get(act.leadId)!.push(act);
  }

  return docs.map((doc) => ({
    ...doc,
    activities: activitiesMap.get(doc.id) || [],
  }));
}

async function enrichCustomer(doc: any, ctx: string | TenantContext) {
  const customerId = doc.id;
  const base = typeof ctx === "string"
    ? { agencyId: ctx, isDeleted: false }
    : { agencyId: ctx.agencyId, isDeleted: false };

  const bookings = await prisma.booking.findMany({
    where: { ...base, customerId },
  });
  const totalSpent = bookings.reduce((sum, b) => sum + b.salePrice, 0);
  return {
    ...doc,
    totalBookings: bookings.length,
    totalSpent,
    country: (doc.country as string) ?? "Pakistan",
  };
}

async function enrichCustomersBatch(docs: any[], ctx: string | TenantContext) {
  const customerIds = docs.map((j) => j.id);
  const base = typeof ctx === "string"
    ? { agencyId: ctx, isDeleted: false }
    : { agencyId: ctx.agencyId, isDeleted: false };

  const stats = await prisma.booking.groupBy({
    by: ["customerId"],
    where: { ...base, customerId: { in: customerIds } },
    _count: { id: true },
    _sum: { salePrice: true },
  });

  const statsMap = new Map();
  for (const stat of stats) {
    statsMap.set(stat.customerId, {
      totalBookings: stat._count.id,
      totalSpent: stat._sum.salePrice ?? 0,
    });
  }

  return docs.map((doc) => {
    const stat = statsMap.get(doc.id) || { totalBookings: 0, totalSpent: 0 };
    return {
      ...doc,
      totalBookings: stat.totalBookings,
      totalSpent: stat.totalSpent,
      country: (doc.country as string) ?? "Pakistan",
    };
  });
}

async function enrichBooking(doc: any, ctx: string | TenantContext) {
  const base = typeof ctx === "string"
    ? { agencyId: ctx, isDeleted: false }
    : { agencyId: ctx.agencyId, isDeleted: false };

  const [customer, supplier, agent, branch] = await Promise.all([
    doc.customerId
      ? prisma.customer.findFirst({ where: { id: doc.customerId, ...base } })
      : Promise.resolve(null),
    doc.supplierId
      ? prisma.supplier.findFirst({ where: { id: doc.supplierId, ...base } })
      : Promise.resolve(null),
    doc.agentId
      ? prisma.user.findFirst({ where: { id: doc.agentId, ...base } })
      : Promise.resolve(null),
    doc.branchId
      ? prisma.branch.findFirst({ where: { id: doc.branchId, ...base } })
      : Promise.resolve(null),
  ]);

  return {
    ...doc,
    customer: customer || undefined,
    supplier: supplier || undefined,
    agent: agent ? { id: agent.id, name: userDisplayName(agent) } : undefined,
    branch: branch ? { id: branch.id, name: branch.name } : undefined,
  };
}

export function applyDateFilter(filter: any, dates?: DateFilterOptions, field: string = "createdAt") {
  if (dates?.startDate || dates?.endDate) {
    filter[field] = {};
    if (dates.startDate) filter[field].gte = new Date(dates.startDate);
    if (dates.endDate) filter[field].lte = new Date(dates.endDate);
  }
}

export async function getDashboardStats(ctx: TenantContext, dates?: DateFilterOptions) {
  const base = tenant(ctx);
  const now = new Date();

  let curStart: Date;
  let curEnd: Date;
  let prevStart: Date;
  let prevEnd: Date;

  if (dates?.startDate && dates?.endDate) {
    curStart = new Date(dates.startDate);
    curEnd = new Date(dates.endDate);
    const duration = curEnd.getTime() - curStart.getTime();
    prevStart = new Date(curStart.getTime() - duration - 1);
    prevEnd = new Date(curStart.getTime() - 1);
  } else {
    const month = now.getMonth();
    const year = now.getFullYear();
    curStart = new Date(year, month, 1);
    curEnd = new Date(year, month + 1, 0, 23, 59, 59, 999);
    prevStart = new Date(year, month - 1, 1);
    prevEnd = new Date(year, month, 0, 23, 59, 59, 999);
  }

  const baseWhere = { agencyId: base.agencyId, isDeleted: false, ...("branchId" in base && base.branchId ? { branchId: base.branchId } : {}) };

  const [
    leads,
    customers,
    currentBookings,
    currentExpenses,
    activities,
    prevMonthBookings,
    prevMonthExpenses,
    prevMonthLeads,
    prevMonthCustomers,
    branches,
    branchUserCounts,
  ] = await Promise.all([
    prisma.lead.count({ where: { ...baseWhere, createdAt: { gte: curStart, lte: curEnd } } }),
    prisma.customer.count({ where: { ...baseWhere, createdAt: { gte: curStart, lte: curEnd } } }),
    prisma.booking.findMany({ where: { ...baseWhere, createdAt: { gte: curStart, lte: curEnd } } }),
    prisma.expense.findMany({ where: { ...baseWhere, date: { gte: curStart, lte: curEnd } } }),
    prisma.recentActivity.findMany({
      where: { agencyId: base.agencyId, createdAt: { gte: curStart, lte: curEnd } },
      orderBy: { createdAt: "desc" },
      take: 20,
    }),
    prisma.booking.findMany({ where: { ...baseWhere, createdAt: { gte: prevStart, lte: prevEnd } } }),
    prisma.expense.findMany({ where: { ...baseWhere, date: { gte: prevStart, lte: prevEnd } } }),
    prisma.lead.count({ where: { ...baseWhere, createdAt: { gte: prevStart, lte: prevEnd } } }),
    prisma.customer.count({ where: { ...baseWhere, createdAt: { gte: prevStart, lte: prevEnd } } }),
    prisma.branch.findMany({ where: { agencyId: base.agencyId, isDeleted: false } }),
    prisma.user.groupBy({
      by: ["branchId"],
      where: { agencyId: base.agencyId, isDeleted: false },
      _count: { id: true },
    }),
  ]);

  const curRevenue = currentBookings.reduce((s, b) => s + Number(b.salePrice), 0);
  const curProfit = currentBookings.reduce((s, b) => s + Number(b.profit), 0);
  const curExpenses = currentExpenses.reduce((s, e) => s + Number(e.amount), 0);
  const curBookingCount = currentBookings.length;

  const prevRevenue = prevMonthBookings.reduce((s, b) => s + Number(b.salePrice), 0);
  const prevProfit = prevMonthBookings.reduce((s, b) => s + Number(b.profit), 0);
  const prevExpensesTotal = prevMonthExpenses.reduce((s, e) => s + Number(e.amount), 0);
  const prevBookingCount = prevMonthBookings.length;

  function trendPct(cur: number, prev: number): number {
    if (prev === 0) return cur > 0 ? 100 : 0;
    return Number((((cur - prev) / prev) * 100).toFixed(1));
  }

  const staffMap = new Map(branchUserCounts.map((u) => [u.branchId, typeof u._count === "object" ? (u._count.id ?? 0) : 0]));

  const branchPerformance = branches.map((branch) => {
    const bId = branch.id;
    const branchBookings = currentBookings.filter((b) => b.branchId === bId);
    const branchPrevBookings = prevMonthBookings.filter((b) => b.branchId === bId);
    const branchExpenses = currentExpenses.filter((e) => e.branchId === bId);

    const revenue = branchBookings.reduce((s, b) => s + Number(b.salePrice), 0);
    const profit = branchBookings.reduce((s, b) => s + Number(b.profit), 0);
    const prevBranchRevenue = branchPrevBookings.reduce((s, b) => s + Number(b.salePrice), 0);
    const expensesTotal = branchExpenses.reduce((s, e) => s + Number(e.amount), 0);

    return {
      name: branch.name,
      code: branch.code,
      revenue,
      profit,
      expenses: expensesTotal,
      staff: staffMap.get(bId) || 0,
      growth: trendPct(revenue, prevBranchRevenue),
    };
  }).sort((a, b) => b.revenue - a.revenue).slice(0, 5);

  return {
    totalLeads: leads,
    totalCustomers: customers,
    monthlyRevenue: curRevenue,
    monthlyProfit: curProfit,
    totalExpenses: curExpenses,
    activeBookings: currentBookings.filter((b) => b.bookingStatus === "confirmed").length,
    trends: {
      leads: trendPct(leads, prevMonthLeads),
      customers: trendPct(customers, prevMonthCustomers),
      revenue: trendPct(curRevenue, prevRevenue),
      profit: trendPct(curProfit, prevProfit),
      expenses: trendPct(curExpenses, prevExpensesTotal),
      bookings: trendPct(curBookingCount, prevBookingCount),
    },
    sparklines: {
      leads: [0, 0, 0, 0, 0, 0, 0],
      customers: [0, 0, 0, 0, 0, 0, 0],
      revenue: [0, 0, 0, 0, 0, 0, 0],
      profit: [0, 0, 0, 0, 0, 0, 0],
      expenses: [0, 0, 0, 0, 0, 0, 0],
      bookings: [0, 0, 0, 0, 0, 0, 0],
    },
    branchPerformance,
    recentActivities: activities.map((a) => ({
      id: a.id,
      type: a.type,
      title: a.title,
      detail: a.detail,
      time: a.createdAt,
    })),
  };
}

export async function getAnalyticsStats(ctx: TenantContext, timeRange: string) {
  const baseFilter = tenant(ctx);

  const now = new Date();
  const startDate = new Date();
  if (timeRange === "30d") startDate.setDate(now.getDate() - 30);
  else if (timeRange === "6m") startDate.setMonth(now.getMonth() - 6);
  else if (timeRange === "1y") startDate.setFullYear(now.getFullYear() - 1);
  else startDate.setFullYear(2000);

  const bookings = await prisma.booking.findMany({
    where: { ...baseFilter, createdAt: { gte: startDate, lte: now } } as any,
  });
  const totalRevenue = bookings.reduce((sum, b) => sum + (b.salePrice || 0), 0);
  const totalProfit = bookings.reduce((sum, b) => sum + (b.profit || 0), 0);
  const totalBookings = bookings.length;
  const profitMargin = totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).toFixed(1) : "0.0";

  const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const revenueMap = new Map<string, { revenue: number; profit: number }>();
  for (const b of bookings) {
    const d = new Date(b.createdAt);
    const key = `${monthNames[d.getMonth()]} ${d.getFullYear()}`;
    const existing = revenueMap.get(key) || { revenue: 0, profit: 0 };
    existing.revenue += b.salePrice;
    existing.profit += b.profit;
    revenueMap.set(key, existing);
  }
  const revenueData = Array.from(revenueMap.entries()).map(([name, data]) => ({ name, ...data }));

  const leadSourceAgg = await prisma.lead.groupBy({
    by: ["source"],
    where: { ...baseFilter, createdAt: { gte: startDate, lte: now } } as any,
    _count: { id: true },
  });
  const colors = ["#2563eb", "#16a34a", "#dc2626", "#9333ea", "#ea580c", "#0f172a"];
  const leadSourceData = leadSourceAgg.map((d, i) => ({
    name: d.source || "Unknown",
    value: d._count.id,
    color: colors[i % colors.length],
  }));

  const branchDataAgg = await prisma.booking.groupBy({
    by: ["branchId"],
    where: { ...baseFilter, createdAt: { gte: startDate, lte: now } } as any,
    _count: { id: true },
  });
  const branchNameMap = new Map(
    (await prisma.branch.findMany({ where: { agencyId: baseFilter.agencyId as string } })).map((b) => [b.id, b.name])
  );
  const branchData = branchDataAgg.map((d) => ({
    name: branchNameMap.get(d.branchId ?? "") || "Unknown Branch",
    bookings: d._count.id,
  }));

  return {
    kpis: { totalRevenue, totalProfit, totalBookings, profitMargin },
    revenueData,
    leadSourceData,
    branchData,
  };
}

// --- Leads ---

export async function listLeads(ctx: TenantContext, pagination?: PaginationOptions, dates?: DateFilterOptions) {
  const filter: any = tenant(ctx);
  applyDateFilter(filter, dates);

  if (!pagination) {
    const leads = await prisma.lead.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      include: { assignedAgent: { select: { id: true, firstName: true, lastName: true, email: true } } },
    });
    const data = await enrichLeadsBatch(leads);
    return { data, total: data.length, page: 1, limit: data.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;

  const [leads, total] = await Promise.all([
    prisma.lead.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      include: { assignedAgent: { select: { id: true, firstName: true, lastName: true, email: true } } },
    }),
    prisma.lead.count({ where: filter }),
  ]);

  const data = await enrichLeadsBatch(leads);
  return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getLead(ctx: TenantContext, idOrRef: string) {
  const lead = await prisma.lead.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "leadRef") } as any,
  });
  if (!lead) return null;
  return enrichLead(lead);
}

export async function createLead(ctx: TenantContext, values: LeadInput, actor: string) {
  const agencyId = ctx.agencyId;
  const branchId = values.branchId ?? (await getDefaultBranchId(agencyId));
  const leadRef = await generateRef("LD", agencyId);
  const lead = await prisma.lead.create({
    data: {
      agencyId,
      leadRef,
      name: values.name,
      phone: values.phone,
      whatsapp: values.whatsapp || null,
      email: values.email || null,
      destination: values.destination,
      travelDate: values.travelDate ? new Date(values.travelDate) : null,
      budget: values.budget,
      adults: values.adults ?? 1,
      children: values.children ?? 0,
      specialRequirements: values.specialRequirements || null,
      source: values.source,
      status: values.status,
      assignedAgentId: values.assignedAgentId || null,
      branchId,
      notes: values.notes || null,
    },
  });

  await prisma.leadActivity.create({
    data: {
      agencyId,
      leadId: lead.id,
      type: "note",
      description: values.notes || "Lead captured",
      createdBy: actor,
    },
  });

  if (values.assignedAgentId) {
    try {
      await notificationService.createNotification(ctx, {
        recipientId: values.assignedAgentId,
        title: "New Lead Assigned",
        body: `You have been assigned a new lead: ${values.name}`,
        entityType: "lead",
        entityId: lead.id,
        type: "info",
      });
    } catch (e) {
      console.error("Failed to send notification", e);
    }
  }

  return enrichLead(lead);
}

export async function updateLead(ctx: TenantContext, idOrRef: string, values: Partial<LeadInput>, actor?: string) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "leadRef") } as any;
  const existing = await prisma.lead.findFirst({ where: filter });
  if (!existing) return null;

  const lead = await prisma.lead.update({
    where: { id: existing.id },
    data: {
      ...(values.name !== undefined && { name: values.name }),
      ...(values.phone !== undefined && { phone: values.phone }),
      ...(values.whatsapp !== undefined && { whatsapp: values.whatsapp || null }),
      ...(values.email !== undefined && { email: values.email || null }),
      ...(values.destination !== undefined && { destination: values.destination }),
      ...(values.travelDate !== undefined && {
        travelDate: values.travelDate ? new Date(values.travelDate) : null,
      }),
      ...(values.budget !== undefined && { budget: values.budget }),
      ...(values.adults !== undefined && { adults: values.adults }),
      ...(values.children !== undefined && { children: values.children }),
      ...(values.specialRequirements !== undefined && {
        specialRequirements: values.specialRequirements || null,
      }),
      ...(values.source !== undefined && { source: values.source }),
      ...(values.status !== undefined && { status: values.status }),
      ...(values.assignedAgentId !== undefined && {
        assignedAgentId: values.assignedAgentId || null,
      }),
      ...(values.branchId !== undefined && { branchId: values.branchId }),
      ...(values.notes !== undefined && { notes: values.notes || null }),
    },
  });

  if (values.notes) {
    await prisma.leadActivity.create({
      data: {
        agencyId: lead.agencyId,
        leadId: lead.id,
        type: "note",
        description: values.notes,
        createdBy: actor || "System",
      },
    });
  }

  return enrichLead(lead);
}

export async function addLeadActivity(
  ctx: TenantContext,
  idOrRef: string,
  values: LeadActivityInput,
  actor: string
) {
  const lead = await prisma.lead.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "leadRef") } as any,
  });
  if (!lead) throw ApiError.notFound("Lead");
  const activity = await prisma.leadActivity.create({
    data: {
      agencyId: ctx.agencyId,
      leadId: lead.id,
      type: values.type,
      description: values.description,
      outcome: values.outcome || null,
      createdBy: actor,
    },
  });
  await prisma.lead.update({
    where: { id: lead.id },
    data: { lastContactedAt: new Date() },
  });
  return activity;
}

export async function convertLead(
  ctx: TenantContext,
  idOrRef: string,
  values: ConvertLeadInput,
  userId: string,
  actor: string
) {
  const agencyId = ctx.agencyId;

  const lead = await prisma.lead.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "leadRef") } as any,
  });
  if (!lead) throw ApiError.notFound("Lead");

  const customer = await findOrCreateCustomerFromLeadDoc(agencyId, lead);
  const branchId = values.branchId ?? lead.branchId;
  const agentId = values.agentId ?? userId;
  const bookingRef = await generateRef("BK", agencyId);
  const amountReceived = values.amountReceived ?? 0;
  const profit = values.salePrice - values.costPrice;
  const profitMargin = values.salePrice > 0 ? (profit / values.salePrice) * 100 : 0;

  const booking = await prisma.$transaction(async (tx) => {
    const b = await tx.booking.create({
      data: {
        agencyId,
        bookingRef,
        pnr: values.pnr || undefined,
        ticketNumber: values.ticketNumber || undefined,
        customerId: customer.id,
        supplierId: values.supplierId,
        branchId,
        agentId,
        leadId: lead.id,
        airline: values.airline,
        departureCity: values.departureCity,
        arrivalCity: values.arrivalCity,
        departureDate: new Date(values.departureDate),
        returnDate: values.returnDate ? new Date(values.returnDate) : null,
        costPrice: values.costPrice,
        salePrice: values.salePrice,
        profit,
        profitMargin,
        bookingStatus: "confirmed",
        paymentStatus: values.paymentStatus,
        amountReceived,
        balance: values.salePrice - amountReceived,
        notes: values.notes || null,
      },
    });

    await tx.lead.update({
      where: { id: lead.id },
      data: { status: "converted" },
    });

    await tx.leadActivity.create({
      data: {
        agencyId,
        leadId: lead.id,
        type: "booking_created",
        description: `Converted to Booking ${bookingRef}`,
        createdBy: actor,
      },
    });

    return b;
  });

  return enrichBooking(booking, ctx);
}

// --- Customers ---

async function findOrCreateCustomerFromLeadDoc(agencyId: string, lead: any) {
  const phoneNorm = normalizePhone(lead.phone);
  let core = phoneNorm;
  if (phoneNorm.startsWith("92")) core = phoneNorm.slice(2);
  else if (phoneNorm.startsWith("0")) core = phoneNorm.slice(1);
  const variants = [lead.phone, phoneNorm];
  if (core.length === 10) {
    const part1 = core.slice(0, 3);
    const part2 = core.slice(3);
    variants.push(
      `+92${part1}${part2}`,
      `+92${part1}-${part2}`,
      `+92${part1} ${part2}`,
      `0${part1}${part2}`,
      `0${part1}-${part2}`,
      `0${part1} ${part2}`
    );
  }
  const existing = await prisma.customer.findFirst({
    where: { agencyId, isDeleted: false, phone: { in: Array.from(new Set(variants)) } },
  });
  if (existing) return existing;
  const parts = lead.name.trim().split(/\s+/);
  const firstName = parts[0] ?? lead.name;
  const lastName = parts.slice(1).join(" ") || firstName;
  const customerRef = await generateRef("CUS", agencyId);
  return prisma.customer.create({
    data: {
      agencyId,
      customerRef,
      type: "individual",
      firstName,
      lastName,
      email: lead.email,
      phone: lead.phone,
      whatsapp: lead.whatsapp,
      city: "N/A",
      country: "Pakistan",
    },
  });
}

export async function findOrCreateCustomerFromLead(ctx: TenantContext, idOrRef: string) {
  const lead = await prisma.lead.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "leadRef") } as any,
  });
  if (!lead) throw ApiError.notFound("Lead");
  const customer = await findOrCreateCustomerFromLeadDoc(ctx.agencyId, lead);
  return enrichCustomer(customer, ctx);
}

export async function listCustomers(ctx: TenantContext, pagination?: PaginationOptions, dates?: DateFilterOptions) {
  const filter: any = tenant(ctx);
  applyDateFilter(filter, dates);

  if (!pagination) {
    const customers = await prisma.customer.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
    });
    const data = await enrichCustomersBatch(customers, ctx);
    return { data, total: data.length, page: 1, limit: data.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;

  const [customers, total] = await Promise.all([
    prisma.customer.findMany({ where: filter, orderBy: { createdAt: "desc" }, skip, take: limit }),
    prisma.customer.count({ where: filter }),
  ]);

  const data = await enrichCustomersBatch(customers, ctx);
  return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getCustomer(ctx: TenantContext, idOrRef: string) {
  const customer = await prisma.customer.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "customerRef") } as any,
  });
  if (!customer) return null;
  return enrichCustomer(customer, ctx);
}

export async function createCustomer(ctx: TenantContext, values: CustomerInput) {
  const agencyId = ctx.agencyId;
  const customerRef = await generateRef("CUS", agencyId);
  const customer = await prisma.customer.create({
    data: {
      agencyId,
      customerRef,
      type: values.type,
      firstName: values.firstName,
      lastName: values.lastName,
      companyName: values.companyName || null,
      businessType: values.businessType || null,
      taxNumber: values.taxNumber || null,
      email: values.email || null,
      phone: values.phone,
      whatsapp: values.whatsapp || null,
      dateOfBirth: values.dateOfBirth ? new Date(values.dateOfBirth) : null,
      gender: values.gender || null,
      cnic: values.cnic || null,
      passportNumber: values.passportNumber || null,
      city: values.city,
      country: values.country ?? countryForCity(values.city),
      address: values.address,
      emergencyContactName: values.emergencyContactName || null,
      emergencyContactPhone: values.emergencyContactPhone || null,
      internalNotes: values.internalNotes || null,
    },
  });
  return enrichCustomer(customer, ctx);
}

export async function updateCustomer(ctx: TenantContext, idOrRef: string, values: CustomerInput) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "customerRef") } as any;
  const existing = await prisma.customer.findFirst({ where: filter });
  if (!existing) return null;
  const customer = await prisma.customer.update({
    where: { id: existing.id },
    data: {
      type: values.type,
      firstName: values.firstName,
      lastName: values.lastName,
      companyName: values.companyName || null,
      businessType: values.businessType || null,
      taxNumber: values.taxNumber || null,
      email: values.email || null,
      phone: values.phone,
      whatsapp: values.whatsapp || null,
      dateOfBirth: values.dateOfBirth ? new Date(values.dateOfBirth) : null,
      gender: values.gender || null,
      cnic: values.cnic || null,
      passportNumber: values.passportNumber || null,
      city: values.city,
      country: values.country ?? countryForCity(values.city),
      address: values.address,
      emergencyContactName: values.emergencyContactName || null,
      emergencyContactPhone: values.emergencyContactPhone || null,
      internalNotes: values.internalNotes || null,
    },
  });
  return enrichCustomer(customer, ctx);
}

export async function listCustomerNotes(ctx: TenantContext, customerId: string) {
  return prisma.customerNote.findMany({
    where: { agencyId: ctx.agencyId, customerId },
    orderBy: { createdAt: "desc" },
  });
}

export async function createCustomerNote(ctx: TenantContext, customerId: string, note: string, actor: string) {
  const customer = await prisma.customer.findFirst({ where: { id: customerId, ...tenant(ctx) as any } });
  if (!customer) throw ApiError.notFound("Customer");
  return prisma.customerNote.create({
    data: { agencyId: ctx.agencyId, customerId, note, addedBy: actor },
  });
}

export async function deleteCustomerNote(ctx: TenantContext, noteId: string) {
  const result = await prisma.customerNote.deleteMany({ where: { id: noteId, agencyId: ctx.agencyId } });
  return result.count > 0;
}

export async function listCustomerDocuments(ctx: TenantContext, customerId: string) {
  return prisma.customerDocument.findMany({
    where: { agencyId: ctx.agencyId, customerId },
    orderBy: { createdAt: "desc" },
  });
}

export async function createCustomerDocument(
  ctx: TenantContext,
  customerId: string,
  doc: { documentType: string; fileName: string; fileSize: number; mimeType: string; fileUrl: string; notes?: string },
  actor: string
) {
  const customer = await prisma.customer.findFirst({ where: { id: customerId, ...tenant(ctx) as any } });
  if (!customer) throw ApiError.notFound("Customer");
  return prisma.customerDocument.create({
    data: {
      agencyId: ctx.agencyId,
      customerId,
      documentType: doc.documentType,
      fileName: doc.fileName,
      fileSize: doc.fileSize,
      mimeType: doc.mimeType,
      fileUrl: doc.fileUrl,
      notes: doc.notes || null,
      uploadedBy: actor,
    },
  });
}

export async function deleteCustomerDocument(ctx: TenantContext, docId: string) {
  const result = await prisma.customerDocument.deleteMany({ where: { id: docId, agencyId: ctx.agencyId } });
  return result.count > 0;
}

// --- Bookings ---

export async function listBookings(ctx: TenantContext, pagination?: PaginationOptions, dates?: DateFilterOptions) {
  const filter: any = tenant(ctx);
  applyDateFilter(filter, dates);

  if (!pagination) {
    const bookings = await prisma.booking.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      include: { customer: true, supplier: true, agent: true, branch: true },
    });
    const data = bookings.map((b) => ({
      ...b,
      agent: b.agent ? { id: b.agent.id, name: userDisplayName(b.agent) } : undefined,
    }));
    return { data, total: data.length, page: 1, limit: data.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;

  const [bookings, total] = await Promise.all([
    prisma.booking.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      include: { customer: true, supplier: true, agent: true, branch: true },
    }),
    prisma.booking.count({ where: filter }),
  ]);

  const data = bookings.map((b) => ({
    ...b,
    agent: b.agent ? { id: b.agent.id, name: userDisplayName(b.agent) } : undefined,
  }));
  return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getBooking(ctx: TenantContext, idOrRef: string) {
  const booking = await prisma.booking.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "bookingRef") } as any,
  });
  if (!booking) return null;
  return enrichBooking(booking, ctx);
}

export async function createBooking(ctx: TenantContext, values: BookingInput, userId: string, actor: string) {
  const agencyId = ctx.agencyId;
  const branchId = values.branchId ?? (await getDefaultBranchId(agencyId));
  const agentId = values.agentId ?? userId;
  const bookingRef = await generateRef("BK", agencyId);
  const amountReceived = values.amountReceived ?? 0;
  const profit = values.salePrice - values.costPrice;
  const profitMargin = values.salePrice > 0 ? (profit / values.salePrice) * 100 : 0;

  const booking = await prisma.booking.create({
    data: {
      agencyId,
      bookingRef,
      pnr: values.pnr || undefined,
      ticketNumber: values.ticketNumber || undefined,
      customerId: values.customerId,
      supplierId: values.supplierId,
      branchId,
      agentId,
      leadId: values.leadId || undefined,
      airline: values.airline,
      departureCity: values.departureCity,
      arrivalCity: values.arrivalCity,
      departureDate: new Date(values.departureDate),
      returnDate: values.returnDate ? new Date(values.returnDate) : null,
      costPrice: values.costPrice,
      salePrice: values.salePrice,
      profit,
      profitMargin,
      bookingStatus: "confirmed",
      paymentStatus: values.paymentStatus,
      amountReceived,
      balance: values.salePrice - amountReceived,
      notes: values.notes || null,
    },
  });

  if (values.leadId) {
    await prisma.lead.update({ where: { id: values.leadId }, data: { status: "converted" } });
    await prisma.leadActivity.create({
      data: {
        agencyId,
        leadId: values.leadId,
        type: "booking_created",
        description: `Converted to Booking ${bookingRef}`,
        createdBy: actor,
      },
    });
  }

  await prisma.bookingActivity.create({
    data: {
      agencyId,
      bookingId: booking.id,
      type: "created",
      title: "Booking Created",
      description: "Initial reservation made",
      createdBy: actor,
    },
  });

  try {
    const manager = await prisma.user.findFirst({ where: { agencyId, branchId, role: "manager", isDeleted: false } });
    const admin = await prisma.user.findFirst({ where: { agencyId, role: "admin", isDeleted: false } });
    const recipientId = manager ? manager.id : admin ? admin.id : null;
    if (recipientId) {
      await notificationService.createNotification(ctx, {
        recipientId,
        title: "New Booking Created",
        body: `A new booking (${bookingRef}) has been created by ${actor}`,
        entityType: "booking",
        entityId: booking.id,
        type: "success",
      });
    }
  } catch (e) {
    console.error("Failed to send notification for booking", e);
  }

  return enrichBooking(booking, ctx);
}

export async function updateBooking(ctx: TenantContext, idOrRef: string, values: BookingInput, actor: string) {
  const amountReceived = values.amountReceived ?? 0;
  const profit = values.salePrice - values.costPrice;
  const profitMargin = values.salePrice > 0 ? (profit / values.salePrice) * 100 : 0;

  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "bookingRef") } as any;
  const existing = await prisma.booking.findFirst({ where: filter });
  if (!existing) return null;

  const booking = await prisma.booking.update({
    where: { id: existing.id },
    data: {
      customerId: values.customerId,
      supplierId: values.supplierId,
      airline: values.airline,
      departureCity: values.departureCity,
      arrivalCity: values.arrivalCity,
      departureDate: new Date(values.departureDate),
      returnDate: values.returnDate ? new Date(values.returnDate) : undefined,
      pnr: values.pnr || undefined,
      ticketNumber: values.ticketNumber || undefined,
      costPrice: values.costPrice,
      salePrice: values.salePrice,
      profit,
      profitMargin,
      paymentStatus: values.paymentStatus,
      amountReceived,
      balance: values.salePrice - amountReceived,
      notes: values.notes || null,
    },
  });

  await prisma.bookingActivity.create({
    data: {
      agencyId: ctx.agencyId,
      bookingId: booking.id,
      type: "updated",
      title: "Booking Updated",
      description: "Booking details were updated",
      createdBy: actor,
    },
  });

  return enrichBooking(booking, ctx);
}

// --- Suppliers ---

export async function listSuppliers(ctx: TenantContext, pagination?: PaginationOptions, dates?: DateFilterOptions) {
  const filter: any = tenant(ctx);
  applyDateFilter(filter, dates);

  if (!pagination) {
    const suppliers = await prisma.supplier.findMany({ where: filter, orderBy: { createdAt: "desc" } });
    return { data: suppliers, total: suppliers.length, page: 1, limit: suppliers.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;
  const [suppliers, total] = await Promise.all([
    prisma.supplier.findMany({ where: filter, orderBy: { createdAt: "desc" }, skip, take: limit }),
    prisma.supplier.count({ where: filter }),
  ]);
  return { data: suppliers, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getSupplier(ctx: TenantContext, id: string) {
  return prisma.supplier.findFirst({ where: { id, ...tenant(ctx) as any } });
}

export async function createSupplier(ctx: TenantContext, values: SupplierInput) {
  return prisma.supplier.create({
    data: {
      agencyId: ctx.agencyId,
      name: values.name,
      category: values.category,
      contactPerson: values.contactPerson,
      email: values.email || null,
      phone: values.phone,
      city: values.city,
      country: values.country,
      balance: 0,
    },
  });
}

export async function updateSupplier(ctx: TenantContext, id: string, values: SupplierInput) {
  const supplier = await prisma.supplier.findFirst({ where: { id, ...tenant(ctx) as any } });
  if (!supplier) return null;
  return prisma.supplier.update({
    where: { id },
    data: {
      name: values.name,
      category: values.category,
      contactPerson: values.contactPerson,
      email: values.email || null,
      phone: values.phone,
      city: values.city,
      country: values.country,
    },
  });
}

// --- Branches ---

export async function listBranches(ctx: TenantContext, pagination?: PaginationOptions) {
  const filter = { agencyId: ctx.agencyId, isDeleted: false };

  if (!pagination) {
    const branches = await prisma.branch.findMany({ where: filter, orderBy: { name: "asc" } });
    return { data: branches, total: branches.length, page: 1, limit: branches.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;
  const [branches, total] = await Promise.all([
    prisma.branch.findMany({ where: filter, orderBy: { name: "asc" }, skip, take: limit }),
    prisma.branch.count({ where: filter }),
  ]);
  return { data: branches, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getBranch(ctx: TenantContext, id: string) {
  return prisma.branch.findFirst({ where: { id, ...tenant(ctx) as any } });
}

export async function createBranch(ctx: TenantContext, values: BranchInput) {
  const code = values.code?.trim().toUpperCase() || values.name.slice(0, 4).toUpperCase();
  const existing = await prisma.branch.findFirst({ where: { agencyId: ctx.agencyId, code, isDeleted: false } });
  if (existing) throw ApiError.conflict("Branch code already in use");
  return prisma.branch.create({
    data: {
      agencyId: ctx.agencyId,
      name: values.name,
      code,
      city: values.city,
      address: values.address || null,
      phone: values.phone || null,
      isHeadOffice: values.isHeadOffice ?? false,
      status: values.status ?? "active",
    },
  });
}

export async function updateBranch(ctx: TenantContext, id: string, values: BranchInput) {
  const branch = await prisma.branch.findFirst({ where: { id, agencyId: ctx.agencyId, isDeleted: false } });
  if (!branch) return null;
  return prisma.branch.update({
    where: { id },
    data: {
      name: values.name,
      city: values.city,
      address: values.address || null,
      phone: values.phone || null,
      isHeadOffice: values.isHeadOffice ?? false,
      status: values.status ?? "active",
    },
  });
}

// --- Users ---

export async function listUsers(ctx: TenantContext, pagination?: PaginationOptions) {
  const filter = { agencyId: ctx.agencyId };

  if (!pagination) {
    const users = await prisma.user.findMany({ where: filter, orderBy: { createdAt: "desc" }, select: { id: true, agencyId: true, branchId: true, firstName: true, lastName: true, email: true, phone: true, role: true, status: true, avatarUrl: true, lastLoginAt: true, createdAt: true } });
    return { data: users, total: users.length, page: 1, limit: users.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;
  const [users, total] = await Promise.all([
    prisma.user.findMany({ where: filter, orderBy: { createdAt: "desc" }, skip, take: limit, select: { id: true, agencyId: true, branchId: true, firstName: true, lastName: true, email: true, phone: true, role: true, status: true, avatarUrl: true, lastLoginAt: true, createdAt: true } }),
    prisma.user.count({ where: filter }),
  ]);
  return { data: users, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getUser(ctx: TenantContext, id: string) {
  return prisma.user.findFirst({ where: { id, ...tenant(ctx) as any }, select: { id: true, agencyId: true, branchId: true, firstName: true, lastName: true, email: true, phone: true, role: true, status: true, avatarUrl: true, lastLoginAt: true, createdAt: true } });
}

export async function listAgents(ctx: TenantContext) {
  return prisma.user.findMany({
    where: { ...tenant(ctx) as any, role: { in: ["agent", "manager"] } },
    orderBy: { firstName: "asc" },
    select: { id: true, firstName: true, lastName: true, email: true, role: true },
  });
}

export async function createUser(ctx: TenantContext, values: UserInput) {
  const existing = await prisma.user.findFirst({ where: { agencyId: ctx.agencyId, email: values.email.toLowerCase(), isDeleted: false } });
  if (existing) throw ApiError.conflict("Email already in use");

  const tempPassword = values.password ?? generateTempPassword();
  const bcrypt = await import("bcryptjs");
  const hashedPassword = await bcrypt.hash(tempPassword, 12);

  const user = await prisma.user.create({
    data: {
      agencyId: ctx.agencyId,
      branchId: values.branchId!,
      firstName: values.firstName,
      lastName: values.lastName,
      email: values.email,
      phone: values.phone || undefined,
      role: values.role,
      status: values.status,
      password: hashedPassword,
    },
  });

  const { password: _, ...userData } = user as any;
  return { ...userData, tempPassword: values.password ? undefined : tempPassword };
}

function generateTempPassword(): string {
  const chars = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#!";
  return Array.from({ length: 12 }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
}

export async function updateUser(ctx: TenantContext, id: string, values: UserInput) {
  if (values.role === "admin" && ctx.callerRole !== "admin") {
    throw ApiError.forbidden("Only an admin can assign the admin role");
  }
  if (ctx.callerId === id && values.role && ctx.callerRole !== values.role) {
    throw ApiError.forbidden("You cannot change your own role");
  }

  const user = await prisma.user.findFirst({ where: { id, ...tenant(ctx) as any } });
  if (!user) return null;

  const updated = await prisma.user.update({
    where: { id },
    data: {
      firstName: values.firstName,
      lastName: values.lastName,
      email: values.email,
      phone: values.phone || undefined,
      role: values.role,
      branchId: values.branchId!,
      status: values.status,
    },
    select: { id: true, agencyId: true, branchId: true, firstName: true, lastName: true, email: true, phone: true, role: true, status: true, avatarUrl: true, lastLoginAt: true, createdAt: true },
  });
  return updated;
}

// --- Expenses ---

export async function listExpenses(ctx: TenantContext, pagination?: PaginationOptions, dates?: DateFilterOptions) {
  const filter: any = tenant(ctx);
  applyDateFilter(filter, dates, "date");

  if (!pagination) {
    const expenses = await prisma.expense.findMany({ where: filter, orderBy: { date: "desc" } });
    return { data: expenses, total: expenses.length, page: 1, limit: expenses.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;
  const [expenses, total] = await Promise.all([
    prisma.expense.findMany({ where: filter, orderBy: { date: "desc" }, skip, take: limit }),
    prisma.expense.count({ where: filter }),
  ]);
  return { data: expenses, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getExpense(ctx: TenantContext, idOrRef: string) {
  return prisma.expense.findFirst({
    where: { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "expenseRef") } as any,
  });
}

export async function createExpense(ctx: TenantContext, values: ExpenseInput, userId: string) {
  const agencyId = ctx.agencyId;
  const branchId = values.branchId ?? (await getDefaultBranchId(agencyId));
  const expenseRef = await generateRef("EXP", agencyId);
  return prisma.expense.create({
    data: {
      agencyId,
      branchId,
      expenseRef,
      title: values.title,
      category: values.category,
      amount: values.amount,
      date: values.date,
      paidTo: values.paidTo,
      paymentMethod: values.paymentMethod,
      notes: values.notes,
      recordedById: userId,
    },
  });
}

export async function updateExpense(ctx: TenantContext, idOrRef: string, values: ExpenseInput) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "expenseRef") } as any;
  const existing = await prisma.expense.findFirst({ where: filter });
  if (!existing) return null;
  return prisma.expense.update({
    where: { id: existing.id },
    data: {
      title: values.title,
      category: values.category,
      amount: values.amount,
      date: values.date,
      paidTo: values.paidTo,
      paymentMethod: values.paymentMethod,
      notes: values.notes,
      ...(values.branchId && { branchId: values.branchId }),
    },
  });
}

// --- Roles ---

export async function listRoles(ctx: TenantContext) {
  return prisma.role.findMany({ where: tenant(ctx) as any, orderBy: { name: "asc" } });
}

export async function updateRolePermissions(ctx: TenantContext, roleId: string, permissions: string[]) {
  const role = await prisma.role.findFirst({ where: { id: roleId, ...tenant(ctx) as any } });
  if (!role) return null;
  return prisma.role.update({ where: { id: roleId }, data: { permissions } });
}

export async function createRole(ctx: TenantContext, data: { name: string; description: string; permissions: string[]; color: string; textColor: string }) {
  return prisma.role.create({
    data: { agencyId: ctx.agencyId, ...data },
  });
}

export async function deleteRole(ctx: TenantContext, roleId: string) {
  const role = await prisma.role.findFirst({ where: { id: roleId, ...tenant(ctx) as any } });
  if (!role) return false;
  await prisma.role.update({ where: { id: roleId }, data: { isDeleted: true, deletedAt: new Date() } });
  return true;
}

// --- Soft Deletes ---

const deletedAt = () => new Date();

export async function deleteLead(ctx: TenantContext, idOrRef: string) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "leadRef") } as any;
  const existing = await prisma.lead.findFirst({ where: filter });
  if (!existing) return false;
  await prisma.lead.update({ where: { id: existing.id }, data: { isDeleted: true, deletedAt: deletedAt() } });
  return true;
}

export async function deleteCustomer(ctx: TenantContext, idOrRef: string) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "customerRef") } as any;
  const existing = await prisma.customer.findFirst({ where: filter });
  if (!existing) return false;
  await prisma.customer.update({ where: { id: existing.id }, data: { isDeleted: true, deletedAt: deletedAt() } });
  return true;
}

export async function deleteBooking(ctx: TenantContext, idOrRef: string) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "bookingRef") } as any;
  const existing = await prisma.booking.findFirst({ where: filter });
  if (!existing) return false;
  await prisma.booking.update({ where: { id: existing.id }, data: { isDeleted: true, deletedAt: deletedAt() } });
  return true;
}

export async function deleteSupplier(ctx: TenantContext, id: string) {
  const supplier = await prisma.supplier.findFirst({ where: { id, ...tenant(ctx) as any } });
  if (!supplier) return false;
  await prisma.supplier.update({ where: { id }, data: { isDeleted: true, deletedAt: deletedAt() } });
  return true;
}

export async function deleteExpense(ctx: TenantContext, idOrRef: string) {
  const filter = { ...tenant(ctx) as any, ...buildIdOrRefFilter(idOrRef, "expenseRef") } as any;
  const existing = await prisma.expense.findFirst({ where: filter });
  if (!existing) return false;
  await prisma.expense.update({ where: { id: existing.id }, data: { isDeleted: true, deletedAt: deletedAt() } });
  return true;
}

export async function deleteUser(ctx: TenantContext, id: string) {
  if (ctx.callerId === id) {
    throw ApiError.forbidden("You cannot delete your own account");
  }
  const user = await prisma.user.findFirst({ where: { id, ...tenant(ctx) as any } });
  if (!user) return false;
  await prisma.user.update({ where: { id }, data: { isDeleted: true, deletedAt: deletedAt() } });
  return true;
}

// --- Supplier Payments ---

export async function recordSupplierPayment(
  ctx: TenantContext,
  supplierId: string,
  data: { amount: number; method: string; reference?: string }
) {
  const supplier = await prisma.supplier.findFirst({ where: { id: supplierId, ...tenant(ctx) as any } });
  if (!supplier) throw ApiError.notFound("Supplier");
  if (data.amount <= 0) throw new ApiError(400, "Amount must be positive");

  const updated = await prisma.supplier.update({
    where: { id: supplierId },
    data: { balance: Math.max(0, supplier.balance - data.amount) },
  });

  await prisma.recentActivity.create({
    data: {
      agencyId: ctx.agencyId,
      type: "payment",
      title: `Payment to ${supplier.name}`,
      detail: `PKR ${data.amount.toLocaleString()} via ${data.method}${data.reference ? ` (Ref: ${data.reference})` : ""}`,
      createdBy: "System",
    },
  });

  return updated;
}

// --- Receipts (Customer Payments) ---

export async function listReceipts(ctx: TenantContext, pagination?: PaginationOptions, dates?: DateFilterOptions) {
  const filter: any = tenant(ctx);
  applyDateFilter(filter, dates, "date");

  if (!pagination) {
    const receipts = await prisma.receipt.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      include: { customer: { select: { firstName: true, lastName: true, companyName: true } }, booking: { select: { bookingRef: true } } },
    });

    const branchIds = [...new Set(receipts.map((r) => r.branchId).filter(Boolean))] as string[];
    const managers = await prisma.user.findMany({
      where: {
        agencyId: ctx.agencyId,
        OR: [
          { branchId: { in: branchIds }, role: { in: ["manager", "branch_manager", "admin"] } },
          { role: "admin" },
        ],
      },
    });

    const getManagerForBranch = (bId: string | null) => {
      if (!bId) return null;
      let mgr = managers.find((m) => m.branchId === bId && ["manager", "branch_manager", "admin"].includes(m.role));
      if (!mgr) mgr = managers.find((m) => m.role === "admin");
      return mgr ? { name: `${mgr.firstName} ${mgr.lastName}`, phone: mgr.phone, email: mgr.email } : null;
    };

    const data = receipts.map((r) => ({
      ...r,
      managerContact: getManagerForBranch(r.branchId),
    }));

    return { data, total: data.length, page: 1, limit: data.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;
  const [receipts, total] = await Promise.all([
    prisma.receipt.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      include: { customer: { select: { firstName: true, lastName: true, companyName: true } }, booking: { select: { bookingRef: true } } },
    }),
    prisma.receipt.count({ where: filter }),
  ]);

  const branchIds = [...new Set(receipts.map((r) => r.branchId).filter(Boolean))] as string[];
  const managers = await prisma.user.findMany({
    where: {
      agencyId: ctx.agencyId,
      OR: [
        { branchId: { in: branchIds }, role: { in: ["manager", "branch_manager", "admin"] } },
        { role: "admin" },
      ],
    },
  });

  const getManagerForBranch = (bId: string | null) => {
    if (!bId) return null;
    let mgr = managers.find((m) => m.branchId === bId && ["manager", "branch_manager", "admin"].includes(m.role));
    if (!mgr) mgr = managers.find((m) => m.role === "admin");
    return mgr ? { name: `${mgr.firstName} ${mgr.lastName}`, phone: mgr.phone, email: mgr.email } : null;
  };

  const data = receipts.map((r) => ({
    ...r,
    managerContact: getManagerForBranch(r.branchId),
  }));

  return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function createReceipt(
  ctx: TenantContext,
  data: { bookingId: string; customerId: string; amount: number; paymentMethod: string; notes?: string },
  actor: string
) {
  const agencyId = ctx.agencyId;
  const booking = await prisma.booking.findFirst({ where: { id: data.bookingId, agencyId } });
  if (!booking) throw ApiError.notFound("Booking");

  const receiptRef = await generateRef("RCP", agencyId);

  const receipt = await prisma.$transaction(async (tx) => {
    const r = await tx.receipt.create({
      data: {
        agencyId,
        receiptRef,
        bookingId: data.bookingId,
        customerId: data.customerId,
        amount: data.amount,
        paymentMethod: data.paymentMethod,
        notes: data.notes || null,
        date: new Date(),
        branchId: booking.branchId,
      },
    });

    const newAmountReceived = (booking.amountReceived || 0) + data.amount;
    const newBalance = Math.max(0, booking.salePrice - newAmountReceived);
    const newPaymentStatus = newBalance === 0 ? "paid" : newAmountReceived > 0 ? "partial" : booking.paymentStatus;

    await tx.booking.update({
      where: { id: data.bookingId },
      data: {
        amountReceived: newAmountReceived,
        balance: newBalance,
        paymentStatus: newPaymentStatus,
      },
    });

    return r;
  });

  if (booking.agentId) {
    try {
      await notificationService.createNotification(ctx, {
        recipientId: booking.agentId,
        title: "Payment Received",
        body: `Receipt ${receiptRef} generated for Booking ${booking.bookingRef} (Amount: ${data.amount})`,
        entityType: "receipt",
        entityId: receipt.id,
        type: "success",
      });
    } catch (e) {
      console.error("Failed to send notification for receipt", e);
    }
  }

  const customer = await prisma.customer.findUnique({ where: { id: data.customerId } });
  await prisma.recentActivity.create({
    data: {
      agencyId,
      type: "receipt",
      title: "Payment received",
      detail: `PKR ${data.amount.toLocaleString()} from ${customer ? `${customer.firstName} ${customer.lastName}` : "Customer"} (${receiptRef})`,
      createdBy: actor,
    },
  });

  await prisma.bookingActivity.create({
    data: {
      agencyId,
      bookingId: booking.id,
      type: "payment",
      title: "Payment Received",
      description: `Received payment of Rs ${data.amount.toLocaleString()} via ${data.paymentMethod} (${receiptRef})`,
      createdBy: actor,
    },
  });

  return receipt;
}

// --- Booking Documents ---

export async function listBookingDocuments(ctx: TenantContext, bookingId: string) {
  return prisma.bookingDocument.findMany({
    where: { agencyId: ctx.agencyId, bookingId },
    orderBy: { createdAt: "desc" },
  });
}

export async function createBookingDocument(
  ctx: TenantContext,
  bookingId: string,
  doc: { name: string; url: string; type: string },
  actor: string
) {
  const booking = await prisma.booking.findFirst({ where: { id: bookingId, agencyId: ctx.agencyId } });
  if (!booking) throw ApiError.notFound("Booking");

  const record = await prisma.bookingDocument.create({
    data: {
      agencyId: ctx.agencyId,
      bookingId,
      name: doc.name,
      url: doc.url,
      type: doc.type,
      uploadedBy: actor,
    },
  });

  await prisma.bookingActivity.create({
    data: {
      agencyId: ctx.agencyId,
      bookingId: booking.id,
      type: "document",
      title: "Document Uploaded",
      description: `Uploaded ${doc.name}`,
      createdBy: actor,
    },
  });

  return record;
}

export async function deleteBookingDocument(ctx: TenantContext, docId: string) {
  const result = await prisma.bookingDocument.deleteMany({ where: { id: docId, agencyId: ctx.agencyId } });
  return result.count > 0;
}

export async function getBookingActivities(ctx: TenantContext, bookingId: string) {
  return prisma.bookingActivity.findMany({
    where: { agencyId: ctx.agencyId, bookingId },
    orderBy: { createdAt: "desc" },
  });
}

// --- Ledger and Statements ---

export async function getCustomerLedger(ctx: TenantContext, customerId: string) {
  const filter = { agencyId: ctx.agencyId, customerId };
  const [customer, bookings, receipts] = await Promise.all([
    prisma.customer.findFirst({ where: filter }),
    prisma.booking.findMany({ where: filter, orderBy: { createdAt: "asc" } }),
    prisma.receipt.findMany({ where: filter, orderBy: { date: "asc" } }),
  ]);

  if (!customer) throw ApiError.notFound("Customer");

  const ledger = [];
  let runningBalance = 0;

  for (const b of bookings) {
    runningBalance += b.salePrice;
    ledger.push({
      date: b.createdAt,
      type: "booking",
      reference: b.bookingRef,
      description: `Booking - ${b.airline} (${b.departureCity} to ${b.arrivalCity})`,
      debit: b.salePrice,
      credit: 0,
      balance: runningBalance,
    });
  }

  for (const r of receipts) {
    runningBalance -= r.amount;
    ledger.push({
      date: r.date,
      type: "receipt",
      reference: r.receiptRef,
      description: `Payment Received - ${r.paymentMethod}`,
      debit: 0,
      credit: r.amount,
      balance: runningBalance,
    });
  }

  ledger.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

  runningBalance = 0;
  for (const entry of ledger) {
    runningBalance += entry.debit;
    runningBalance -= entry.credit;
    entry.balance = runningBalance;
  }

  return { customer, entries: ledger, finalBalance: runningBalance };
}

export async function getSupplierStatement(ctx: TenantContext, supplierId: string) {
  const [supplier, bookings] = await Promise.all([
    prisma.supplier.findFirst({ where: { id: supplierId, agencyId: ctx.agencyId } }),
    prisma.booking.findMany({ where: { agencyId: ctx.agencyId, supplierId }, orderBy: { createdAt: "asc" } }),
  ]);

  if (!supplier) throw ApiError.notFound("Supplier");

  const payments = await prisma.recentActivity.findMany({
    where: { agencyId: ctx.agencyId, type: "payment", title: `Payment to ${supplier.name}` },
    orderBy: { createdAt: "asc" },
  });

  const statement = [];
  let runningBalance = 0;

  for (const b of bookings) {
    statement.push({
      date: b.createdAt,
      type: "booking",
      reference: b.bookingRef,
      description: `Booking - ${b.airline} (${b.departureCity} to ${b.arrivalCity})`,
      debit: 0,
      credit: b.costPrice,
    });
  }

  for (const p of payments) {
    const amountStr = p.detail.split(" ")[1];
    const amount = parseInt(amountStr.replace(/,/g, ""), 10) || 0;
    statement.push({
      date: p.createdAt,
      type: "payment",
      reference: "N/A",
      description: p.detail,
      debit: amount,
      credit: 0,
    });
  }

  statement.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

  for (const entry of statement as any) {
    runningBalance += entry.credit;
    runningBalance -= entry.debit;
    entry.balance = runningBalance;
  }

  return { supplier, entries: statement, finalBalance: runningBalance };
}

export { userDisplayName };
