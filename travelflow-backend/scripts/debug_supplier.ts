import { prisma } from "../src/lib/prisma";

async function debugSupplier() {
  const suppliers = await prisma.supplier.findMany({
    where: { balance: { not: 0 } },
    include: { payments: true }
  });
  console.log("=== SUPPLIERS WITH BALANCE ===");
  console.log(JSON.stringify(suppliers, null, 2));

  const services = await prisma.bookingService.findMany({
    include: { supplier: true }
  });
  console.log("=== BOOKING SERVICES ===");
  console.log(JSON.stringify(services.map(s => ({
    id: s.id,
    title: s.title,
    category: s.serviceCategory,
    costPrice: s.costPrice,
    supplierInvoiceAmount: s.supplierInvoiceAmount,
    financialStatus: s.financialStatus,
    supplier: s.supplier?.name
  })), null, 2));

  const jes = await prisma.journalEntry.findMany({
    include: { lines: { include: { account: true } } }
  });
  console.log("=== JOURNAL ENTRIES ===");
  for (const je of jes) {
    console.log(`\nEntry: ${je.entryNumber} [${je.sourceModule}] ${je.description}`);
    for (const l of je.lines) {
      console.log(`  [${l.account.code}] ${l.account.name.padEnd(45)} Dr: ${l.debit.toFixed(2).padStart(8)} | Cr: ${l.credit.toFixed(2).padStart(8)}`);
    }
  }
}

debugSupplier()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
