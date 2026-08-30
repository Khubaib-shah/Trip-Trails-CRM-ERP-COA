import { prisma } from "../lib/prisma";
import { TenantContext, PaginationOptions } from "./domain.service";
import { generateRef } from "../utils/refGenerator";
import { ApiError } from "../utils/ApiError";

export async function listInvoices(ctx: TenantContext, pagination?: PaginationOptions) {
  const filter: any = { agencyId: ctx.agencyId, ...(ctx.userBranchId ? { branchId: ctx.userBranchId } : {}) };

  if (!pagination) {
    const data = await prisma.invoice.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      include: { customer: { select: { firstName: true, lastName: true, email: true, phone: true, companyName: true } }, booking: { select: { bookingRef: true } } },
    });
    return { data, total: data.length, page: 1, limit: data.length, totalPages: 1 };
  }

  const { page, limit } = pagination;
  const skip = (page - 1) * limit;

  const [data, total] = await Promise.all([
    prisma.invoice.findMany({
      where: filter,
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      include: { customer: { select: { firstName: true, lastName: true, email: true, phone: true, companyName: true } }, booking: { select: { bookingRef: true } } },
    }),
    prisma.invoice.count({ where: filter }),
  ]);

  return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getInvoice(ctx: TenantContext, id: string) {
  const invoice = await prisma.invoice.findFirst({
    where: { agencyId: ctx.agencyId, id },
    include: {
      customer: { select: { firstName: true, lastName: true, email: true, phone: true, companyName: true, address: true, city: true, country: true } },
      booking: { select: { bookingRef: true, pnr: true, airline: true, departureDate: true, returnDate: true, departureCity: true, arrivalCity: true, amountReceived: true, balance: true } },
    },
  });

  if (!invoice) throw ApiError.notFound("Invoice");

  let branchManager = invoice.branchId
    ? await prisma.user.findFirst({
        where: { agencyId: ctx.agencyId, branchId: invoice.branchId, role: { in: ["manager", "branch_manager", "admin"] } },
      })
    : null;

  if (!branchManager) {
    branchManager = await prisma.user.findFirst({ where: { agencyId: ctx.agencyId, role: "admin" } });
  }

  const managerContact = branchManager
    ? { name: `${branchManager.firstName} ${branchManager.lastName}`, phone: branchManager.phone, email: branchManager.email }
    : null;

  return { ...invoice, managerContact };
}

export async function generateInvoiceFromBooking(ctx: TenantContext, bookingId: string) {
  const booking = await prisma.booking.findFirst({ where: { id: bookingId, agencyId: ctx.agencyId } });
  if (!booking) throw ApiError.notFound("Booking");

  const existing = await prisma.invoice.findFirst({ where: { bookingId: booking.id } });
  if (existing) return existing;

  const invoiceRef = await generateRef("INV", ctx.agencyId);
  return prisma.invoice.create({
    data: {
      agencyId: ctx.agencyId,
      branchId: booking.branchId,
      invoiceRef,
      bookingId: booking.id,
      customerId: booking.customerId,
      subtotal: booking.salePrice,
      tax: 0,
      total: booking.salePrice,
      status: booking.paymentStatus === "paid" ? "paid" : "draft",
      dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      items: {
        create: [{
          agencyId: ctx.agencyId,
          description: `Flight Booking - ${booking.airline} (${booking.departureCity} to ${booking.arrivalCity})`,
          quantity: 1,
          unitPrice: booking.salePrice,
          amount: booking.salePrice,
        }],
      },
    },
  });
}

export async function markInvoicePaid(ctx: TenantContext, id: string) {
  const invoice = await prisma.invoice.findFirst({ where: { id, agencyId: ctx.agencyId } });
  if (!invoice) throw ApiError.notFound("Invoice");
  return prisma.invoice.update({ where: { id }, data: { status: "paid", paidAt: new Date() } });
}
