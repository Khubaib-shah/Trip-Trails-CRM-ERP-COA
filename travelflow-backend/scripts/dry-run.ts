import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const branches = await prisma.branch.count();
  const branchList = await prisma.branch.findMany({ select: { name: true, id: true, currency: true } });
  const customers = await prisma.customer.count();
  const suppliers = await prisma.supplier.count();
  const bookings = await prisma.booking.count();
  const invoices = await prisma.invoice.count();
  const expenses = await prisma.expense.count();
  const coa = await prisma.chartOfAccount.count();
  const journals = await prisma.journalEntry.count();
  const lines = await prisma.journalLine.count();

  console.log("==== DRY RUN REPORT ====");
  console.log(`Branches: ${branches}`, branchList);
  console.log(`Chart of Accounts: ${coa} (Currently Global)`);
  console.log(`Proposed Branch COAs: ${coa * (branches || 1)}`);
  console.log(`Suppliers: ${suppliers}`);
  console.log(`Customers: ${customers}`);
  console.log(`Bookings: ${bookings}`);
  console.log(`Invoices: ${invoices}`);
  console.log(`Expenses: ${expenses}`);
  console.log(`Journal Entries: ${journals}`);
  console.log(`Journal Lines: ${lines}`);
}

main().catch(console.error).finally(() => prisma.$disconnect());
