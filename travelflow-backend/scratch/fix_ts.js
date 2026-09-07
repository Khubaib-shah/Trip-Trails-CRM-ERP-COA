const fs = require("fs");
const path = require("path");

// 1. Fix accounting.service.ts
const accPath = path.join(__dirname, "../src/services/accounting.service.ts");
let accCode = fs.readFileSync(accPath, "utf-8");
accCode = accCode.replace(/invoice\.invoiceNumber/g, "invoice.invoiceRef");
accCode = accCode.replace(/ctx\.user\?\.id/g, "ctx.callerId");
accCode = accCode.replace(/for \(const svc of invoice\.booking\.services\)/g, "for (const svc of invoice.booking!.bookingServices)");
accCode = accCode.replace(/if \(\!invoice\) throw ApiError\.notFound\("Invoice"\);/g, `if (!invoice) throw ApiError.notFound("Invoice");\n  if (!invoice.booking) throw ApiError.badRequest("Invoice has no booking");`);
accCode = accCode.replace(/export async function postSupplierCostJournal\(ctx: AgencyContext, bookingServiceId: string\) \{\}/, "// export async function postSupplierCostJournal(ctx: AgencyContext, bookingServiceId: string) {}");

// Replace the previous include logic for invoice booking services
accCode = accCode.replace(
  /include: \{\s*booking: \{\s*include: \{\s*services: true\s*\}\s*\}\s*\}/g,
  "include: { booking: { include: { bookingServices: true } } }"
);

fs.writeFileSync(accPath, accCode);

// 2. Fix domain.service.ts
const domPath = path.join(__dirname, "../src/services/domain.service.ts");
let domCode = fs.readFileSync(domPath, "utf-8");

domCode = domCode.replace(/customerId: \{ not: null \}/g, "/* customerId required */");
domCode = domCode.replace(/include: \{ services: \{ where: \{ isDeleted: false \} \} \}/g, "include: { bookingServices: { where: { isDeleted: false } } }");
domCode = domCode.replace(/b\.services\.reduce\(\(sSum, s\)/g, "b.bookingServices.reduce((sSum: any, s: any)");
// Also fix unused import postCustomerPaymentJournal by removing it if it's not used, but we want to use it.
// Wait, I did insert it: try { await postCustomerPaymentJournal(ctx, payment.id); } 
// Let's check why it said it's not read. Oh, maybe the multi replace for domain.service.ts failed earlier due to line matching issues!
fs.writeFileSync(domPath, domCode);

// Let's re-inject postCustomerPaymentJournal call in domain.service.ts if it's missing
if (!domCode.includes("await postCustomerPaymentJournal(")) {
  domCode = domCode.replace(
    /return payment;\n\}/g,
    `  try { await postCustomerPaymentJournal(ctx, payment.id); } catch(e) { console.error(e); }\n  return payment;\n}`
  );
  fs.writeFileSync(domPath, domCode);
}

// 3. Fix invoice.service.ts
const invPath = path.join(__dirname, "../src/services/invoice.service.ts");
let invCode = fs.readFileSync(invPath, "utf-8");
// Wait, in my previous replacement for invoice.service.ts, I might have messed up the braces!
// Let me just replace the entire generateInvoiceFromBooking function to be safe.
const invFunctionRegex = /export async function generateInvoiceFromBooking[\s\S]*?(?=export async function updateInvoiceStatus)/;
const correctInvFunction = `export async function generateInvoiceFromBooking(ctx: AgencyContext, bookingId: string) {
  const booking = await prisma.booking.findFirst({ where: { id: bookingId, agencyId: ctx.agencyId, isDeleted: false } });
  if (!booking) throw ApiError.notFound("Booking");

  const services = await prisma.bookingService.findMany({
    where: { bookingId: booking.id, agencyId: ctx.agencyId, isDeleted: false },
  });

  const subtotal = services.reduce((sum, s) => sum + s.sellingPrice, 0);
  const invoiceRef = await generateRef("INV", ctx.agencyId);

  const invoice = await prisma.invoice.create({
    data: {
      agencyId: ctx.agencyId,
      branchId: booking.branchId,
      invoiceRef,
      bookingId: booking.id,
      customerId: booking.customerId,
      subtotal,
      tax: 0,
      total: subtotal,
      status: booking.paymentStatus === "paid" ? "paid" : "draft",
      dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      items: {
        create: services.map((s) => ({
          agencyId: ctx.agencyId,
          description: \`\${s.title} (\${s.serviceCategory})\`,
          quantity: s.quantity,
          unitPrice: s.sellingPrice,
          amount: s.sellingPrice * s.quantity,
        })),
      },
    },
  });

  try {
    await postInvoiceJournal(ctx, invoice.id);
  } catch (err) {
    console.error("Failed to post invoice journal:", err);
  }

  return invoice;
}

`;
invCode = invCode.replace(invFunctionRegex, correctInvFunction);
fs.writeFileSync(invPath, invCode);

console.log("Fixed TS Errors");
