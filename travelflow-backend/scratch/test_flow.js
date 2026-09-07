const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { calculateServiceFinancials } = require('./src/lib/financial-calculator');

async function runTest() {
  const agencyId = "a1000000-0000-0000-0000-000000000001";
  const branchId = "11111111-1111-1111-1111-111111111102"; // KHI branch
  
  const customer = await prisma.customer.findFirst({ where: { agencyId } });
  const supplier = await prisma.supplier.findFirst({ where: { agencyId } });
  const user = await prisma.user.findFirst({ where: { agencyId } });

  console.log("Customer:", customer.id);
  console.log("Supplier:", supplier.id);

  // 1. Create Booking
  const booking = await prisma.booking.create({
    data: {
      agencyId,
      branchId,
      customerId: customer.id,
      agentId: user.id,
      bookingRef: "TEST-BK-001",
      departureDate: new Date(),
    }
  });

  console.log("Booking created:", booking.id);

  // 2. Calculate financials for service
  const input = {
    costPrice: 1000,
    sellingPrice: 1200,
    taxTreatment: "VAT_ON_MARGIN",
    vatRate: 5
  };
  const fins = calculateServiceFinancials(input);
  console.log("Financials calculated:", fins);

  // 3. Add Service
  const service = await prisma.bookingService.create({
    data: {
      agencyId,
      bookingId: booking.id,
      supplierId: supplier.id,
      serviceCategory: "flight",
      title: "DXB Flight",
      costPrice: input.costPrice,
      sellingPrice: input.sellingPrice,
      taxTreatment: input.taxTreatment,
      vatRate: input.vatRate,
      taxBase: fins.taxBase,
      taxAmount: fins.taxAmount,
      expectedMargin: fins.expectedMargin,
      actualMargin: fins.actualMargin,
      costVariance: fins.costVariance,
      customerTotal: fins.customerTotal,
      quantity: 1
    }
  });

  console.log("Service created:", service.id);

  // 4. We simulate Invoice Generation (which calls postInvoiceJournal)
  const invoiceSvc = require('./src/services/invoice.service');
  const ctx = { agencyId, branchId, user: { id: user.id }, callerId: user.id };
  
  try {
    const invoice = await invoiceSvc.generateInvoiceFromBooking(ctx, booking.id);
    console.log("Invoice created:", invoice.id);

    // 5. Check Journal Entries
    const je = await prisma.journalEntry.findFirst({
      where: { agencyId, sourceModule: "INVOICE", sourceId: invoice.id },
      include: { lines: { include: { account: true } } }
    });

    if (je) {
      console.log("\\nJournal Entry for Invoice:");
      console.log(je.description);
      je.lines.forEach(l => {
        console.log(\`\${l.debit > 0 ? 'DR' : 'CR'} \${l.account.name} (\${l.account.code}): \${l.debit > 0 ? l.debit : l.credit}\`);
      });
    } else {
      console.log("NO JOURNAL ENTRY FOUND!");
    }
  } catch (err) {
    console.error("Error generating invoice:", err);
  }
}

runTest().catch(console.error).finally(() => prisma.$disconnect());
