import { prisma } from "../src/lib/prisma";
import * as accounting from "../src/services/accounting.service";

async function applyConfirm() {
  const agency = await prisma.agency.findFirstOrThrow();
  const service = await prisma.bookingService.findFirstOrThrow({
    where: { serviceCategory: "flight" }
  });
  console.log("Found service:", service.title, "costPrice:", service.costPrice);

  const je = await accounting.confirmSupplierInvoice(
    { agencyId: agency.id, userRole: "admin" },
    {
      bookingServiceId: service.id,
      supplierInvoiceAmount: 4050,
      reference: "SUPP-BILL-EK-4050"
    }
  );
  console.log("Posted confirmation JE:", je.entryNumber);

  const accounts = await prisma.chartOfAccount.findMany({
    where: { code: { in: ["2000", "2010", "5000"] } },
    include: { journalLines: true }
  });
  for (const a of accounts) {
    const dr = a.journalLines.reduce((s, l) => s + l.debit, 0);
    const cr = a.journalLines.reduce((s, l) => s + l.credit, 0);
    const bal = a.normalBalance === "DEBIT" ? dr - cr : cr - dr;
    console.log(`[${a.code}] ${a.name.padEnd(45)} Balance: ${bal}`);
  }
}

applyConfirm()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
