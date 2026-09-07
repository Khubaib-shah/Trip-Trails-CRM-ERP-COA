import { PrismaClient, AccountType, NormalBalance } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

const AGENCY_ID = "a1000000-0000-0000-0000-000000000001";

// ═══════════════════════════════════════════════════════════════════════════════
// COA TEMPLATE
// ═══════════════════════════════════════════════════════════════════════════════
const coaTemplate = [
  { code: "1000", name: "Bank – Current Account", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance, category: "Cash & Bank" },
  { code: "1100", name: "Accounts Receivable – Customers", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance, category: "Receivables" },
  { code: "1250", name: "Input VAT Recoverable", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance, category: "Taxes" },
  { code: "2000", name: "Supplier Estimated", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance, category: "Supplier Liabilities" },
  { code: "2010", name: "Accounts Payable – Suppliers", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance, category: "Supplier Liabilities" },
  { code: "2100", name: "Customer Advances", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance, category: "Customer Liabilities" },
  { code: "2200", name: "Output VAT Payable", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance, category: "Taxes Payable" },
  { code: "3900", name: "Retained Earnings", type: "EQUITY" as AccountType, normal: "CREDIT" as NormalBalance, category: "Equity" },
  { code: "4000", name: "Service Fee Income", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance, category: "Operating Revenue" },
  { code: "4010", name: "Hotel Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance, category: "Operating Revenue" },
  { code: "4020", name: "Ticketing Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance, category: "Operating Revenue" },
  { code: "4030", name: "Package Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance, category: "Operating Revenue" },
  { code: "5000", name: "Cost Variance (Gain)/Loss", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance, category: "Direct Cost" },
  { code: "6000", name: "Rent Expense", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance, category: "Operating Expense" },
  { code: "6410", name: "Bank Charges", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance, category: "Operating Expense" },
];

async function main() {
  console.log("╔══════════════════════════════════════════════╗");
  console.log("║  TripTrails - Branch-Separated Seed Data     ║");
  console.log("╚══════════════════════════════════════════════╝\n");

  console.log("Cleaning existing data...");
  await prisma.journalLine.deleteMany();
  await prisma.journalEntry.deleteMany();
  await prisma.fiscalPeriod.deleteMany();
  await prisma.chartOfAccount.deleteMany();
  await prisma.counter.deleteMany();
  await prisma.bookingService.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.invoiceLine.deleteMany();
  await prisma.invoice.deleteMany();
  await prisma.supplierPayment.deleteMany();
  await prisma.customerPayment.deleteMany();
  await prisma.expense.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.supplier.deleteMany();
  await prisma.user.deleteMany();
  await prisma.role.deleteMany();
  await prisma.branch.deleteMany();
  await prisma.agency.deleteMany();

  console.log("Creating Agency...");
  await prisma.agency.create({
    data: {
      id: AGENCY_ID, name: "TripTrails HQ", slug: "triptrails", code: "TT",
      contactEmail: "info@triptrails.com", contactPhone: "+97100000000", city: "Dubai",
      currency: "AED",
    }
  });

  const branchDefs = [
    { id: "11111111-1111-1111-1111-111111111101", name: "Lahore Head Office", code: "LHE", city: "Lahore", currency: "PKR" },
    { id: "11111111-1111-1111-1111-111111111102", name: "Karachi Branch", code: "KHI", city: "Karachi", currency: "PKR" },
    { id: "11111111-1111-1111-1111-111111111105", name: "Dubai Branch", code: "DXB", city: "Dubai", currency: "AED" },
  ];

  console.log("Seeding Branches and Branch-Specific Data...");
  const hashedPassword = await bcrypt.hash("Password123!", 10);

  for (let idx = 0; idx < branchDefs.length; idx++) {
    const b = branchDefs[idx];
    const uuidSuffix = String(idx + 1).padStart(3, '0');
    console.log(`\n---> Initializing ${b.name} (${b.currency})...`);
    
    // 1. Branch
    await prisma.branch.create({
      data: { id: b.id, agencyId: AGENCY_ID, name: b.name, code: b.code, city: b.city, currency: b.currency, isHeadOffice: b.code === "LHE" }
    });

    // 2. User
    const userId = `22222222-2222-2222-2222-2222222222${b.code === "LHE" ? "01" : b.code === "KHI" ? "02" : "05"}`;
    await prisma.user.create({
      data: {
        id: userId, agencyId: AGENCY_ID, branchId: b.id,
        firstName: "Manager", lastName: b.code, email: `manager@${b.code.toLowerCase()}.triptrails.com`,
        password: hashedPassword, role: "manager"
      }
    });

    // 3. Chart of Accounts (Branch-Isolated)
    for (const acc of coaTemplate) {
      await prisma.chartOfAccount.create({
        data: {
          agencyId: AGENCY_ID, branchId: b.id,
          code: acc.code, name: acc.name, type: acc.type, normalBalance: acc.normal,
          category: acc.category, isSystem: true, isActive: true
        }
      });
    }

    // 4. Customers
    const custId = `c0000000-0000-0000-0000-000000000${uuidSuffix}`;
    await prisma.customer.create({
      data: {
        id: custId, agencyId: AGENCY_ID, branchId: b.id, customerRef: `CUST-${b.code}-001`,
        type: "individual", firstName: "Test", lastName: `Customer ${b.code}`, phone: "+123456789"
      }
    });

    // 5. Suppliers
    const suppId = `44444444-4444-4444-4444-444444444${uuidSuffix}`;
    await prisma.supplier.create({
      data: {
        id: suppId, agencyId: AGENCY_ID, branchId: b.id,
        name: `Emirates Airlines (${b.code})`, category: "Airlines", balance: 0
      }
    });

    // 6. Basic Transaction (Expense)
    const expenseId = `55555555-5555-5555-5555-555555555${uuidSuffix}`;
    await prisma.expense.create({
      data: {
        id: expenseId, agencyId: AGENCY_ID, branchId: b.id, expenseRef: `EXP-${b.code}-001`,
        title: `Rent ${b.code}`, category: "Rent", amount: 5000, currency: b.currency, exchangeRate: 1.0,
        date: new Date(), paymentMethod: "cash", recordedById: userId, status: "approved"
      }
    });

    console.log(`     Created COA, Customer, Supplier, and Expense for ${b.code}`);
  }

  console.log("\nSeed completed successfully.");
}

main().catch(console.error).finally(() => prisma.$disconnect());
