const fs = require("fs");
const path = require("path");

const servicePath = path.join(__dirname, "../src/services/accounting.service.ts");
let content = fs.readFileSync(servicePath, "utf-8");

const hooksCode = `
// ─── Automated Accounting Hooks ───────────────────────────────────────────────

export async function getAccountByCode(agencyId: string, code: string) {
  const acc = await prisma.chartOfAccount.findFirst({
    where: { agencyId, code, isActive: true }
  });
  if (!acc) throw ApiError.badRequest(\`Missing Account Code: \${code}. Please setup Chart of Accounts.\`);
  return acc;
}

export async function postInvoiceJournal(ctx: AgencyContext, invoiceId: string) {
  const invoice = await prisma.invoice.findFirst({
    where: { id: invoiceId, agencyId: ctx.agencyId },
    include: {
      booking: {
        include: { services: true }
      }
    }
  });
  if (!invoice) throw ApiError.notFound("Invoice");

  // If already posted, skip or reverse. For now, assume it's first time.
  const existing = await prisma.journalEntry.findFirst({
    where: { agencyId: ctx.agencyId, sourceModule: "INVOICE", sourceId: invoiceId }
  });
  if (existing) return existing;

  const ar = await getAccountByCode(ctx.agencyId, "1100");
  const ap = await getAccountByCode(ctx.agencyId, "2000");
  const vat = await getAccountByCode(ctx.agencyId, "2100");
  const rev = await getAccountByCode(ctx.agencyId, "4000");

  let totalAR = 0;
  let totalAP = 0;
  let totalVAT = 0;
  let totalRev = 0;

  for (const svc of invoice.booking.services) {
    const cost = svc.supplierInvoiceAmount ?? svc.costPrice;
    totalAR += (svc.customerTotal ?? svc.sellingPrice);
    totalAP += cost;
    totalVAT += (svc.taxAmount || 0);
    totalRev += (svc.actualMargin ?? svc.expectedMargin ?? (svc.sellingPrice - cost - (svc.taxAmount || 0)));
  }

  // Ensure balance
  const diff = totalAR - (totalAP + totalVAT + totalRev);
  if (Math.abs(diff) > 0.01) {
    // put diff to revenue to balance
    totalRev += diff;
  }

  const lines = [
    { accountId: ar.id, debit: totalAR, credit: 0, description: \`Invoice \${invoice.invoiceNumber}\` },
    { accountId: ap.id, debit: 0, credit: totalAP, description: \`Cost Accrual\` },
    { accountId: vat.id, debit: 0, credit: totalVAT, description: \`Output VAT\` },
    { accountId: rev.id, debit: 0, credit: totalRev, description: \`Agency Margin/Revenue\` },
  ].filter(l => l.debit > 0 || l.credit > 0);

  return postJournalEntry(ctx, {
    description: \`Invoice \${invoice.invoiceNumber} Recognition\`,
    date: invoice.createdAt,
    sourceModule: "INVOICE",
    sourceId: invoiceId,
    reference: invoice.invoiceNumber,
    lines,
    createdBy: ctx.user?.id || ""
  });
}

export async function postCustomerPaymentJournal(ctx: AgencyContext, paymentId: string) {
  const payment = await prisma.customerPayment.findFirst({
    where: { id: paymentId, agencyId: ctx.agencyId }
  });
  if (!payment) throw ApiError.notFound("Payment");

  const existing = await prisma.journalEntry.findFirst({
    where: { agencyId: ctx.agencyId, sourceModule: "CUSTOMER_PAYMENT", sourceId: paymentId }
  });
  if (existing) return existing;

  const cash = await getAccountByCode(ctx.agencyId, "1001"); // using Cash KHI as default
  const ar = await getAccountByCode(ctx.agencyId, "1100");

  return postJournalEntry(ctx, {
    description: \`Payment Received \${payment.paymentRef}\`,
    date: payment.date,
    sourceModule: "CUSTOMER_PAYMENT",
    sourceId: paymentId,
    reference: payment.paymentRef,
    lines: [
      { accountId: cash.id, debit: payment.amount, credit: 0 },
      { accountId: ar.id, debit: 0, credit: payment.amount },
    ],
    createdBy: ctx.user?.id || ""
  });
}

export async function postSupplierPaymentJournal(ctx: AgencyContext, paymentId: string) {
  const payment = await prisma.supplierPayment.findFirst({
    where: { id: paymentId, agencyId: ctx.agencyId }
  });
  if (!payment) throw ApiError.notFound("Payment");

  const existing = await prisma.journalEntry.findFirst({
    where: { agencyId: ctx.agencyId, sourceModule: "SUPPLIER_PAYMENT", sourceId: paymentId }
  });
  if (existing) return existing;

  const cash = await getAccountByCode(ctx.agencyId, "1001");
  const ap = await getAccountByCode(ctx.agencyId, "2000");

  return postJournalEntry(ctx, {
    description: \`Payment to Supplier \${payment.paymentRef}\`,
    date: payment.date,
    sourceModule: "SUPPLIER_PAYMENT",
    sourceId: paymentId,
    reference: payment.paymentRef,
    lines: [
      { accountId: ap.id, debit: payment.amount, credit: 0 },
      { accountId: cash.id, debit: 0, credit: payment.amount },
    ],
    createdBy: ctx.user?.id || ""
  });
}

export async function postSupplierCostJournal(ctx: AgencyContext, bookingServiceId: string) {
  // If actual supplier invoice differs from costPrice, we could post a variance here.
  // We'll leave it as a placeholder for now, as postInvoiceJournal accrues the AP already.
}

`;

fs.writeFileSync(servicePath, content.replace("export {", hooksCode + "export {"));
console.log("Hooks added to accounting.service.ts");
