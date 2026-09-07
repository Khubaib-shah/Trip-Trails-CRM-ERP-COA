import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";
import { calculateServiceFinancials } from "../src/lib/financial-calculator";

const prisma = new PrismaClient();

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS & IDS (MUST BE VALID HEX UUIDs)
// ═══════════════════════════════════════════════════════════════════════════════

const AGENCY_ID = "a1000000-0000-0000-0000-000000000001";

const BR_KHI = "11111111-1111-1111-1111-111111111102";
const BR_PSW = "11111111-1111-1111-1111-111111111104";
const BR_DXB = "11111111-1111-1111-1111-111111111105";

// Roles
const R_ADMIN = "33333333-3333-3333-3333-333333333301";
const R_MANAGER = "33333333-3333-3333-3333-333333333302";
const R_AGENT = "33333333-3333-3333-3333-333333333303";
const R_ACCOUNTANT = "33333333-3333-3333-3333-333333333304";

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

function daysAgo(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(10, 0, 0, 0);
  return d;
}

function randInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randElement<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function generateId(prefix: string, index: number) {
  // prefix is 8 chars, fill rest to 32 chars
  return `${prefix}-0000-0000-0000-${String(index).padStart(12, "0")}`;
}

let jeCount = 0;
let jlGlobalCount = 0;

async function postJournalEntry(params: {
  branchId: string;
  description: string;
  date: Date;
  sourceModule: string;
  sourceId?: string;
  reference?: string;
  lines: { accountId: string; debit: number; credit: number; description?: string; currency?: string }[];
  createdBy: string;
}) {
  const totalDebit = params.lines.reduce((sum, l) => sum + l.debit, 0);
  const totalCredit = params.lines.reduce((sum, l) => sum + l.credit, 0);
  if (Math.abs(totalDebit - totalCredit) > 0.01) {
    throw new Error(`Journal entry lines do not balance: Dr ${totalDebit} != Cr ${totalCredit}`);
  }

  jeCount++;
  const year = params.date.getFullYear();
  const entryNumber = `JE-${year}-${String(jeCount).padStart(4, "0")}`;

  const jeId = generateId("d1000000", jeCount);

  await prisma.journalEntry.create({
    data: {
      id: jeId,
      agencyId: AGENCY_ID,
      branchId: params.branchId,
      entryNumber: entryNumber,
      date: params.date,
      description: params.description,
      reference: params.reference || null,
      sourceModule: params.sourceModule,
      sourceId: params.sourceId || null,
      status: "POSTED",
      createdBy: params.createdBy,
      postedAt: params.date,
      createdAt: params.date,
    },
  });

  const jlCreates = params.lines.map((l) => {
    jlGlobalCount++;
    return {
      id: generateId("e1000000", jlGlobalCount),
      agencyId: AGENCY_ID,
      journalEntryId: jeId,
      accountId: l.accountId,
      debit: l.debit,
      credit: l.credit,
      currency: l.currency || "PKR",
      exchangeRate: 1,
      baseDebit: l.debit,
      baseCredit: l.credit,
      description: l.description || null,
      createdAt: params.date,
    };
  });

  await prisma.journalLine.createMany({ data: jlCreates });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════════

async function main() {
  console.log("Cleaning database...");
  await prisma.journalLine.deleteMany();
  await prisma.journalEntry.deleteMany();
  await prisma.fiscalPeriod.deleteMany();
  await prisma.chartOfAccount.deleteMany();
  await prisma.counter.deleteMany();
  await prisma.paymentAllocation.deleteMany();
  await prisma.customerPayment.deleteMany();
  await prisma.supplierPaymentAllocation.deleteMany();
  await prisma.supplierPayment.deleteMany();
  await prisma.invoiceLine.deleteMany();
  await prisma.invoice.deleteMany();
  await prisma.bookingService.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.quotationItem.deleteMany();
  await prisma.quotation.deleteMany();
  await prisma.leadActivity.deleteMany();
  await prisma.lead.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.supplier.deleteMany();
  await prisma.user.deleteMany();
  await prisma.role.deleteMany();
  await prisma.branch.deleteMany();
  await prisma.agency.deleteMany();

  console.log("Database cleaned. Creating Organization...");

  const password = await bcrypt.hash("Password123!", 10);

  await prisma.agency.create({
    data: {
      id: AGENCY_ID, name: "TripTrails ERP Demo", slug: "triptrails-demo", code: "TTD",
      contactEmail: "demo@triptrails.pk", contactPhone: "+92-300-0000000",
      city: "Karachi", country: "Pakistan", currency: "PKR",
      primaryColor: "#1a56db", emailAlerts: true, smsAlerts: true, dailyReports: true, status: "active"
    }
  });

  await prisma.branch.createMany({
    data: [
      { id: BR_KHI, agencyId: AGENCY_ID, name: "Karachi Branch", code: "KHI", city: "Karachi", currency: "PKR", isHeadOffice: true, status: "active" },
      { id: BR_PSW, agencyId: AGENCY_ID, name: "Peshawar Branch", code: "PSW", city: "Peshawar", currency: "PKR", isHeadOffice: false, status: "active" },
      { id: BR_DXB, agencyId: AGENCY_ID, name: "Dubai Branch", code: "DXB", city: "Dubai", currency: "AED", isHeadOffice: false, status: "active" },
    ]
  });

  await prisma.role.createMany({
    data: [
      { id: R_ADMIN, agencyId: AGENCY_ID, name: "admin", description: "Admin", permissions: ["all"], color: "#dc2626", textColor: "#ffffff" },
      { id: R_MANAGER, agencyId: AGENCY_ID, name: "manager", description: "Mgr", permissions: ["all"], color: "#2563eb", textColor: "#ffffff" },
      { id: R_AGENT, agencyId: AGENCY_ID, name: "agent", description: "Agent", permissions: ["all"], color: "#16a34a", textColor: "#ffffff" },
      { id: R_ACCOUNTANT, agencyId: AGENCY_ID, name: "accountant", description: "Acct", permissions: ["all"], color: "#9333ea", textColor: "#ffffff" },
    ]
  });

  const USERS = {
    OWNER: "22222222-0000-0000-0000-000000000001",
    KHI_MGR: "22222222-0000-0000-0000-000000000002",
    PSW_MGR: "22222222-0000-0000-0000-000000000003",
    DXB_MGR: "22222222-0000-0000-0000-000000000004",
    ACCT: "22222222-0000-0000-0000-000000000005"
  };

  await prisma.user.createMany({
    data: [
      { id: USERS.OWNER, agencyId: AGENCY_ID, branchId: BR_KHI, firstName: "Admin", lastName: "Owner", email: "admin@tt.com", password, role: "admin", status: "active" },
      { id: USERS.KHI_MGR, agencyId: AGENCY_ID, branchId: BR_KHI, firstName: "Karachi", lastName: "Manager", email: "khi@tt.com", password, role: "manager", status: "active" },
      { id: USERS.PSW_MGR, agencyId: AGENCY_ID, branchId: BR_PSW, firstName: "Peshawar", lastName: "Manager", email: "psw@tt.com", password, role: "manager", status: "active" },
      { id: USERS.DXB_MGR, agencyId: AGENCY_ID, branchId: BR_DXB, firstName: "Dubai", lastName: "Manager", email: "dxb@tt.com", password, role: "manager", status: "active" },
      { id: USERS.ACCT, agencyId: AGENCY_ID, branchId: BR_KHI, firstName: "Head", lastName: "Accountant", email: "acct@tt.com", password, role: "accountant", status: "active" },
    ]
  });

  // Chart of Accounts
  console.log("Setting up Chart of Accounts...");
  const COA = {
    CASH_KHI: "c1000000-0000-0000-0000-000000000001",
    BANK_DXB: "c1000000-0000-0000-0000-000000000002",
    AR: "c1000000-0000-0000-0000-000000000003",
    PREPAID_RENT: "c1000000-0000-0000-0000-000000000004",
    AP: "c1000000-0000-0000-0000-000000000005",
    VAT_PAYABLE: "c1000000-0000-0000-0000-000000000006",
    REVENUE: "c1000000-0000-0000-0000-000000000007",
    COST_OF_SALES: "c1000000-0000-0000-0000-000000000008",
    RENT_EXPENSE: "c1000000-0000-0000-0000-000000000009",
  };

  await prisma.chartOfAccount.createMany({
    data: [
      { id: COA.CASH_KHI, agencyId: AGENCY_ID, code: "1001", name: "Cash on Hand KHI", type: "ASSET", normalBalance: "DEBIT", isActive: true },
      { id: COA.BANK_DXB, agencyId: AGENCY_ID, code: "1002", name: "Bank Dubai", type: "ASSET", normalBalance: "DEBIT", isActive: true },
      { id: COA.AR, agencyId: AGENCY_ID, code: "1100", name: "Accounts Receivable", type: "ASSET", normalBalance: "DEBIT", isActive: true },
      { id: COA.PREPAID_RENT, agencyId: AGENCY_ID, code: "1200", name: "Prepaid Rent", type: "ASSET", normalBalance: "DEBIT", isActive: true },
      { id: COA.AP, agencyId: AGENCY_ID, code: "2000", name: "Accounts Payable", type: "LIABILITY", normalBalance: "CREDIT", isActive: true },
      { id: COA.VAT_PAYABLE, agencyId: AGENCY_ID, code: "2100", name: "VAT Payable", type: "LIABILITY", normalBalance: "CREDIT", isActive: true },
      { id: COA.REVENUE, agencyId: AGENCY_ID, code: "4000", name: "Sales Revenue", type: "REVENUE", normalBalance: "CREDIT", isActive: true },
      { id: COA.COST_OF_SALES, agencyId: AGENCY_ID, code: "5000", name: "Cost of Services", type: "EXPENSE", normalBalance: "DEBIT", isActive: true },
      { id: COA.RENT_EXPENSE, agencyId: AGENCY_ID, code: "5100", name: "Rent Expense", type: "EXPENSE", normalBalance: "DEBIT", isActive: true },
    ]
  });

  const SUP = {
    EMIRATES: "44444444-0000-0000-0000-000000000001",
    DXB_HOTEL: "44444444-0000-0000-0000-000000000002",
    UMRAH: "44444444-0000-0000-0000-000000000003",
    SAFARI: "44444444-0000-0000-0000-000000000004",
    QATAR: "44444444-0000-0000-0000-000000000005",
    VISA_KHI: "44444444-0000-0000-0000-000000000006",
  };

  await prisma.supplier.createMany({
    data: [
      { id: SUP.EMIRATES, agencyId: AGENCY_ID, name: "Emirates Airlines", category: "airline", balance: 0, status: "active" },
      { id: SUP.DXB_HOTEL, agencyId: AGENCY_ID, name: "Atlantis Dubai", category: "hotel", balance: 0, status: "active" },
      { id: SUP.UMRAH, agencyId: AGENCY_ID, name: "Makkah Services Group", category: "ground_handler", balance: 0, status: "active" },
      { id: SUP.SAFARI, agencyId: AGENCY_ID, name: "Desert Rose Safari", category: "tour_operator", balance: 0, status: "active" },
      { id: SUP.QATAR, agencyId: AGENCY_ID, name: "Qatar Airways", category: "airline", balance: 0, status: "active" },
      { id: SUP.VISA_KHI, agencyId: AGENCY_ID, name: "Gerrys Visa", category: "visa", balance: 0, status: "active" },
    ]
  });
  
  const suppliersArr = Object.values(SUP);

  console.log("Generating 40 Customers...");
  const firstNames = ["Ali", "Zahid", "John", "Sarah", "Omer", "Tariq", "Fatima", "Ayesha", "Bilal", "Usman", "Hassan", "Zainab", "Kashif", "Waqas"];
  const lastNames = ["Khan", "Ahmed", "Smith", "Malik", "Ali", "Qureshi", "Shafiq", "Mahmood", "Raza", "Iqbal"];
  const customerIds: string[] = [];

  for (let i = 1; i <= 40; i++) {
    const id = generateId("c1000000", i);
    customerIds.push(id);
    await prisma.customer.create({
      data: {
        id, agencyId: AGENCY_ID, customerRef: `CUS-2026-${String(i).padStart(3, "0")}`,
        type: "individual", firstName: randElement(firstNames), lastName: randElement(lastNames),
        phone: `+92300${String(randInt(1000000, 9999999))}`, city: randElement(["Karachi", "Lahore", "Dubai", "Peshawar"]),
        status: "active", createdAt: daysAgo(randInt(30, 60))
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // SCENARIO LOOP: Generate 40 Workflows using Latest Dates (0-30 days ago)
  // ═══════════════════════════════════════════════════════════════════════════════
  console.log("Generating 40 End-to-End Scenarios...");

  const branches = [
    { id: BR_KHI, curr: "PKR", agent: USERS.KHI_MGR, bank: COA.CASH_KHI },
    { id: BR_PSW, curr: "PKR", agent: USERS.PSW_MGR, bank: COA.CASH_KHI },
    { id: BR_DXB, curr: "AED", agent: USERS.DXB_MGR, bank: COA.BANK_DXB },
  ];

  const destinations = ["Dubai", "Makkah", "Istanbul", "London", "Baku", "Male", "Singapore"];
  const titles = ["Holiday Package", "Business Trip", "Umrah Group", "Family Vacation", "Honeymoon Trip"];

  for (let i = 1; i <= 40; i++) {
    const branchInfo = randElement(branches);
    const customerId = randElement(customerIds);
    const dest = randElement(destinations);
    
    // Dates within last 30 days
    const dStart = randInt(10, 30);
    const dMid = dStart - randInt(1, 4);
    const dEnd = dMid - randInt(1, 4);
    
    const leadId = generateId("55555555", i);
    await prisma.lead.create({
      data: {
        id: leadId, agencyId: AGENCY_ID, branchId: branchInfo.id,
        leadRef: `LD-2026-${String(i).padStart(3, "0")}`, name: `${dest} Trip Request`, destination: dest,
        source: "website", status: "converted", assignedAgentId: branchInfo.agent, customerId,
        createdAt: daysAgo(dStart), budget: randInt(100000, 500000), adults: randInt(1, 4), phone: "+920000000000"
      }
    });

    const quoteId = generateId("66666666", i);
    const quoteAmt = randInt(100000, 300000);
    await prisma.quotation.create({
      data: {
        id: quoteId, agencyId: AGENCY_ID, quotationNumber: `QT-2026-${String(i).padStart(3, "0")}`,
        title: randElement(titles), leadId, customerId, branchId: branchInfo.id,
        consultantId: branchInfo.agent, travelType: "leisure", destination: dest,
        subtotal: quoteAmt, agencyFee: 0, discount: 0, taxTotal: quoteAmt * 0.05, total: quoteAmt * 1.05, estimatedProfit: quoteAmt * 0.1,
        status: "accepted", currency: branchInfo.curr, createdAt: daysAgo(dMid)
      }
    });

    const bookingId = generateId("b1000000", i);
    await prisma.booking.create({
      data: {
        id: bookingId, agencyId: AGENCY_ID, bookingRef: `BK-2026-${String(i).padStart(3, "0")}`,
        customerId, branchId: branchInfo.id, agentId: branchInfo.agent,
        leadId, sourceQuotationId: quoteId, sourceType: "quotation", title: randElement(titles),
        departureDate: daysAgo(dEnd - 5), bookingStatus: "confirmed", paymentStatus: "paid", createdAt: daysAgo(dEnd)
      }
    });

    // 1-2 Services per booking
    const numServices = randInt(1, 2);
    let totalSelling = 0;
    let totalTax = 0;
    let totalCustomer = 0;
    let totalCost = 0;

    for (let s = 1; s <= numServices; s++) {
      const cst = randInt(500, 2000) * (branchInfo.curr === "PKR" ? 100 : 1);
      const sel = cst + (cst * 0.15); // 15% margin
      
      const srvData = { 
        costPrice: cst, sellingPrice: sel, 
        taxTreatment: branchInfo.curr === "AED" ? "VAT_ON_SELLING_PRICE" : "VAT_ON_MARGIN", 
        vatRate: 5, supplierInvoiceAmount: cst 
      };
      const srvFin = calculateServiceFinancials(srvData as any);
      
      const randSupplier = randElement(suppliersArr);
      await prisma.bookingService.create({
        data: {
          id: generateId("77777777", (i * 10) + s), agencyId: AGENCY_ID, bookingId, supplierId: randSupplier,
          serviceCategory: s === 1 ? "flight" : "hotel", title: `Service ${s}`, financialStatus: "invoiced",
          ...srvFin, ...srvData, quantity: 1, unit: "Person"
        }
      });
      await prisma.supplier.update({ where: { id: randSupplier }, data: { balance: { increment: srvData.supplierInvoiceAmount } } });
      totalSelling += srvData.sellingPrice;
      totalTax += srvFin.taxAmount;
      totalCustomer += srvFin.customerTotal;
      totalCost += srvData.supplierInvoiceAmount;
    }

    // Invoice
    const invId = generateId("88888888", i);
    await prisma.invoice.create({
      data: {
        id: invId, agencyId: AGENCY_ID, branchId: branchInfo.id, invoiceRef: `INV-2026-${String(i).padStart(3, "0")}`,
        bookingId, customerId, subtotal: totalSelling, tax: totalTax, total: totalCustomer, status: "paid", createdAt: daysAgo(dEnd), paidAt: daysAgo(dEnd - 1)
      }
    });

    // Invoice Journal
    await postJournalEntry({
      branchId: branchInfo.id, date: daysAgo(dEnd), description: `Invoice INV-2026-${String(i).padStart(3, "0")}`, sourceModule: "INVOICE", sourceId: invId, createdBy: USERS.ACCT,
      lines: [
        { accountId: COA.AR, debit: totalCustomer, credit: 0, currency: branchInfo.curr },
        { accountId: COA.REVENUE, debit: 0, credit: totalSelling, currency: branchInfo.curr },
        { accountId: COA.VAT_PAYABLE, debit: 0, credit: totalTax, currency: branchInfo.curr }
      ]
    });

    // Customer Payment
    const cpId = generateId("99999999", i);
    await prisma.customerPayment.create({
      data: {
        id: cpId, agencyId: AGENCY_ID, branchId: branchInfo.id, paymentRef: `CPY-2026-${String(i).padStart(3, "0")}`,
        customerId, bookingId, amount: totalCustomer, paymentMethod: "bank_transfer", date: daysAgo(dEnd - 1), status: "completed", createdAt: daysAgo(dEnd - 1)
      }
    });
    await prisma.paymentAllocation.create({ data: { id: generateId("a1000000", i), agencyId: AGENCY_ID, customerPaymentId: cpId, bookingId, amount: totalCustomer } });

    await postJournalEntry({
      branchId: branchInfo.id, date: daysAgo(dEnd - 1), description: `Customer Payment CPY-2026-${String(i).padStart(3, "0")}`, sourceModule: "CUSTOMER_PAYMENT", sourceId: cpId, createdBy: USERS.ACCT,
      lines: [
        { accountId: branchInfo.bank, debit: totalCustomer, credit: 0, currency: branchInfo.curr },
        { accountId: COA.AR, debit: 0, credit: totalCustomer, currency: branchInfo.curr }
      ]
    });

    // Cost Accrual
    await postJournalEntry({
      branchId: branchInfo.id, date: daysAgo(dEnd), description: `Supplier Cost Accrual BK-2026-${String(i).padStart(3, "0")}`, sourceModule: "BOOKING", sourceId: bookingId, createdBy: USERS.ACCT,
      lines: [
        { accountId: COA.COST_OF_SALES, debit: totalCost, credit: 0, currency: branchInfo.curr },
        { accountId: COA.AP, debit: 0, credit: totalCost, currency: branchInfo.curr }
      ]
    });
    
    // Partially pay supplier half the time
    if (Math.random() > 0.5) {
      const spId = generateId("aaaaa000", i);
      const randSupp = randElement(suppliersArr);
      await prisma.supplierPayment.create({
        data: {
          id: spId, agencyId: AGENCY_ID, branchId: branchInfo.id, supplierId: randSupp,
          paymentRef: `SPY-2026-${String(i).padStart(3, "0")}`, amount: totalCost, paymentMethod: "bank_transfer", date: daysAgo(dEnd - 2), recordedById: USERS.ACCT, createdAt: daysAgo(dEnd - 2)
        }
      });
      await postJournalEntry({
        branchId: branchInfo.id, date: daysAgo(dEnd - 2), description: `Supplier Payment SPY-2026-${String(i).padStart(3, "0")}`, sourceModule: "SUPPLIER_PAYMENT", sourceId: spId, createdBy: USERS.ACCT,
        lines: [
          { accountId: COA.AP, debit: totalCost, credit: 0, currency: branchInfo.curr },
          { accountId: branchInfo.bank, debit: 0, credit: totalCost, currency: branchInfo.curr }
        ]
      });
      await prisma.supplier.update({ where: { id: randSupp }, data: { balance: { decrement: totalCost } } });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // CLOSING & COUNTERS
  // ═══════════════════════════════════════════════════════════════════════════════
  const currentYear = new Date().getFullYear();
  await prisma.counter.createMany({
    data: [
      { id: `BK_${AGENCY_ID}_${currentYear}`, seq: 40 },
      { id: `LD_${AGENCY_ID}_${currentYear}`, seq: 40 },
      { id: `CUS_${AGENCY_ID}_${currentYear}`, seq: 40 },
      { id: `SUP_${AGENCY_ID}_${currentYear}`, seq: 10 },
      { id: `CPY_${AGENCY_ID}_${currentYear}`, seq: 40 },
      { id: `SPY_${AGENCY_ID}_${currentYear}`, seq: 40 },
      { id: `INV_${AGENCY_ID}_${currentYear}`, seq: 40 },
      { id: `QT_${AGENCY_ID}_${currentYear}`, seq: 40 },
    ],
  });

  console.log("Mass Demo seed successfully completed!");
  console.log("Generated 40 end-to-end booking scenarios with balanced journal entries.");
}

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
