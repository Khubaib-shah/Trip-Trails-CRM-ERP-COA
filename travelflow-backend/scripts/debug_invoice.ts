import { prisma } from "../src/lib/prisma";

async function checkInvoice() {
  const invoices = await prisma.invoice.findMany({
    include: { customer: true, booking: true }
  });
  console.log("=== INVOICES IN DB ===");
  console.log(JSON.stringify(invoices, null, 2));

  const users = await prisma.user.findMany({
    select: { id: true, email: true, role: true, branchId: true }
  });
  console.log("=== USERS IN DB ===");
  console.log(JSON.stringify(users, null, 2));

  const branches = await prisma.branch.findMany();
  console.log("=== BRANCHES IN DB ===");
  console.log(JSON.stringify(branches.map(b => ({ id: b.id, name: b.name, code: b.code })), null, 2));
}

checkInvoice()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
