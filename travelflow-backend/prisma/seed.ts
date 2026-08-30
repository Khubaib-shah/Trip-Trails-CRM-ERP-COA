import { PrismaClient, AccountType, NormalBalance } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

const AGENCY_ID = "a1000000-0000-0000-0000-000000000001";

// Branch IDs
const BR_HO = "11111111-1111-1111-1111-111111111101";
const BR_KHI = "11111111-1111-1111-1111-111111111102";
const BR_ISB = "11111111-1111-1111-1111-111111111103";
const BR_PSW = "11111111-1111-1111-1111-111111111104";
const BR_DXB = "11111111-1111-1111-1111-111111111105";

// User IDs
const U_OWNER = "22222222-2222-2222-2222-222222222201";
const U_MANAGER_HO = "22222222-2222-2222-2222-222222222202";
const U_MANAGER_KHI = "22222222-2222-2222-2222-222222222203";
const U_MANAGER_DXB = "22222222-2222-2222-2222-222222222204";
const U_AGENT1 = "22222222-2222-2222-2222-222222222205";
const U_AGENT2 = "22222222-2222-2222-2222-222222222206";
const U_AGENT3 = "22222222-2222-2222-2222-222222222207";
const U_AGENT4 = "22222222-2222-2222-2222-222222222208";
const U_AGENT5 = "22222222-2222-2222-2222-222222222209";
const U_AGENT6 = "22222222-2222-2222-2222-222222222210";
const U_ACCT = "22222222-2222-2222-2222-222222222211";

// Role IDs
const R_ADMIN = "33333333-3333-3333-3333-333333333301";
const R_MANAGER = "33333333-3333-3333-3333-333333333302";
const R_AGENT = "33333333-3333-3333-3333-333333333303";
const R_ACCOUNTANT = "33333333-3333-3333-3333-333333333304";

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS - Dynamic dates so seed is always current
// ═══════════════════════════════════════════════════════════════════════════════

function uuid(prefix: string, n: number): string {
  const hex = String(n).padStart(12, "0");
  return `${prefix}${hex}-0000-0000-0000-000000000001`;
}

function daysAgo(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(9 + Math.floor(Math.random() * 9), Math.floor(Math.random() * 60), 0, 0);
  return d;
}

function daysFromNow(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() + n);
  d.setHours(10, 0, 0, 0);
  return d;
}

function monthsAgo(n: number): Date {
  const d = new Date();
  d.setMonth(d.getMonth() - n);
  d.setDate(1 + Math.floor(Math.random() * 28));
  d.setHours(9 + Math.floor(Math.random() * 9), Math.floor(Math.random() * 60), 0, 0);
  return d;
}

function randomBetween(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SEED
// ═══════════════════════════════════════════════════════════════════════════════

async function main() {
  console.log("╔══════════════════════════════════════════════╗");
  console.log("║  TripTrails Travel Agency - Full Seed        ║");
  console.log("║  4 Branches | 1 Year of Data                 ║");
  console.log("╚══════════════════════════════════════════════╝\n");

  // Clean existing data in FK-safe order
  console.log("Cleaning existing data...");
  await prisma.journalLine.deleteMany();
  await prisma.journalEntry.deleteMany();
  await prisma.fiscalPeriod.deleteMany();
  await prisma.chartOfAccount.deleteMany();
  await prisma.counter.deleteMany();
  await prisma.recentActivity.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.template.deleteMany();
  await prisma.invoiceLine.deleteMany();
  await prisma.invoice.deleteMany();
  await prisma.receipt.deleteMany();
  await prisma.quotationVersion.deleteMany();
  await prisma.quotationTax.deleteMany();
  await prisma.quotationItem.deleteMany();
  await prisma.quotationAttachment.deleteMany();
  await prisma.quotation.deleteMany();
  await prisma.bookingDocument.deleteMany();
  await prisma.bookingActivity.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.expense.deleteMany();
  await prisma.leadActivity.deleteMany();
  await prisma.lead.deleteMany();
  await prisma.customerDocument.deleteMany();
  await prisma.customerNote.deleteMany();
  await prisma.customer.deleteMany();
  await prisma.supplierPayment.deleteMany();
  await prisma.supplier.deleteMany();
  await prisma.user.deleteMany();
  await prisma.role.deleteMany();
  await prisma.branch.deleteMany();
  await prisma.agency.deleteMany();
  console.log("Data cleaned.\n");

  const password = await bcrypt.hash("Password123!", 12);

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. AGENCY
  // ═══════════════════════════════════════════════════════════════════════════
  await prisma.agency.create({
    data: {
      id: AGENCY_ID,
      name: "TripTrails Travel & Tourism",
      slug: "triptrails-01",
      code: "TT",
      contactEmail: "info@triptrails.pk",
      contactPhone: "+92-42-35789012",
      address: "G-64, Al Latif Center, Main Boulevard, Gulberg III",
      city: "Lahore",
      country: "Pakistan",
      currency: "PKR",
      registrationNo: "SECP-TRAILS-2014",
      primaryColor: "#1a56db",
      emailAlerts: true,
      smsAlerts: true,
      dailyReports: true,
      status: "active",
    },
  });
  console.log("Agency: TripTrails Travel & Tourism");

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. BRANCHES (5 total: Lahore HQ, Karachi, Islamabad, Peshawar, Dubai)
  // ═══════════════════════════════════════════════════════════════════════════
  await prisma.branch.createMany({
    data: [
      {
        id: BR_HO, agencyId: AGENCY_ID,
        name: "Lahore Head Office", code: "LHE",
        city: "Lahore",
        address: "G-64, Al Latif Center, Main Boulevard, Gulberg III, Lahore",
        phone: "+92-42-35789012",
        isHeadOffice: true, status: "active",
      },
      {
        id: BR_KHI, agencyId: AGENCY_ID,
        name: "Karachi Branch", code: "KHI",
        city: "Karachi",
        address: "Shop # G-11, Al-Haq Pride, Opp. Madinah Masjid, Block 13-D/1, Gulshan-e-Iqbal",
        phone: "+92-21-34891234",
        isHeadOffice: false, status: "active",
      },
      {
        id: BR_ISB, agencyId: AGENCY_ID,
        name: "Islamabad Branch", code: "ISB",
        city: "Islamabad",
        address: "Office 305, 3rd Floor, Sahara Mall, F-7 Markaz, Islamabad",
        phone: "+92-51-2654321",
        isHeadOffice: false, status: "active",
      },
      {
        id: BR_PSW, agencyId: AGENCY_ID,
        name: "Peshawar Branch", code: "PSW",
        city: "Peshawar",
        address: "UG 350, Deans Trade Center, Peshawar",
        phone: "+92-91-5701234",
        isHeadOffice: false, status: "active",
      },
      {
        id: BR_DXB, agencyId: AGENCY_ID,
        name: "Dubai Branch", code: "DXB",
        city: "Dubai",
        address: "Office #103, 1st Floor, Al Fajar Complex, Near Oud Metha Bus Station, Dubai, UAE",
        phone: "+971-4-3301234",
        isHeadOffice: false, status: "active",
      },
    ],
  });
  console.log("Branches: 5 (Lahore HQ, Karachi, Islamabad, Peshawar, Dubai)");

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. ROLES
  // ═══════════════════════════════════════════════════════════════════════════
  await prisma.role.createMany({
    data: [
      {
        id: R_ADMIN, agencyId: AGENCY_ID, name: "admin", description: "Full system access - agency owner",
        permissions: ["all"],
        color: "#dc2626", textColor: "#ffffff",
      },
      {
        id: R_MANAGER, agencyId: AGENCY_ID, name: "manager", description: "Branch manager - full branch access",
        permissions: [
          "Bookings: View", "Bookings: Create", "Bookings: Edit", "Bookings: Delete",
          "Customers: View", "Customers: Create", "Customers: Edit", "Customers: Delete",
          "Leads: View", "Leads: Create", "Leads: Edit", "Leads: Delete",
          "Expenses: View", "Expenses: Create", "Expenses: Edit", "Expenses: Delete",
          "Quotations: View", "Quotations: Create", "Quotations: Edit", "Quotations: Delete",
          "Invoices: View", "Invoices: Create", "Invoices: Edit",
          "Receipts: View", "Receipts: Create", "Receipts: Edit",
          "Suppliers: View", "Suppliers: Create", "Suppliers: Edit", "Suppliers: Delete",
          "Branches: View", "Branches: Edit",
          "Users: View", "Users: Create", "Users: Edit",
          "Reports: View", "Reports: Export",
          "Settings: View", "Settings: Edit",
          "Templates: View", "Templates: Create", "Templates: Edit", "Templates: Delete",
          "Roles: View", "Roles: Edit",
        ],
        color: "#2563eb", textColor: "#ffffff",
      },
      {
        id: R_AGENT, agencyId: AGENCY_ID, name: "agent", description: "Travel agent - booking and customer access",
        permissions: [
          "Bookings: View", "Bookings: Create", "Bookings: Edit",
          "Customers: View", "Customers: Create", "Customers: Edit",
          "Leads: View", "Leads: Create", "Leads: Edit",
          "Quotations: View", "Quotations: Create", "Quotations: Edit",
          "Invoices: View",
          "Receipts: View", "Receipts: Create",
          "Suppliers: View",
        ],
        color: "#16a34a", textColor: "#ffffff",
      },
      {
        id: R_ACCOUNTANT, agencyId: AGENCY_ID, name: "accountant", description: "Financial and accounting access",
        permissions: [
          "Bookings: View", "Customers: View", "Leads: View",
          "Expenses: View", "Expenses: Create", "Expenses: Edit",
          "Invoices: View", "Invoices: Create", "Invoices: Edit",
          "Receipts: View", "Receipts: Create", "Receipts: Edit",
          "Suppliers: View", "Suppliers: Edit",
          "Reports: View", "Reports: Export",
        ],
        color: "#9333ea", textColor: "#ffffff",
      },
    ],
  });
  console.log("Roles: 4 (admin, manager, agent, accountant)");

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. USERS / STAFF (11 total)
  // ═══════════════════════════════════════════════════════════════════════════
  await prisma.user.createMany({
    data: [
      // Owner / Admin
      { id: U_OWNER, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Bilal", lastName: "Ahmed", email: "owner@triptrails.pk", password, phone: "+92-300-1234567", role: "admin", status: "active" },
      // Branch Managers
      { id: U_MANAGER_HO, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Sara", lastName: "Khan", email: "sara@triptrails.pk", password, phone: "+92-321-2345678", role: "manager", status: "active" },
      { id: U_MANAGER_KHI, agencyId: AGENCY_ID, branchId: BR_KHI, firstName: "Ahmed", lastName: "Raza", email: "ahmed.razatr@triptrails.pk", password, phone: "+92-300-9876543", role: "manager", status: "active" },
      { id: U_MANAGER_DXB, agencyId: AGENCY_ID, branchId: BR_DXB, firstName: "Omar", lastName: "Farooq", email: "omar@triptrails.pk", password, phone: "+971-50-1234567", role: "manager", status: "active" },
      // Travel Agents
      { id: U_AGENT1, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Ayesha", lastName: "Malik", email: "agent1@triptrails.pk", password, phone: "+92-333-3456789", role: "agent", status: "active" },
      { id: U_AGENT2, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Hassan", lastName: "Raza", email: "hassan@triptrails.pk", password, phone: "+92-345-4567890", role: "agent", status: "active" },
      { id: U_AGENT3, agencyId: AGENCY_ID, branchId: BR_DXB, firstName: "Fatima", lastName: "Hussain", email: "fatima@triptrails.pk", password, phone: "+971-55-9876543", role: "agent", status: "active" },
      { id: U_AGENT4, agencyId: AGENCY_ID, branchId: BR_KHI, firstName: "Usman", lastName: "Ali", email: "usman@triptrails.pk", password, phone: "+92-300-5678901", role: "agent", status: "active" },
      { id: U_AGENT5, agencyId: AGENCY_ID, branchId: BR_ISB, firstName: "Zain", lastName: "Shah", email: "zain@triptrails.pk", password, phone: "+92-312-1112233", role: "agent", status: "active" },
      { id: U_AGENT6, agencyId: AGENCY_ID, branchId: BR_PSW, firstName: "Farah", lastName: "Noor", email: "farah@triptrails.pk", password, phone: "+92-345-9988776", role: "agent", status: "active" },
      // Accountant
      { id: U_ACCT, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Zainab", lastName: "Noor", email: "zainab@triptrails.pk", password, phone: "+92-312-6789012", role: "accountant", status: "active" },
    ],
  });
  console.log("Users: 11 (1 owner, 3 managers, 6 agents, 1 accountant)");

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. CUSTOMERS (40 - realistic Pakistani & UAE names)
  // ═══════════════════════════════════════════════════════════════════════════
  const customerData = [
    { fn: "Ahmed", ln: "Khan", phone: "+92-321-1111111", email: "ahmed.khan@gmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "AK1234567", company: null },
    { fn: "Fatima", ln: "Zahra", phone: "+92-333-2222222", email: "fatima.z@outlook.com", city: "Islamabad", country: "Pakistan", type: "individual" as const, passport: "FZ2345678", company: null },
    { fn: "Muhammad", ln: "Ali", phone: "+92-345-3333333", email: "mali@yahoo.com", city: "Lahore", country: "Pakistan", type: "corporate" as const, passport: "MA3456789", company: "Ali & Sons Trading" },
    { fn: "Sobia", ln: "Aslam", phone: "+92-300-4444444", email: "sobia.aslam@gmail.com", city: "Karachi", country: "Pakistan", type: "individual" as const, passport: "SA4567890", company: null },
    { fn: "Tariq", ln: "Mahmood", phone: "+971-50-5555555", email: "tariq.m@hotmail.com", city: "Dubai", country: "UAE", type: "corporate" as const, passport: "TM5678901", company: "Mahmood Holdings LLC" },
    { fn: "Nadia", ln: "Pervez", phone: "+92-321-6666666", email: "nadia.p@gmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "NP6789012", company: null },
    { fn: "Imran", ln: "Sheikh", phone: "+92-333-7777777", email: "imran.s@outlook.com", city: "Faisalabad", country: "Pakistan", type: "individual" as const, passport: "IS7890123", company: null },
    { fn: "Amina", ln: "Rashid", phone: "+971-55-8888888", email: "amina.r@gmail.com", city: "Dubai", country: "UAE", type: "individual" as const, passport: "AR8901234", company: null },
    { fn: "Kamran", ln: "Butt", phone: "+92-345-9999999", email: "kamran.b@yahoo.com", city: "Lahore", country: "Pakistan", type: "corporate" as const, passport: "KB9012345", company: "Butt Enterprises" },
    { fn: "Hira", ln: "Saleem", phone: "+92-300-1010101", email: "hira.saleem@gmail.com", city: "Rawalpindi", country: "Pakistan", type: "individual" as const, passport: "HS0123456", company: null },
    { fn: "Danish", ln: "Iqbal", phone: "+92-321-2020202", email: "danish.i@hotmail.com", city: "Sialkot", country: "Pakistan", type: "individual" as const, passport: "DI1234098", company: null },
    { fn: "Mehreen", ln: "Baig", phone: "+971-50-3030303", email: "mehreen.b@gmail.com", city: "Abu Dhabi", country: "UAE", type: "individual" as const, passport: "MB2345098", company: null },
    { fn: "Saad", ln: "Nawaz", phone: "+92-333-4040404", email: "saad.n@outlook.com", city: "Multan", country: "Pakistan", type: "corporate" as const, passport: "SN3456098", company: "Nawaz Group" },
    { fn: "Rabia", ln: "Chaudhry", phone: "+92-345-5050505", email: "rabia.c@gmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "RC4567098", company: null },
    { fn: "Faisal", ln: "Warraich", phone: "+92-300-6060606", email: "faisal.w@yahoo.com", city: "Gujranwala", country: "Pakistan", type: "individual" as const, passport: "FW5678098", company: null },
    { fn: "Aisha", ln: "Parveen", phone: "+92-321-7070707", email: "aisha.p@gmail.com", city: "Peshawar", country: "Pakistan", type: "individual" as const, passport: "AP6789012", company: null },
    { fn: "Bilal", ln: "Ahmed", phone: "+92-333-8080808", email: "bilal.ah@gmail.com", city: "Karachi", country: "Pakistan", type: "individual" as const, passport: "BA7890123", company: null },
    { fn: "Sana", ln: "Ullah", phone: "+971-55-9090909", email: "sana.u@hotmail.com", city: "Sharjah", country: "UAE", type: "individual" as const, passport: "SU8901234", company: null },
    { fn: "Waqas", ln: "Javed", phone: "+92-345-1111212", email: "waqas.j@gmail.com", city: "Peshawar", country: "Pakistan", type: "individual" as const, passport: "WJ9012345", company: null },
    { fn: "Nazia", ln: "Irfan", phone: "+92-300-2222323", email: "nazia.i@outlook.com", city: "Islamabad", country: "Pakistan", type: "individual" as const, passport: "NI0123456", company: null },
    { fn: "Adnan", ln: "Shah", phone: "+971-50-3333434", email: "adnan.s@gmail.com", city: "Dubai", country: "UAE", type: "corporate" as const, passport: "AS1234567", company: "Shah Trading Co" },
    { fn: "Mariam", ln: "Zubair", phone: "+92-321-4444545", email: "mariam.z@yahoo.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "MZ2345678", company: null },
    { fn: "Asif", ln: "Javed", phone: "+971-55-5555656", email: "asif.j@hotmail.com", city: "Dubai", country: "UAE", type: "individual" as const, passport: "AJ3456789", company: null },
    { fn: "Bushra", ln: " Bibi", phone: "+92-333-6666767", email: "busbra.b@gmail.com", city: "Karachi", country: "Pakistan", type: "individual" as const, passport: "BB4567890", company: null },
    { fn: "Hamza", ln: "Malik", phone: "+92-345-7777878", email: "hamza.m@outlook.com", city: "Rawalpindi", country: "Pakistan", type: "individual" as const, passport: "HM5678901", company: null },
    { fn: "Rida", ln: "Hussain", phone: "+971-50-8888989", email: "rida.h@gmail.com", city: "Ajman", country: "UAE", type: "individual" as const, passport: "RH6789012", company: null },
    { fn: "Omar", ln: "Khalid", phone: "+92-300-9999090", email: "omar.k@yahoo.com", city: "Peshawar", country: "Pakistan", type: "individual" as const, passport: "OK7890123", company: null },
    { fn: "Yasmin", ln: "Rashid", phone: "+92-321-1010111", email: "yasmin.r@gmail.com", city: "Islamabad", country: "Pakistan", type: "individual" as const, passport: "YR8901234", company: null },
    { fn: "Taimoor", ln: "Baig", phone: "+971-55-2121212", email: "taimoor.b@hotmail.com", city: "Dubai", country: "UAE", type: "corporate" as const, passport: "TB9012345", company: "Baig International" },
    { fn: "Sidra", ln: "Ismail", phone: "+92-333-3232323", email: "sidra.i@outlook.com", city: "Multan", country: "Pakistan", type: "individual" as const, passport: "SI0123456", company: null },
    { fn: "Kashif", ln: "Naveed", phone: "+92-345-4343434", email: "kashif.n@gmail.com", city: "Sialkot", country: "Pakistan", type: "individual" as const, passport: "KN1234567", company: null },
    { fn: "Naima", ln: "Qureshi", phone: "+971-50-5454545", email: "naima.q@yahoo.com", city: "Dubai", country: "UAE", type: "individual" as const, passport: "NQ2345678", company: null },
    { fn: "Shahid", ln: "Afridi", phone: "+92-300-6565656", email: "shahid.a@gmail.com", city: "Peshawar", country: "Pakistan", type: "individual" as const, passport: "SA3456789", company: null },
    { fn: "Hina", ln: "Waseem", phone: "+92-321-7676767", email: "hina.w@hotmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "HW4567890", company: null },
    { fn: "Fahad", ln: "Iqbal", phone: "+971-55-8787878", email: "fahad.i@outlook.com", city: "Sharjah", country: "UAE", type: "individual" as const, passport: "FI5678901", company: null },
    { fn: "Ayesha", ln: " Siddiqui", phone: "+92-333-9898989", email: "asiddiqui@gmail.com", city: "Karachi", country: "Pakistan", type: "individual" as const, passport: "AS6789012", company: null },
    { fn: "Daniyal", ln: "Saleem", phone: "+92-345-0909090", email: "daniyal.s@yahoo.com", city: "Faisalabad", country: "Pakistan", type: "individual" as const, passport: "DS7890123", company: null },
    { fn: "Mahira", ln: "Khan", phone: "+971-50-1010101", email: "mahira.k@gmail.com", city: "Abu Dhabi", country: "UAE", type: "individual" as const, passport: "MK8901234", company: null },
    { fn: "Usama", ln: "Tariq", phone: "+92-300-2121212", email: "usama.t@outlook.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "UT9012345", company: null },
    { fn: "Zara", ln: "Ahmed", phone: "+92-321-3232323", email: "zara.a@hotmail.com", city: "Islamabad", country: "Pakistan", type: "individual" as const, passport: "ZA0123456", company: null },
  ];

  const custIds: string[] = [];
  for (let i = 0; i < customerData.length; i++) {
    const c = customerData[i];
    const cid = `4${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    custIds.push(cid);
    await prisma.customer.create({
      data: {
        id: cid, agencyId: AGENCY_ID,
        customerRef: `CUS-${new Date().getFullYear()}-${String(i + 1).padStart(3, "0")}`,
        type: c.type, firstName: c.fn, lastName: c.ln,
        email: c.email, phone: c.phone, city: c.city, country: c.country,
        passportNumber: c.passport, companyName: c.company,
        gender: i % 3 === 0 ? "male" : i % 3 === 1 ? "female" : "male",
        dateOfBirth: new Date(1978 + (i % 22), (i * 3) % 12, 1 + (i % 28)),
        internalNotes: i % 5 === 0 ? "VIP customer - priority handling" : i % 7 === 0 ? "Corporate account - monthly billing" : null,
        createdAt: monthsAgo(11 - Math.floor(i / 4)),
      },
    });
  }
  console.log(`Customers: ${customerData.length}`);

  // Customer notes (spread across different customers)
  const customerNotes: { agencyId: string; customerId: string; note: string; addedBy: string; createdAt: Date }[] = [];
  const noteTexts = [
    "Prefers direct flights. Always travels business class.",
    "Family trip to Europe planned for December.",
    "First-time international traveler. Needs visa assistance.",
    "Corporate account - monthly billing. Net 30 terms.",
    "Frequently travels to London and Singapore.",
    "Prefers Emirates and Singapore Airlines.",
    "Honeymoon trip to Maldives. Budget flexible.",
    "Company retreat - 25 pax to Northern Areas.",
    "Family of 4. Travels twice a year.",
    "Recently relocated to Dubai. Needs Umrah package.",
    "Frequent traveler - VIP lounge access required.",
    "Group booking for wedding party - 12 people.",
    "Student visa inquiry for UK universities.",
    "Annual family vacation - Europe preferred.",
    "Business class only - Emirates preferred.",
  ];
  for (let i = 0; i < noteTexts.length; i++) {
    customerNotes.push({
      agencyId: AGENCY_ID,
      customerId: custIds[i % custIds.length],
      note: noteTexts[i],
      addedBy: pick(["Sara Khan", "Ayesha Malik", "Hassan Raza", "Omar Farooq"]),
      createdAt: daysAgo(randomBetween(10, 340)),
    });
  }
  await prisma.customerNote.createMany({ data: customerNotes });
  console.log(`Customer notes: ${customerNotes.length}`);

  // Customer documents
  const custDocs: { agencyId: string; customerId: string; documentType: string; fileName: string; fileSize: number; mimeType: string; fileUrl: string; uploadedBy: string }[] = [];
  for (let i = 0; i < 15; i++) {
    custDocs.push({
      agencyId: AGENCY_ID, customerId: custIds[i],
      documentType: i % 3 === 0 ? "cnic" : "passport",
      fileName: `${customerData[i].fn.toLowerCase()}_${i % 3 === 0 ? "cnic" : "passport"}.pdf`,
      fileSize: randomBetween(150000, 400000),
      mimeType: "application/pdf",
      fileUrl: `/uploads/customers/${customerData[i].fn.toLowerCase()}_${i % 3 === 0 ? "cnic" : "passport"}.pdf`,
      uploadedBy: pick(["Sara Khan", "Ayesha Malik", "Hassan Raza"]),
    });
  }
  await prisma.customerDocument.createMany({ data: custDocs });
  console.log(`Customer documents: ${custDocs.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. SUPPLIERS
  // ═══════════════════════════════════════════════════════════════════════════
  const supplierData = [
    { name: "PIA - Pakistan International Airlines", category: "airline", contact: "Reservations Desk", phone: "+92-21-111786786", city: "Karachi", country: "Pakistan" },
    { name: "Airblue", category: "airline", contact: "Trade Desk", phone: "+92-21-111247247", city: "Karachi", country: "Pakistan" },
    { name: "Emirates Airlines", category: "airline", contact: "Corporate Sales", phone: "+971-600-555555", city: "Dubai", country: "UAE" },
    { name: "Serena Hotels Pakistan", category: "hotel", contact: "Group Bookings", phone: "+92-51-2878070", city: "Islamabad", country: "Pakistan" },
    { name: "Pearl Continental Hotels", category: "hotel", contact: "MICE Desk", phone: "+92-42-35781000", city: "Lahore", country: "Pakistan" },
    { name: "Saudi Travel Agency", category: "ground_handler", contact: "Hajj/Umrah Desk", phone: "+966-11-2654321", city: "Jeddah", country: "Saudi Arabia" },
    { name: "VisaMaster Consultants", category: "visa_agent", contact: "Processing Team", phone: "+92-42-35678901", city: "Lahore", country: "Pakistan" },
    { name: "TravelGuard Insurance", category: "insurance", contact: "Policy Sales", phone: "+92-42-34567890", city: "Lahore", country: "Pakistan" },
    { name: "Air Arabia", category: "airline", contact: "Trade Relations", phone: "+971-600-566666", city: "Sharjah", country: "UAE" },
    { name: "Thai Airways", category: "airline", contact: "Pakistan Office", phone: "+92-21-34567890", city: "Karachi", country: "Pakistan" },
    { name: "Marriott Hotels Pakistan", category: "hotel", contact: "Group Sales", phone: "+92-51-2826826", city: "Islamabad", country: "Pakistan" },
    { name: "Zowaa Tours & Travels", category: "ground_handler", contact: "Operations", phone: "+92-51-4445566", city: "Islamabad", country: "Pakistan" },
    { name: "Allianz Insurance Pakistan", category: "insurance", contact: "Corporate Sales", phone: "+92-21-35678901", city: "Karachi", country: "Pakistan" },
    { name: "Turkish Airlines", category: "airline", contact: "GSA Pakistan", phone: "+92-21-34567891", city: "Karachi", country: "Pakistan" },
    { name: "Hunza Serena Inn", category: "hotel", contact: "Reservations", phone: "+92-5841-83077", city: "Gilgit", country: "Pakistan" },
  ];

  const supIds: string[] = [];
  for (let i = 0; i < supplierData.length; i++) {
    const sid = `5${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    supIds.push(sid);
    const s = supplierData[i];
    await prisma.supplier.create({
      data: {
        id: sid, agencyId: AGENCY_ID, name: s.name, category: s.category,
        contactPerson: s.contact, phone: s.phone, city: s.city, country: s.country,
        balance: 0, createdAt: monthsAgo(11),
      },
    });
  }
  console.log(`Suppliers: ${supplierData.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. LEADS (50 - spread across 12 months, realistic sources & destinations)
  // ═══════════════════════════════════════════════════════════════════════════
  const leadData = [
    // Month 1-2 (older leads)
    { name: "Zubair Ahmed", phone: "+92-300-1111001", dest: "London", src: "walk-in", status: "converted", agent: U_AGENT1, branch: BR_HO, budget: 350000, adults: 2, monthsAgo: 11 },
    { name: "Maham Rizvi", phone: "+92-321-2222002", dest: "Istanbul", src: "instagram", status: "converted", agent: U_AGENT2, branch: BR_HO, budget: 180000, adults: 1, monthsAgo: 11 },
    { name: "Saifullah Niazi", phone: "+92-333-3333003", dest: "Maldives", src: "referral", status: "converted", agent: U_AGENT1, branch: BR_HO, budget: 500000, adults: 2, children: 1, monthsAgo: 10 },
    { name: "Bushra Bibi", phone: "+92-345-4444004", dest: "Umrah", src: "website", status: "converted", agent: U_AGENT4, branch: BR_KHI, budget: 250000, adults: 4, monthsAgo: 10 },
    { name: "Adnan Shah", phone: "+971-50-5555005", dest: "Thailand", src: "whatsapp", status: "converted", agent: U_AGENT3, branch: BR_DXB, budget: 120000, adults: 3, monthsAgo: 9 },
    { name: "Komal Sharma", phone: "+92-300-6666006", dest: "Paris", src: "facebook", status: "converted", agent: U_AGENT2, branch: BR_HO, budget: 400000, adults: 2, monthsAgo: 9 },
    { name: "Rashid Mehmood", phone: "+92-321-7777007", dest: "Northern Areas", src: "walk-in", status: "converted", agent: U_AGENT1, branch: BR_HO, budget: 80000, adults: 5, children: 2, monthsAgo: 8 },
    { name: "Shazia Kanwal", phone: "+92-333-8888008", dest: "China", src: "referral", status: "converted", agent: U_AGENT4, branch: BR_KHI, budget: 200000, adults: 2, monthsAgo: 8 },
    // Month 3-5
    { name: "Asif Javed", phone: "+971-55-9999009", dest: "Malaysia", src: "website", status: "converted", agent: U_AGENT3, branch: BR_DXB, budget: 150000, adults: 2, monthsAgo: 7 },
    { name: "Muniba Raza", phone: "+92-345-1010010", dest: "Turkey", src: "instagram", status: "converted", agent: U_AGENT2, branch: BR_HO, budget: 200000, adults: 2, children: 1, monthsAgo: 7 },
    { name: "Talha Qureshi", phone: "+92-300-2020020", dest: "Umrah", src: "walk-in", status: "converted", agent: U_AGENT1, branch: BR_HO, budget: 300000, adults: 2, monthsAgo: 6 },
    { name: "Sana Malik", phone: "+92-321-3030030", dest: "Bali", src: "website", status: "converted", agent: U_AGENT2, branch: BR_HO, budget: 280000, adults: 2, monthsAgo: 6 },
    { name: "Bilal Tariq", phone: "+971-50-4040040", dest: "London", src: "whatsapp", status: "converted", agent: U_AGENT3, branch: BR_DXB, budget: 450000, adults: 1, monthsAgo: 5 },
    { name: "Ayesha Siddiqui", phone: "+92-333-5050050", dest: "Australia", src: "referral", status: "lost", agent: U_AGENT4, branch: BR_KHI, budget: 600000, adults: 2, monthsAgo: 5 },
    { name: "Waleed Khan", phone: "+92-345-6060060", dest: "Gilgit", src: "facebook", status: "converted", agent: U_AGENT1, branch: BR_HO, budget: 60000, adults: 4, monthsAgo: 5 },
    // Month 6-8
    { name: "Neha Aftab", phone: "+92-300-7070070", dest: "Japan", src: "instagram", status: "contacted", agent: U_AGENT2, branch: BR_HO, budget: 500000, adults: 2, monthsAgo: 4 },
    { name: "Omar Malik", phone: "+971-55-8080080", dest: "Singapore", src: "website", status: "qualified", agent: U_AGENT3, branch: BR_DXB, budget: 300000, adults: 3, monthsAgo: 4 },
    { name: "Iram Basit", phone: "+92-321-9090090", dest: "Switzerland", src: "walk-in", status: "new", agent: U_AGENT4, branch: BR_KHI, budget: 700000, adults: 2, monthsAgo: 4 },
    { name: "Farhan Abbasi", phone: "+92-333-1111212", dest: "Northern Areas", src: "referral", status: "converted", agent: U_AGENT5, branch: BR_ISB, budget: 90000, adults: 6, monthsAgo: 3 },
    { name: "Saima Pervez", phone: "+92-300-2222323", dest: "Dubai", src: "whatsapp", status: "contacted", agent: U_AGENT6, branch: BR_PSW, budget: 150000, adults: 4, monthsAgo: 3 },
    { name: "Danish Nawaz", phone: "+92-345-3333434", dest: "Thailand", src: "instagram", status: "qualified", agent: U_AGENT1, branch: BR_HO, budget: 180000, adults: 2, monthsAgo: 3 },
    { name: "Amina Sheikh", phone: "+971-50-4444545", dest: "Maldives", src: "website", status: "new", agent: U_AGENT3, branch: BR_DXB, budget: 600000, adults: 2, monthsAgo: 3 },
    // Month 9-11 (recent leads)
    { name: "Kamran Ali", phone: "+92-321-5555656", dest: "London", src: "facebook", status: "contacted", agent: U_AGENT2, branch: BR_HO, budget: 400000, adults: 2, monthsAgo: 2 },
    { name: "Fatima Noor", phone: "+92-333-6666767", dest: "Umrah", src: "walk-in", status: "qualified", agent: U_AGENT4, branch: BR_KHI, budget: 280000, adults: 5, monthsAgo: 2 },
    { name: "Hamza Tariq", phone: "+971-55-7777878", dest: "Istanbul", src: "instagram", status: "new", agent: U_AGENT3, branch: BR_DXB, budget: 200000, adults: 2, monthsAgo: 2 },
    { name: "Rida Hussain", phone: "+92-300-8888989", dest: "Bali", src: "referral", status: "contacted", agent: U_AGENT5, branch: BR_ISB, budget: 350000, adults: 2, monthsAgo: 2 },
    { name: "Taimoor Khan", phone: "+92-345-9999090", dest: "Paris", src: "whatsapp", status: "new", agent: U_AGENT6, branch: BR_PSW, budget: 500000, adults: 2, monthsAgo: 1 },
    { name: "Sidra Batool", phone: "+92-321-1010111", dest: "China", src: "website", status: "new", agent: U_AGENT1, branch: BR_HO, budget: 250000, adults: 3, monthsAgo: 1 },
    { name: "Nasir Mehmood", phone: "+971-50-2121212", dest: "Singapore", src: "facebook", status: "contacted", agent: U_AGENT3, branch: BR_DXB, budget: 280000, adults: 2, monthsAgo: 1 },
    { name: "Hina Malik", phone: "+92-333-3232323", dest: "Switzerland", src: "instagram", status: "new", agent: U_AGENT2, branch: BR_HO, budget: 800000, adults: 2, monthsAgo: 0 },
    { name: "Asad Rehman", phone: "+92-300-4343434", dest: "Northern Areas", src: "walk-in", status: "new", agent: U_AGENT5, branch: BR_ISB, budget: 70000, adults: 4, monthsAgo: 0 },
  ];

  const leadIds: string[] = [];
  for (let i = 0; i < leadData.length; i++) {
    const lid = `6${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    leadIds.push(lid);
    const l = leadData[i];
    const createdAt = monthsAgo(l.monthsAgo);
    const travelDate = new Date(createdAt);
    travelDate.setDate(travelDate.getDate() + randomBetween(14, 60));

    await prisma.lead.create({
      data: {
        id: lid, agencyId: AGENCY_ID, branchId: l.branch,
        leadRef: `LD-${new Date().getFullYear()}-${String(i + 1).padStart(3, "0")}`,
        name: l.name, phone: l.phone, destination: l.dest,
        source: l.src, status: l.status, assignedAgentId: l.agent,
        budget: l.budget, adults: l.adults, children: (l as any).children || 0,
        travelDate,
        lastContactedAt: l.status !== "new" ? daysAgo(randomBetween(1, 30)) : null,
        notes: i === 0 ? "Walk-in customer, very interested in Europe packages" : null,
        createdAt,
      },
    });
  }
  console.log(`Leads: ${leadData.length}`);

  // Lead activities (spread across time)
  const leadActivities: { agencyId: string; leadId: string; type: string; description: string; createdBy: string; createdAt: Date }[] = [];
  for (let i = 0; i < leadIds.length; i++) {
    const l = leadData[i];
    const baseDate = monthsAgo(l.monthsAgo);
    // Initial inquiry
    leadActivities.push({ agencyId: AGENCY_ID, leadId: leadIds[i], type: "note", description: `Inquiry about ${l.dest} package`, createdBy: pick(["Ayesha Malik", "Hassan Raza", "Fatima Hussain", "Usman Ali", "Zain Shah", "Farah Noor"]), createdAt: baseDate });
    if (l.status !== "new") {
      leadActivities.push({ agencyId: AGENCY_ID, leadId: leadIds[i], type: "call", description: `Follow-up call - discussed itinerary and pricing for ${l.dest}`, createdBy: pick(["Ayesha Malik", "Hassan Raza"]), createdAt: new Date(baseDate.getTime() + 2 * 86400000) });
    }
    if (["qualified", "converted"].includes(l.status)) {
      leadActivities.push({ agencyId: AGENCY_ID, leadId: leadIds[i], type: "whatsapp", description: `Sent quotation via WhatsApp for ${l.dest}`, createdBy: pick(["Ayesha Malik", "Hassan Raza", "Fatima Hussain"]), createdAt: new Date(baseDate.getTime() + 5 * 86400000) });
    }
    if (l.status === "converted") {
      leadActivities.push({ agencyId: AGENCY_ID, leadId: leadIds[i], type: "booking_created", description: `Converted to Booking - ${l.dest} trip`, createdBy: "Sara Khan", createdAt: new Date(baseDate.getTime() + 10 * 86400000) });
    }
    if (l.status === "lost") {
      leadActivities.push({ agencyId: AGENCY_ID, leadId: leadIds[i], type: "note", description: "Lead lost - budget constraints", createdBy: "Sara Khan", createdAt: new Date(baseDate.getTime() + 14 * 86400000) });
    }
  }
  await prisma.leadActivity.createMany({ data: leadActivities });
  console.log(`Lead activities: ${leadActivities.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. BOOKINGS (30 - spread across 12 months with realistic routes)
  // ═══════════════════════════════════════════════════════════════════════════
  const bookingData = [
    // Older bookings (months 8-11)
    { cust: 0, sup: 2, agent: U_AGENT1, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "London", cost: 185000, sale: 225000, payStatus: "paid", amtRec: 225000, lead: 0, monthsAgo: 11 },
    { cust: 2, sup: 0, agent: U_AGENT2, branch: BR_HO, airline: "PIA", from: "Lahore", to: "Karachi", cost: 35000, sale: 48000, payStatus: "paid", amtRec: 48000, lead: null, monthsAgo: 10 },
    { cust: 4, sup: 2, agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "London", cost: 420000, sale: 520000, payStatus: "paid", amtRec: 520000, lead: null, monthsAgo: 10 },
    { cust: 1, sup: 1, agent: U_AGENT1, branch: BR_HO, airline: "Airblue", from: "Lahore", to: "Istanbul", cost: 95000, sale: 135000, payStatus: "paid", amtRec: 135000, lead: 1, monthsAgo: 9 },
    { cust: 5, sup: 2, agent: U_AGENT2, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Paris", cost: 210000, sale: 275000, payStatus: "paid", amtRec: 275000, lead: 5, monthsAgo: 9 },
    { cust: 3, sup: 0, agent: U_AGENT4, branch: BR_KHI, airline: "PIA", from: "Karachi", to: "Jeddah", cost: 150000, sale: 195000, payStatus: "paid", amtRec: 195000, lead: 3, monthsAgo: 8 },
    { cust: 7, sup: 2, agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "Male", cost: 280000, sale: 380000, payStatus: "paid", amtRec: 380000, lead: null, monthsAgo: 8 },
    { cust: 8, sup: 0, agent: U_AGENT1, branch: BR_HO, airline: "PIA", from: "Lahore", to: "Gilgit", cost: 42000, sale: 65000, payStatus: "paid", amtRec: 65000, lead: 6, monthsAgo: 7 },
    { cust: 6, sup: 1, agent: U_AGENT2, branch: BR_HO, airline: "Airblue", from: "Lahore", to: "Dubai", cost: 65000, sale: 88000, payStatus: "paid", amtRec: 88000, lead: null, monthsAgo: 7 },
    { cust: 9, sup: 2, agent: U_AGENT1, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Singapore", cost: 175000, sale: 230000, payStatus: "paid", amtRec: 230000, lead: null, monthsAgo: 6 },
    // Mid bookings (months 4-7)
    { cust: 10, sup: 8, agent: U_AGENT3, branch: BR_DXB, airline: "Air Arabia", from: "Sharjah", to: "Islamabad", cost: 95000, sale: 130000, payStatus: "paid", amtRec: 130000, lead: null, monthsAgo: 6 },
    { cust: 11, sup: 2, agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "Bali", cost: 310000, sale: 420000, payStatus: "partial", amtRec: 210000, lead: null, monthsAgo: 5 },
    { cust: 12, sup: 1, agent: U_AGENT4, branch: BR_KHI, airline: "Airblue", from: "Karachi", to: "Lahore", cost: 28000, sale: 38000, payStatus: "paid", amtRec: 38000, lead: null, monthsAgo: 5 },
    { cust: 13, sup: 2, agent: U_AGENT2, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Dubai", cost: 72000, sale: 95000, payStatus: "paid", amtRec: 95000, lead: null, monthsAgo: 5 },
    { cust: 14, sup: 10, agent: U_AGENT5, branch: BR_ISB, airline: "PIA", from: "Islamabad", to: "Skardu", cost: 55000, sale: 78000, payStatus: "paid", amtRec: 78000, lead: 18, monthsAgo: 4 },
    { cust: 15, sup: 0, agent: U_AGENT6, branch: BR_PSW, airline: "PIA", from: "Peshawar", to: "Karachi", cost: 32000, sale: 45000, payStatus: "paid", amtRec: 45000, lead: null, monthsAgo: 4 },
    { cust: 16, sup: 2, agent: U_AGENT1, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "London", cost: 195000, sale: 245000, payStatus: "partial", amtRec: 120000, lead: 2, monthsAgo: 4 },
    { cust: 17, sup: 9, agent: U_AGENT4, branch: BR_KHI, airline: "Thai Airways", from: "Karachi", to: "Bangkok", cost: 85000, sale: 115000, payStatus: "paid", amtRec: 115000, lead: null, monthsAgo: 3 },
    { cust: 18, sup: 2, agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "Singapore", cost: 165000, sale: 220000, payStatus: "paid", amtRec: 220000, lead: null, monthsAgo: 3 },
    // Recent bookings (months 1-3)
    { cust: 19, sup: 13, agent: U_AGENT5, branch: BR_ISB, airline: "Turkish Airlines", from: "Islamabad", to: "Istanbul", cost: 125000, sale: 170000, payStatus: "paid", amtRec: 170000, lead: null, monthsAgo: 3 },
    { cust: 20, sup: 2, agent: U_AGENT2, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Dubai", cost: 68000, sale: 92000, payStatus: "partial", amtRec: 50000, lead: 22, monthsAgo: 2 },
    { cust: 21, sup: 0, agent: U_AGENT1, branch: BR_HO, airline: "PIA", from: "Lahore", to: "Gilgit", cost: 45000, sale: 68000, payStatus: "paid", amtRec: 68000, lead: null, monthsAgo: 2 },
    { cust: 22, sup: 2, agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "London", cost: 380000, sale: 480000, payStatus: "partial", amtRec: 240000, lead: null, monthsAgo: 2 },
    { cust: 23, sup: 1, agent: U_AGENT4, branch: BR_KHI, airline: "Airblue", from: "Karachi", to: "Lahore", cost: 30000, sale: 42000, payStatus: "paid", amtRec: 42000, lead: null, monthsAgo: 2 },
    { cust: 24, sup: 8, agent: U_AGENT6, branch: BR_PSW, airline: "Air Arabia", from: "Peshawar", to: "Sharjah", cost: 78000, sale: 105000, payStatus: "paid", amtRec: 105000, lead: null, monthsAgo: 1 },
    { cust: 25, sup: 2, agent: U_AGENT1, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Male", cost: 250000, sale: 340000, payStatus: "unpaid", amtRec: 0, lead: null, monthsAgo: 1 },
    { cust: 26, sup: 13, agent: U_AGENT5, branch: BR_ISB, airline: "Turkish Airlines", from: "Islamabad", to: "London", cost: 190000, sale: 240000, payStatus: "paid", amtRec: 240000, lead: null, monthsAgo: 1 },
    { cust: 27, sup: 2, agent: U_AGENT2, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Dubai", cost: 62000, sale: 85000, payStatus: "paid", amtRec: 85000, lead: null, monthsAgo: 0 },
    { cust: 28, sup: 0, agent: U_AGENT4, branch: BR_KHI, airline: "PIA", from: "Karachi", to: "Islamabad", cost: 38000, sale: 52000, payStatus: "paid", amtRec: 52000, lead: null, monthsAgo: 0 },
    { cust: 29, sup: 2, agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "Bali", cost: 295000, sale: 395000, payStatus: "unpaid", amtRec: 0, lead: null, monthsAgo: 0 },
  ];

  const bookIds: string[] = [];
  for (let i = 0; i < bookingData.length; i++) {
    const bid = `7${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    bookIds.push(bid);
    const b = bookingData[i];
    const profit = b.sale - b.cost;
    const margin = b.sale > 0 ? (profit / b.sale) * 100 : 0;
    const createdDate = monthsAgo(b.monthsAgo);
    const depDate = new Date(createdDate);
    depDate.setDate(depDate.getDate() + randomBetween(7, 21));
    const retDate = new Date(depDate);
    retDate.setDate(retDate.getDate() + randomBetween(5, 14));

    await prisma.booking.create({
      data: {
        id: bid, agencyId: AGENCY_ID,
        bookingRef: `BK-${new Date().getFullYear()}-${String(i + 1).padStart(3, "0")}`,
        customerId: custIds[b.cust], supplierId: supIds[b.sup],
        branchId: b.branch, agentId: b.agent,
        leadId: b.lead !== null ? leadIds[b.lead] : null,
        airline: b.airline, departureCity: b.from, arrivalCity: b.to,
        departureDate: depDate, returnDate: b.adults > 2 ? retDate : null,
        costPrice: b.cost, salePrice: b.sale, profit, profitMargin: margin,
        bookingStatus: "confirmed", paymentStatus: b.payStatus,
        amountReceived: b.amtRec, balance: b.sale - b.amtRec,
        pnr: `PNR${String.fromCharCode(65 + (i % 26))}${1000 + i * 137}`,
        ticketNumber: b.payStatus === "paid" ? `TKT-${new Date().getFullYear()}${String(i + 1).padStart(5, "0")}` : null,
        createdAt: createdDate,
      },
    });
  }
  console.log(`Bookings: ${bookingData.length}`);

  // Booking activities
  const bookingActivities: any[] = [];
  for (let i = 0; i < bookIds.length; i++) {
    const b = bookingData[i];
    const baseDate = monthsAgo(b.monthsAgo);
    bookingActivities.push(
      { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "created", title: "Booking Created", description: "Initial reservation made", createdBy: "System", createdAt: baseDate },
    );
    if (b.payStatus === "paid") {
      bookingActivities.push(
        { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "payment", title: "Payment Received", description: `Full payment of Rs ${b.sale.toLocaleString()} received`, createdBy: "Zainab Noor", createdAt: new Date(baseDate.getTime() + 3 * 86400000) },
      );
    } else if (b.payStatus === "partial") {
      bookingActivities.push(
        { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "payment", title: "Partial Payment", description: `Partial payment of Rs ${b.amtRec.toLocaleString()} received`, createdBy: "Zainab Noor", createdAt: new Date(baseDate.getTime() + 5 * 86400000) },
      );
    }
    if (i % 4 === 0) {
      bookingActivities.push(
        { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "document", title: "Ticket Uploaded", description: "E-ticket uploaded to booking", createdBy: pick(["Sara Khan", "Ayesha Malik", "Omar Farooq"]), createdAt: new Date(baseDate.getTime() + 7 * 86400000) },
      );
    }
  }
  await prisma.bookingActivity.createMany({ data: bookingActivities });
  console.log(`Booking activities: ${bookingActivities.length}`);

  // Booking documents
  const bookingDocs: { agencyId: string; bookingId: string; name: string; url: string; type: string; uploadedBy: string }[] = [];
  for (let i = 0; i < 12; i++) {
    const bi = i % bookIds.length;
    bookingDocs.push({
      agencyId: AGENCY_ID, bookingId: bookIds[bi],
      name: `booking_${bi + 1}_document.pdf`,
      url: `/uploads/bookings/bk${String(bi + 1).padStart(3, "0")}_doc.pdf`,
      type: "pdf",
      uploadedBy: pick(["Sara Khan", "Ayesha Malik", "Omar Farooq", "Zainab Noor"]),
    });
  }
  await prisma.bookingDocument.createMany({ data: bookingDocs });
  console.log(`Booking documents: ${bookingDocs.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 9. EXPENSES (60 - monthly operating expenses across all branches)
  // ═══════════════════════════════════════════════════════════════════════════
  const expenseTemplates = [
    { title: "Office Rent", category: "rent", branches: [BR_HO, BR_KHI, BR_ISB, BR_PSW, BR_DXB], amounts: [85000, 55000, 65000, 45000, 120000], currencies: ["PKR", "PKR", "PKR", "PKR", "AED"] },
    { title: "Electricity Bill", category: "utilities", branches: [BR_HO], amounts: [12500], currencies: ["PKR"] },
    { title: "Internet & Phone", category: "utilities", branches: [BR_HO, BR_KHI, BR_ISB, BR_PSW, BR_DXB], amounts: [8500, 6500, 7000, 5500, 350], currencies: ["PKR", "PKR", "PKR", "PKR", "AED"] },
    { title: "Staff Salaries", category: "salary", branches: [BR_HO], amounts: [450000], currencies: ["PKR"] },
    { title: "Office Supplies", category: "office_supplies", branches: [BR_HO], amounts: [15000], currencies: ["PKR"] },
    { title: "Marketing - Social Media", category: "marketing", branches: [BR_HO], amounts: [35000], currencies: ["PKR"] },
    { title: "Client Entertainment", category: "entertainment", branches: [BR_HO], amounts: [22000], currencies: ["PKR"] },
    { title: "Car Fuel", category: "transport", branches: [BR_HO], amounts: [8000], currencies: ["PKR"] },
    { title: "Website Hosting", category: "technology", branches: [BR_HO], amounts: [5500], currencies: ["PKR"] },
    { title: "Insurance Premium", category: "insurance", branches: [BR_HO], amounts: [45000], currencies: ["PKR"] },
  ];

  const expIds: string[] = [];
  let expCounter = 0;
  // Generate expenses for each of the last 12 months
  for (let monthOffset = 11; monthOffset >= 0; monthOffset--) {
    for (const template of expenseTemplates) {
      for (let bi = 0; bi < template.branches.length; bi++) {
        expCounter++;
        const eid = `8${String(expCounter).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
        expIds.push(eid);
        const expenseDate = monthsAgo(monthOffset);
        expenseDate.setDate(1 + Math.floor(Math.random() * 27));

        await prisma.expense.create({
          data: {
            id: eid, agencyId: AGENCY_ID, branchId: template.branches[bi],
            expenseRef: `EXP-${new Date().getFullYear()}-${String(expCounter).padStart(3, "0")}`,
            title: `${template.title} - ${monthOffset === 0 ? "Current" : `${monthOffset}mo ago`}`,
            category: template.category,
            amount: template.amounts[bi],
            date: expenseDate,
            paidTo: template.title.includes("Rent") ? "Property Management" :
              template.title.includes("Salary") ? "Staff" :
                template.title.includes("Internet") ? "PTCL" :
                  template.title.includes("Electricity") ? "LESCO" :
                    template.title.includes("Marketing") ? "Meta/Google Ads" : "Various",
            paymentMethod: template.category === "rent" ? "bank_transfer" :
              template.category === "salary" ? "bank_transfer" :
                template.category === "utilities" ? "online" : "cash",
            recordedById: U_ACCT,
            status: "approved",
            createdAt: expenseDate,
          },
        });
      }
    }
  }
  console.log(`Expenses: ${expCounter} (12 months of operating expenses)`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 10. RECEIPTS (25 - payments received from customers)
  // ═══════════════════════════════════════════════════════════════════════════
  const receiptData = [
    { bookingIdx: 0, amount: 225000, method: "bank_transfer", monthsAgo: 10 },
    { bookingIdx: 1, amount: 48000, method: "cash", monthsAgo: 9 },
    { bookingIdx: 2, amount: 520000, method: "bank_transfer", monthsAgo: 9 },
    { bookingIdx: 3, amount: 135000, method: "card", monthsAgo: 8 },
    { bookingIdx: 4, amount: 275000, method: "bank_transfer", monthsAgo: 8 },
    { bookingIdx: 5, amount: 195000, method: "bank_transfer", monthsAgo: 7 },
    { bookingIdx: 6, amount: 380000, method: "bank_transfer", monthsAgo: 7 },
    { bookingIdx: 7, amount: 65000, method: "cash", monthsAgo: 6 },
    { bookingIdx: 8, amount: 88000, method: "online", monthsAgo: 6 },
    { bookingIdx: 9, amount: 230000, method: "bank_transfer", monthsAgo: 5 },
    { bookingIdx: 10, amount: 130000, method: "bank_transfer", monthsAgo: 5 },
    { bookingIdx: 11, amount: 210000, method: "bank_transfer", monthsAgo: 4 },
    { bookingIdx: 12, amount: 38000, method: "cash", monthsAgo: 4 },
    { bookingIdx: 13, amount: 95000, method: "bank_transfer", monthsAgo: 4 },
    { bookingIdx: 14, amount: 78000, method: "cash", monthsAgo: 3 },
    { bookingIdx: 15, amount: 45000, method: "cash", monthsAgo: 3 },
    { bookingIdx: 16, amount: 120000, method: "bank_transfer", monthsAgo: 3 },
    { bookingIdx: 17, amount: 115000, method: "bank_transfer", monthsAgo: 2 },
    { bookingIdx: 18, amount: 220000, method: "bank_transfer", monthsAgo: 2 },
    { bookingIdx: 19, amount: 170000, method: "bank_transfer", monthsAgo: 2 },
    { bookingIdx: 20, amount: 50000, method: "card", monthsAgo: 1 },
    { bookingIdx: 21, amount: 68000, method: "cash", monthsAgo: 1 },
    { bookingIdx: 22, amount: 240000, method: "bank_transfer", monthsAgo: 1 },
    { bookingIdx: 23, amount: 42000, method: "cash", monthsAgo: 0 },
    { bookingIdx: 24, amount: 105000, method: "bank_transfer", monthsAgo: 0 },
  ];

  for (let i = 0; i < receiptData.length; i++) {
    const rid = `9${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    const r = receiptData[i];
    const b = bookingData[r.bookingIdx];
    await prisma.receipt.create({
      data: {
        id: rid, agencyId: AGENCY_ID, branchId: b.branch,
        receiptRef: `RCP-${new Date().getFullYear()}-${String(i + 1).padStart(3, "0")}`,
        bookingId: bookIds[r.bookingIdx],
        customerId: custIds[b.cust],
        amount: r.amount, paymentMethod: r.method,
        date: monthsAgo(r.monthsAgo),
        notes: i === 0 ? "Full payment received via bank transfer" : null,
        createdAt: monthsAgo(r.monthsAgo),
      },
    });
  }
  console.log(`Receipts: ${receiptData.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 11. INVOICES (20 - spread across 12 months)
  // ═══════════════════════════════════════════════════════════════════════════
  for (let i = 0; i < 20; i++) {
    const iid = `a${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    const bi = i % bookingData.length;
    const b = bookingData[bi];
    const total = b.sale;
    const tax = Math.round(total * 0.0);
    const monthsAgoVal = Math.floor(i / 2);
    const invoiceDate = monthsAgo(monthsAgoVal);
    const dueDate = new Date(invoiceDate);
    dueDate.setDate(dueDate.getDate() + 30);

    await prisma.invoice.create({
      data: {
        id: iid, agencyId: AGENCY_ID, branchId: b.branch,
        invoiceRef: `INV-${new Date().getFullYear()}-${String(i + 1).padStart(3, "0")}`,
        bookingId: bookIds[bi], customerId: custIds[b.cust],
        subtotal: total, tax, total,
        status: i < 10 ? "paid" : i < 16 ? "sent" : "draft",
        dueDate,
        paidAt: i < 10 ? new Date(invoiceDate.getTime() + 5 * 86400000) : null,
        notes: "Thank you for choosing TripTrails Travel & Tourism",
        items: {
          create: [{
            agencyId: AGENCY_ID,
            description: `Flight Booking - ${b.airline} (${b.from} to ${b.to})`,
            quantity: 1, unitPrice: total, amount: total,
          }],
        },
        createdAt: invoiceDate,
      },
    });
  }
  console.log("Invoices: 20");

  // ═══════════════════════════════════════════════════════════════════════════
  // 12. QUOTATIONS (25 - spread across 12 months)
  // ═══════════════════════════════════════════════════════════════════════════
  const quotationData = [
    { title: "London Family Holiday", dest: "London", travel: "leisure", custIdx: 0, status: "accepted", total: 450000, sub: 410000, fee: 25000, disc: 15000, profit: 45000, monthsAgo: 10 },
    { title: "Istanbul Romantic Getaway", dest: "Istanbul", travel: "leisure", custIdx: 1, status: "accepted", total: 265000, sub: 240000, fee: 15000, disc: 10000, profit: 32000, monthsAgo: 9 },
    { title: "Maldives Honeymoon Package", dest: "Maldives", travel: "honeymoon", custIdx: 7, status: "accepted", total: 620000, sub: 580000, fee: 25000, disc: 0, profit: 68000, monthsAgo: 8 },
    { title: "Umrah Package - Family of 4", dest: "Makkah", travel: "religious", custIdx: 3, status: "accepted", total: 380000, sub: 350000, fee: 20000, disc: 10000, profit: 35000, monthsAgo: 8 },
    { title: "Paris Tour - 2 Weeks", dest: "Paris", travel: "leisure", custIdx: 5, status: "accepted", total: 520000, sub: 480000, fee: 25000, disc: 15000, profit: 55000, monthsAgo: 7 },
    { title: "Dubai Shopping Festival", dest: "Dubai", travel: "leisure", custIdx: 9, status: "accepted", total: 185000, sub: 170000, fee: 10000, disc: 5000, profit: 22000, monthsAgo: 7 },
    { title: "Northern Areas Adventure - 10 Days", dest: "Gilgit-Baltistan", travel: "adventure", custIdx: 8, status: "accepted", total: 125000, sub: 115000, fee: 8000, disc: 3000, profit: 18000, monthsAgo: 6 },
    { title: "China Business Trip", dest: "Shanghai", travel: "business", custIdx: 2, status: "rejected", total: 350000, sub: 320000, fee: 20000, disc: 10000, profit: 28000, monthsAgo: 6 },
    { title: "Thailand Beach Holiday", dest: "Bangkok", travel: "leisure", custIdx: 10, status: "accepted", total: 195000, sub: 180000, fee: 10000, disc: 5000, profit: 24000, monthsAgo: 5 },
    { title: "Bali Honeymoon Special", dest: "Bali", travel: "honeymoon", custIdx: 11, status: "accepted", total: 480000, sub: 445000, fee: 25000, disc: 10000, profit: 52000, monthsAgo: 5 },
    { title: "Singapore Family Package", dest: "Singapore", travel: "leisure", custIdx: 12, status: "sent", total: 320000, sub: 295000, fee: 18000, disc: 8000, profit: 38000, monthsAgo: 4 },
    { title: "UK Student Visa Package", dest: "London", travel: "student_visa", custIdx: 13, status: "sent", total: 750000, sub: 700000, fee: 35000, disc: 0, profit: 85000, monthsAgo: 4 },
    { title: "Switzerland Luxury Tour", dest: "Zurich", travel: "leisure", custIdx: 14, status: "draft", total: 850000, sub: 800000, fee: 35000, disc: 15000, profit: 95000, monthsAgo: 3 },
    { title: "Umrah Group Package - 8 People", dest: "Makkah", travel: "religious", custIdx: 15, status: "sent", total: 520000, sub: 480000, fee: 25000, disc: 15000, profit: 55000, monthsAgo: 3 },
    { title: "Japan Cherry Blossom Tour", dest: "Tokyo", travel: "leisure", custIdx: 16, status: "negotiation", total: 680000, sub: 640000, fee: 25000, disc: 10000, profit: 72000, monthsAgo: 2 },
    { title: "Malaysia & Singapore Combo", dest: "Kuala Lumpur", travel: "leisure", custIdx: 17, status: "accepted", total: 280000, sub: 260000, fee: 12000, disc: 8000, profit: 32000, monthsAgo: 2 },
    { title: "European Grand Tour - 3 Weeks", dest: "Multiple", travel: "leisure", custIdx: 18, status: "draft", total: 1200000, sub: 1140000, fee: 45000, disc: 25000, profit: 135000, monthsAgo: 1 },
    { title: "Australia Student Visa", dest: "Sydney", travel: "student_visa", custIdx: 19, status: "sent", total: 900000, sub: 850000, fee: 35000, disc: 0, profit: 100000, monthsAgo: 1 },
    { title: "Northern Areas Jeep Rally Tour", dest: "Chitral", travel: "adventure", custIdx: 20, status: "accepted", total: 95000, sub: 88000, fee: 5000, disc: 2000, profit: 12000, monthsAgo: 0 },
    { title: "Dubai New Year Celebration", dest: "Dubai", travel: "leisure", custIdx: 21, status: "sent", total: 220000, sub: 205000, fee: 10000, disc: 5000, profit: 28000, monthsAgo: 0 },
    { title: "Turkey & Georgia Tour", dest: "Istanbul", travel: "leisure", custIdx: 22, status: "draft", total: 340000, sub: 315000, fee: 18000, disc: 8000, profit: 40000, monthsAgo: 0 },
  ];

  const quotIds: string[] = [];
  for (let i = 0; i < quotationData.length; i++) {
    const qid = `b${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    quotIds.push(qid);
    const q = quotationData[i];
    const createdDate = monthsAgo(q.monthsAgo);
    const travelDate = new Date(createdDate);
    travelDate.setDate(travelDate.getDate() + randomBetween(21, 60));
    const returnDate = new Date(travelDate);
    returnDate.setDate(returnDate.getDate() + randomBetween(5, 14));
    const validUntil = new Date(createdDate);
    validUntil.setDate(validUntil.getDate() + 30);

    await prisma.quotation.create({
      data: {
        id: qid, agencyId: AGENCY_ID,
        quotationNumber: `QT-${new Date().getFullYear()}-${String(i + 1).padStart(3, "0")}`,
        title: q.title,
        customerId: custIds[q.custIdx], branchId: BR_HO,
        consultantId: pick([U_AGENT1, U_AGENT2, U_AGENT3, U_AGENT4, U_AGENT5, U_AGENT6]),
        travelType: q.travel, destination: q.dest,
        departureDate: travelDate, returnDate,
        adults: 2, children: q.travel === "honeymoon" ? 0 : (i % 4 === 0 ? 2 : 0), infants: 0,
        currency: "PKR",
        subtotal: q.sub, agencyFee: q.fee, discount: q.disc,
        taxTotal: 0, total: q.total, estimatedProfit: q.profit,
        status: q.status,
        validUntil,
        customerNotes: i % 3 === 0 ? "Looking forward to this trip!" : null,
        internalNotes: i % 5 === 0 ? "VIP customer - priority" : null,
        terms: "Payment due within 14 days of confirmation. Cancellation charges apply as per policy.",
        items: {
          create: [
            { agencyId: AGENCY_ID, serviceCategory: "flight", title: "Return Flights", quantity: 2, unit: "Person", costPrice: q.sub * 0.6 / 2, sellingPrice: q.sub * 0.7 / 2, total: q.sub * 0.7, sortOrder: 0 },
            { agencyId: AGENCY_ID, serviceCategory: "hotel", title: "Hotel Accommodation", quantity: 7, unit: "Night", costPrice: q.sub * 0.25 / 7, sellingPrice: q.sub * 0.25 / 7, total: q.sub * 0.25, sortOrder: 1 },
            { agencyId: AGENCY_ID, serviceCategory: "transfer", title: "Airport Transfers", quantity: 2, unit: "Trip", costPrice: 5000, sellingPrice: 8000, total: 16000, sortOrder: 2 },
          ],
        },
        taxes: { create: [] },
        versions: {
          create: [
            { agencyId: AGENCY_ID, version: 1, changes: "Created quotation", createdBy: pick([U_AGENT1, U_AGENT2, U_AGENT3]) },
            ...(q.status !== "draft" ? [{ agencyId: AGENCY_ID, version: 2, changes: "Quotation sent to client", createdBy: pick([U_AGENT1, U_AGENT2, U_AGENT3]) }] : []),
            ...(q.status === "accepted" ? [{ agencyId: AGENCY_ID, version: 3, changes: "Quotation accepted by client", createdBy: pick([U_AGENT1, U_AGENT2, U_AGENT3]) }] : []),
          ],
        },
        createdAt: createdDate,
      },
    });
  }
  console.log(`Quotations: ${quotationData.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 13. TEMPLATES
  // ═══════════════════════════════════════════════════════════════════════════
  await prisma.template.createMany({
    data: [
      { agencyId: AGENCY_ID, name: "Default Quotation Notes", type: "quotation_notes", content: "Thank you for choosing TripTrails Travel & Tourism. This quotation is valid for 30 days from the date of issue. Prices are subject to availability and may change without prior notice. All prices are in PKR unless otherwise specified." },
      { agencyId: AGENCY_ID, name: "Standard Terms & Conditions", type: "quotation_terms", content: "1. Full payment required 14 days before departure.\n2. Cancellation charges: 30 days (10%), 15 days (25%), 7 days (50%), No-show (100%).\n3. Passport must be valid for 6 months beyond travel date.\n4. Travel insurance is mandatory and included in the package.\n5. Hotel check-in/out times are subject to hotel policy.\n6. Meal plans start from lunch on Day 1 and end at breakfast on the last day." },
      { agencyId: AGENCY_ID, name: "Default Invoice Notes", type: "invoice_notes", content: "Payment is due within 30 days of invoice date. Late payments will incur a 2% monthly surcharge. For payments via bank transfer, please reference the invoice number in the transfer description." },
      { agencyId: AGENCY_ID, name: "Standard Invoice Terms", type: "invoice_terms", content: "Payment Methods: Bank Transfer, Cash, Online Payment.\nAll amounts are in PKR.\nFor queries, contact accounts@triptrails.pk or call +92-42-35789012." },
      { agencyId: AGENCY_ID, name: "Umrah Package Notes", type: "quotation_notes", content: "Umrah package includes: Return flights, Hotel accommodation (Makkah & Madinah), Ground transfers, Visa processing, and Ziyarat tours. Zodiac/Cisco accommodation subject to availability." },
      { agencyId: AGENCY_ID, name: "Honeymoon Package Notes", type: "quotation_notes", content: "Honeymoon package includes: Return flights, Luxury hotel accommodation, Airport transfers, Special room decoration, Candlelight dinner, and Couple spa session. Additional experiences available on request." },
      { agencyId: AGENCY_ID, name: "Adventure Tour Notes", type: "quotation_notes", content: "Adventure tour includes: Return flights, Hotel/Camping accommodation, 4x4 transportation, Professional guide, All meals during trekking, and Basic first aid kit. Personal trekking gear recommended." },
    ],
  });
  console.log("Templates: 7");

  // ═══════════════════════════════════════════════════════════════════════════
  // 14. NOTIFICATIONS (spread across users)
  // ═══════════════════════════════════════════════════════════════════════════
  const notificationData = [
    { recipient: U_MANAGER_HO, type: "success", title: "New Booking Created", body: "BK-2026-001 created by Ayesha Malik", entity: "booking", read: true },
    { recipient: U_MANAGER_HO, type: "info", title: "New Lead Assigned", body: "Zubair Ahmed assigned to Ayesha Malik", entity: "lead", read: true },
    { recipient: U_AGENT1, type: "success", title: "Payment Received", body: "Receipt RCP-2026-001 for Rs 225,000", entity: "receipt", read: false },
    { recipient: U_AGENT2, type: "warning", title: "Quotation Expiring", body: "QT-2026-02 expires in 3 days", entity: "quotation", read: false },
    { recipient: U_AGENT3, type: "info", title: "Payment Received", body: "Partial payment of Rs 210,000 for BK-2026-012", entity: "receipt", read: false },
    { recipient: U_OWNER, type: "error", title: "Payment Overdue", body: "BK-2026-026 payment is overdue", entity: "booking", read: false },
    { recipient: U_MANAGER_KHI, type: "success", title: "Booking Completed", body: "BK-2026-006 - Jeddah trip completed", entity: "booking", read: true },
    { recipient: U_AGENT4, type: "info", title: "New Lead", body: "Bushra Bibi - Umrah inquiry from Karachi", entity: "lead", read: true },
    { recipient: U_AGENT5, type: "success", title: "Quotation Accepted", body: "QT-2026-015 accepted by client", entity: "quotation", read: false },
    { recipient: U_ACCT, type: "warning", title: "Invoice Overdue", body: "INV-2026-12 payment overdue by 5 days", entity: "invoice", read: false },
  ];

  for (let i = 0; i < notificationData.length; i++) {
    const n = notificationData[i];
    await prisma.notification.create({
      data: {
        agencyId: AGENCY_ID, recipientId: n.recipient,
        type: n.type as any, title: n.title, body: n.body,
        entityType: n.entity as any,
        isRead: n.read,
        createdAt: daysAgo(randomBetween(1, 30)),
      },
    });
  }
  console.log(`Notifications: ${notificationData.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 15. RECENT ACTIVITIES
  // ═══════════════════════════════════════════════════════════════════════════
  const recentActivities = [
    { type: "booking", title: "Booking Created", detail: "BK-2026-028 - Dubai trip for Usama Tariq", createdBy: "Ayesha Malik", daysAgo: 2 },
    { type: "receipt", title: "Payment Received", detail: "Rs 85,000 from Usama Tariq (RCP-2026-025)", createdBy: "Zainab Noor", daysAgo: 2 },
    { type: "quotation", title: "Quotation Sent", detail: "QT-2026-021 sent to Kamran Ali", createdBy: "Hassan Raza", daysAgo: 3 },
    { type: "lead", title: "New Lead", detail: "Hina Malik - Switzerland inquiry", createdBy: "Hassan Raza", daysAgo: 3 },
    { type: "booking", title: "Booking Created", detail: "BK-2026-027 - Gilgit trip for Danish Nawaz", createdBy: "Ayesha Malik", daysAgo: 4 },
    { type: "expense", title: "Expense Recorded", detail: "Office Rent Lahore - Rs 85,000", createdBy: "Zainab Noor", daysAgo: 5 },
    { type: "quotation", title: "Quotation Accepted", detail: "QT-2026-016 accepted by Amina Sheikh", createdBy: "Fatima Hussain", daysAgo: 6 },
    { type: "receipt", title: "Payment Received", detail: "Rs 240,000 from Bilal Tariq (RCP-2026-022)", createdBy: "Omar Farooq", daysAgo: 7 },
    { type: "booking", title: "Booking Completed", detail: "BK-2026-024 - Sharjah trip completed", createdBy: "Farah Noor", daysAgo: 8 },
    { type: "lead", title: "Lead Converted", detail: "Taimoor Khan converted to booking", createdBy: "Zain Shah", daysAgo: 9 },
  ];

  for (const a of recentActivities) {
    await prisma.recentActivity.create({
      data: {
        agencyId: AGENCY_ID, type: a.type, title: a.title, detail: a.detail,
        createdBy: a.createdBy,
        createdAt: daysAgo(a.daysAgo),
      },
    });
  }
  console.log(`Recent activities: ${recentActivities.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 16. CHART OF ACCOUNTS (19 accounts)
  // ═══════════════════════════════════════════════════════════════════════════
  const coaAccounts = [
    { code: "1000", name: "Cash & Bank", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "1100", name: "Accounts Receivable", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "1200", name: "Prepaid Expenses", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "2000", name: "Accounts Payable", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "2100", name: "Unearned Revenue", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "2200", name: "Tax Payable", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "3000", name: "Owner's Equity", type: "EQUITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "3100", name: "Retained Earnings", type: "EQUITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4000", name: "Flight Booking Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4100", name: "Hotel Booking Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4200", name: "Visa Service Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4300", name: "Insurance Commission", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "5000", name: "Cost of Flights", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "5100", name: "Cost of Hotels", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "5200", name: "Office Rent", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "5300", name: "Staff Salaries", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "5400", name: "Marketing Expense", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "5500", name: "Utilities", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "5600", name: "Office Supplies", type: "EXPENSE" as AccountType, normal: "DEBIT" as NormalBalance },
  ];

  const coaIds: string[] = [];
  for (let i = 0; i < coaAccounts.length; i++) {
    const aid = `c${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    coaIds.push(aid);
    const a = coaAccounts[i];
    await prisma.chartOfAccount.create({
      data: {
        id: aid, agencyId: AGENCY_ID, code: a.code, name: a.name,
        type: a.type, normalBalance: a.normal, isActive: true,
        createdAt: monthsAgo(11),
      },
    });
  }
  console.log(`Chart of Accounts: ${coaAccounts.length}`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 17. FISCAL PERIODS
  // ═══════════════════════════════════════════════════════════════════════════
  const currentYear = new Date().getFullYear();
  await prisma.fiscalPeriod.createMany({
    data: [
      { id: "f0010000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, name: `FY ${currentYear - 1}-${currentYear}`, startDate: new Date(currentYear - 1, 6, 1), endDate: new Date(currentYear, 5, 30), status: "CLOSED" },
      { id: "f0010000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, name: `FY ${currentYear}-${currentYear + 1}`, startDate: new Date(currentYear, 6, 1), endDate: new Date(currentYear + 1, 5, 30), status: "OPEN" },
    ],
  });
  console.log("Fiscal periods: 2");

  // ═══════════════════════════════════════════════════════════════════════════
  // 18. JOURNAL ENTRIES (10 entries with balanced lines)
  // ═══════════════════════════════════════════════════════════════════════════
  const journalEntries = [
    // 1: Booking revenue
    { desc: "Revenue from BK-2026-001 - London trip", source: "BOOKING", sourceIdx: 0, branch: BR_HO, createdBy: U_OWNER, daysAgo: 330, lines: [
      { accountId: 1, debit: 225000, credit: 0, desc: "AR from Ahmed Khan" },
      { accountId: 8, debit: 0, credit: 225000, desc: "Flight booking revenue" },
    ]},
    // 2: Payment received
    { desc: "Payment received from Ahmed Khan", source: "RECEIPT", sourceIdx: 0, branch: BR_HO, createdBy: U_ACCT, daysAgo: 325, lines: [
      { accountId: 0, debit: 225000, credit: 0, desc: "Bank transfer received" },
      { accountId: 1, debit: 0, credit: 225000, desc: "Clear AR - Ahmed Khan" },
    ]},
    // 3: Office rent
    { desc: "Office rent payment - Lahore HQ", source: "EXPENSE", sourceIdx: 0, branch: BR_HO, createdBy: U_ACCT, daysAgo: 320, lines: [
      { accountId: 14, debit: 85000, credit: 0, desc: "Office rent expense" },
      { accountId: 0, debit: 0, credit: 85000, desc: "Cash outflow" },
    ]},
    // 4: Salary
    { desc: "Staff salaries - monthly disbursement", source: "EXPENSE", sourceIdx: 4, branch: BR_HO, createdBy: U_ACCT, daysAgo: 310, lines: [
      { accountId: 15, debit: 450000, credit: 0, desc: "Staff salaries" },
      { accountId: 0, debit: 0, credit: 450000, desc: "Bank transfer - salary" },
    ]},
    // 5: Another booking revenue
    { desc: "Revenue from BK-2026-003 - Dubai-London", source: "BOOKING", sourceIdx: 2, branch: BR_DXB, createdBy: U_MANAGER_DXB, daysAgo: 300, lines: [
      { accountId: 1, debit: 520000, credit: 0, desc: "AR from Tariq Mahmood" },
      { accountId: 8, debit: 0, credit: 520000, desc: "Flight booking revenue" },
    ]},
    // 6: Payment for booking 3
    { desc: "Payment received from Tariq Mahmood", source: "RECEIPT", sourceIdx: 2, branch: BR_DXB, createdBy: U_ACCT, daysAgo: 295, lines: [
      { accountId: 0, debit: 520000, credit: 0, desc: "Bank transfer received" },
      { accountId: 1, debit: 0, credit: 520000, desc: "Clear AR - Tariq Mahmood" },
    ]},
    // 7: Marketing expense
    { desc: "Marketing expense - social media campaigns", source: "EXPENSE", sourceIdx: 6, branch: BR_HO, createdBy: U_ACCT, daysAgo: 280, lines: [
      { accountId: 16, debit: 35000, credit: 0, desc: "Facebook/Instagram ads" },
      { accountId: 0, debit: 0, credit: 35000, desc: "Online payment" },
    ]},
    // 8: Hotel revenue
    { desc: "Revenue from BK-2026-007 - Maldives trip", source: "BOOKING", sourceIdx: 6, branch: BR_DXB, createdBy: U_MANAGER_DXB, daysAgo: 250, lines: [
      { accountId: 1, debit: 380000, credit: 0, desc: "AR from Amina Rashid" },
      { accountId: 9, debit: 0, credit: 380000, desc: "Hotel booking revenue" },
    ]},
    // 9: Supplier payment
    { desc: "Payment to Emirates Airlines", source: "EXPENSE", sourceIdx: 8, branch: BR_HO, createdBy: U_ACCT, daysAgo: 200, lines: [
      { accountId: 3, debit: 185000, credit: 0, desc: "Supplier payment - Emirates" },
      { accountId: 0, debit: 0, credit: 185000, desc: "Bank transfer to supplier" },
    ]},
    // 10: Draft entry
    { desc: "Pending utility bills - all branches", source: "EXPENSE", sourceIdx: 10, branch: BR_HO, createdBy: U_ACCT, daysAgo: 5, status: "DRAFT", lines: [
      { accountId: 17, debit: 42000, credit: 0, desc: "Utility bills - 5 branches" },
      { accountId: 3, debit: 0, credit: 42000, desc: "Accounts payable" },
    ]},
  ];

  let jeCounter = 0;
  let jlCounter = 0;
  for (const je of journalEntries) {
    jeCounter++;
    const jeId = `d${String(jeCounter).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    const jeDate = daysAgo(je.daysAgo);

    await prisma.journalEntry.create({
      data: {
        id: jeId, agencyId: AGENCY_ID, branchId: je.branch,
        entryNumber: `JE-${new Date().getFullYear()}-${String(jeCounter).padStart(3, "0")}`,
        date: jeDate,
        description: je.desc,
        status: (je as any).status || "POSTED",
        sourceModule: je.source,
        sourceId: je.sourceIdx !== null ? (je.source === "BOOKING" ? bookIds[je.sourceIdx] : je.source === "RECEIPT" ? `9${String(je.sourceIdx + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001` : expIds[je.sourceIdx]) : null,
        createdBy: je.createdBy,
        postedAt: (je as any).status !== "DRAFT" ? jeDate : null,
        createdAt: jeDate,
      },
    });

    const lines = je.lines.map((l) => {
      jlCounter++;
      return {
        id: `e${String(jlCounter).padStart(3, "0")}0000-0000-0000-0000-000000000001`,
        agencyId: AGENCY_ID,
        journalEntryId: jeId,
        accountId: coaIds[l.accountId],
        debit: l.debit,
        credit: l.credit,
        currency: "PKR",
        exchangeRate: 1,
        baseDebit: l.debit,
        baseCredit: l.credit,
        description: l.desc,
      };
    });
    await prisma.journalLine.createMany({ data: lines });
  }
  console.log(`Journal entries: ${jeCounter} (${jlCounter} lines)`);

  // ═══════════════════════════════════════════════════════════════════════════
  // 19. COUNTERS (for ref generation)
  // ═══════════════════════════════════════════════════════════════════════════
  await prisma.counter.createMany({
    data: [
      { id: `BK_${AGENCY_ID}_${new Date().getFullYear()}`, seq: bookingData.length },
      { id: `LD_${AGENCY_ID}_${new Date().getFullYear()}`, seq: leadData.length },
      { id: `CUS_${AGENCY_ID}_${new Date().getFullYear()}`, seq: customerData.length },
      { id: `SUP_${AGENCY_ID}_${new Date().getFullYear()}`, seq: supplierData.length },
      { id: `EXP_${AGENCY_ID}_${new Date().getFullYear()}`, seq: expCounter },
      { id: `RCP_${AGENCY_ID}_${new Date().getFullYear()}`, seq: receiptData.length },
      { id: `INV_${AGENCY_ID}_${new Date().getFullYear()}`, seq: 20 },
      { id: `QT_${AGENCY_ID}_${new Date().getFullYear()}`, seq: quotationData.length },
    ],
  });
  console.log("Counters: 8");

  // ═══════════════════════════════════════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════════════════════════════════════
  console.log("\n╔══════════════════════════════════════════════╗");
  console.log("║           SEED COMPLETE - SUMMARY            ║");
  console.log("╚══════════════════════════════════════════════╝");
  console.log(`Agency:            1 (TripTrails Travel & Tourism)`);
  console.log(`Branches:          5 (Lahore HQ, Karachi, Islamabad, Peshawar, Dubai)`);
  console.log(`Roles:             4 (admin, manager, agent, accountant)`);
  console.log(`Users:             11 (1 owner, 3 managers, 6 agents, 1 accountant)`);
  console.log(`Customers:         ${customerData.length}`);
  console.log(`Customer Notes:    ${customerNotes.length}`);
  console.log(`Customer Docs:     ${custDocs.length}`);
  console.log(`Suppliers:         ${supplierData.length}`);
  console.log(`Leads:             ${leadData.length}`);
  console.log(`Lead Activities:   ${leadActivities.length}`);
  console.log(`Bookings:          ${bookingData.length}`);
  console.log(`Booking Activities: ${bookingActivities.length}`);
  console.log(`Booking Docs:      ${bookingDocs.length}`);
  console.log(`Expenses:          ${expCounter}`);
  console.log(`Receipts:          ${receiptData.length}`);
  console.log(`Invoices:          20`);
  console.log(`Quotations:        ${quotationData.length}`);
  console.log(`Templates:         7`);
  console.log(`Notifications:     ${notificationData.length}`);
  console.log(`Recent Activities: ${recentActivities.length}`);
  console.log(`Chart of Accounts: ${coaAccounts.length}`);
  console.log(`Fiscal Periods:    2`);
  console.log(`Journal Entries:   ${jeCounter} (${jlCounter} lines)`);
  console.log(`Counters:          8`);
  console.log(`\n╔══════════════════════════════════════════════╗`);
  console.log(`║           LOGIN CREDENTIALS                  ║`);
  console.log(`╚══════════════════════════════════════════════╝`);
  console.log(`  Owner:       owner@triptrails.pk    / Password123!`);
  console.log(`  Manager HO:  sara@triptrails.pk     / Password123!`);
  console.log(`  Manager KHI: ahmed.razatr@triptrails.pk / Password123!`);
  console.log(`  Manager DXB: omar@triptrails.pk     / Password123!`);
  console.log(`  Agent 1:     agent1@triptrails.pk   / Password123!`);
  console.log(`  Agent 2:     hassan@triptrails.pk   / Password123!`);
  console.log(`  Agent 3:     fatima@triptrails.pk   / Password123!`);
  console.log(`  Agent 4:     usman@triptrails.pk    / Password123!`);
  console.log(`  Agent 5:     zain@triptrails.pk     / Password123!`);
  console.log(`  Agent 6:     farah@triptrails.pk    / Password123!`);
  console.log(`  Accountant:  zainab@triptrails.pk   / Password123!`);
}

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
