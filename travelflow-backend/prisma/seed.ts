import { PrismaClient, AccountType, NormalBalance, PeriodStatus, JournalEntryStatus } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

const AGENCY_ID = "a1000000-0000-0000-0000-000000000001";
const BR_HO = "b1000000-0000-0000-0000-000000000001";
const BR_DXB = "b1000000-0000-0000-0000-000000000002";
const BR_KHI = "b1000000-0000-0000-0000-000000000003";

const U_ADMIN = "u1000000-0000-0000-0000-000000000001";
const U_MANAGER1 = "u1000000-0000-0000-0000-000000000002";
const U_MANAGER2 = "u1000000-0000-0000-0000-000000000003";
const U_AGENT1 = "u1000000-0000-0000-0000-000000000004";
const U_AGENT2 = "u1000000-0000-0000-0000-000000000005";
const U_AGENT3 = "u1000000-0000-0000-0000-000000000006";
const U_AGENT4 = "u1000000-0000-0000-0000-000000000007";
const U_ACCT = "u1000000-0000-0000-0000-000000000008";

function id(n: number) {
  return `a${String(n).padStart(3, "0")}00000-0000-0000-0000-000000000001`;
}

function daysAgo(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() - n);
  d.setHours(10 + Math.floor(Math.random() * 8), Math.floor(Math.random() * 60), 0, 0);
  return d;
}

function futureDate(n: number): Date {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return d;
}

async function main() {
  console.log("=== TravelFlow Full Seed ===\n");

  const pw = await bcrypt.hash("admin123", 12);

  // ═══════════════════════════════════════════
  // 1. AGENCY
  // ═══════════════════════════════════════════
  await prisma.agency.create({
    data: {
      id: AGENCY_ID,
      name: "TripTrails Travel Agency",
      slug: "trails-01",
      code: "TT",
      contactEmail: "info@trails.pk",
      contactPhone: "+92-42-35789012",
      address: "89-A, Block P, Johar Town",
      city: "Lahore",
      country: "Pakistan",
      currency: "PKR",
      registrationNo: "SECP-TRAILS-2024",
      primaryColor: "#1a56db",
      emailAlerts: true,
      smsAlerts: false,
      dailyReports: true,
      status: "active",
    },
  });
  console.log("Agency: TripTrails Travel Agency");

  // ═══════════════════════════════════════════
  // 2. BRANCHES
  // ═══════════════════════════════════════════
  await prisma.branch.createMany({
    data: [
      { id: BR_HO, agencyId: AGENCY_ID, name: "Head Office Lahore", code: "HO", city: "Lahore", address: "89-A, Block P, Johar Town", phone: "+92-42-35789012", isHeadOffice: true, status: "active" },
      { id: BR_DXB, agencyId: AGENCY_ID, name: "Dubai Branch", code: "DXB", city: "Dubai", address: "Office 1204, Al Habtoor Business Tower, Sheikh Zayed Road", phone: "+971-4-3301234", isHeadOffice: false, status: "active" },
      { id: BR_KHI, agencyId: AGENCY_ID, name: "Karachi Branch", code: "KHI", city: "Karachi", address: "Suite 501, SBQ Tower, Shahrah-e-Faisal", phone: "+92-21-34567890", isHeadOffice: false, status: "active" },
    ],
  });
  console.log("Branches: Lahore (HQ), Dubai, Karachi");

  // ═══════════════════════════════════════════
  // 3. ROLES
  // ═══════════════════════════════════════════
  await prisma.role.createMany({
    data: [
      {
        id: "r0010000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, name: "admin", description: "Full system access",
        permissions: ["all"], color: "#dc2626", textColor: "#ffffff",
      },
      {
        id: "r0010000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, name: "manager", description: "Branch manager with full branch access",
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
        id: "r0010000-0000-0000-0000-000000000003", agencyId: AGENCY_ID, name: "agent", description: "Travel agent - limited access",
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
        id: "r0010000-0000-0000-0000-000000000004", agencyId: AGENCY_ID, name: "accountant", description: "Financial and accounting access",
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
  console.log("Roles: admin, manager, agent, accountant");

  // ═══════════════════════════════════════════
  // 4. USERS
  // ═══════════════════════════════════════════
  await prisma.user.createMany({
    data: [
      { id: U_ADMIN, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Bilal", lastName: "Ahmed", email: "admin@trails.pk", password: pw, phone: "+92-300-1234567", role: "admin", status: "active" },
      { id: U_MANAGER1, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Sara", lastName: "Khan", email: "sara@trails.pk", password: pw, phone: "+92-321-2345678", role: "manager", status: "active" },
      { id: U_MANAGER2, agencyId: AGENCY_ID, branchId: BR_DXB, firstName: "Omar", lastName: "Farooq", email: "omar@trails.pk", password: pw, phone: "+971-50-1234567", role: "manager", status: "active" },
      { id: U_AGENT1, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Ayesha", lastName: "Malik", email: "ayesha@trails.pk", password: pw, phone: "+92-333-3456789", role: "agent", status: "active" },
      { id: U_AGENT2, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Hassan", lastName: "Raza", email: "hassan@trails.pk", password: pw, phone: "+92-345-4567890", role: "agent", status: "active" },
      { id: U_AGENT3, agencyId: AGENCY_ID, branchId: BR_DXB, firstName: "Fatima", lastName: "Hussain", email: "fatima@trails.pk", password: pw, phone: "+971-55-9876543", role: "agent", status: "active" },
      { id: U_AGENT4, agencyId: AGENCY_ID, branchId: BR_KHI, firstName: "Usman", lastName: "Ali", email: "usman@trails.pk", password: pw, phone: "+92-300-5678901", role: "agent", status: "active" },
      { id: U_ACCT, agencyId: AGENCY_ID, branchId: BR_HO, firstName: "Zainab", lastName: "Noor", email: "zainab@trails.pk", password: pw, phone: "+92-312-6789012", role: "accountant", status: "active" },
    ],
  });
  console.log("Users: 8 (admin, 2 managers, 4 agents, 1 accountant)");

  // ═══════════════════════════════════════════
  // 5. CUSTOMERS
  // ═══════════════════════════════════════════
  const customers = [
    { firstName: "Ahmed", lastName: "Khan", phone: "+92-321-1111111", email: "ahmed.khan@gmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "AK1234567" },
    { firstName: "Fatima", lastName: "Zahra", phone: "+92-333-2222222", email: "fatima.z@outlook.com", city: "Islamabad", country: "Pakistan", type: "individual" as const, passport: "FZ2345678" },
    { firstName: "Muhammad", lastName: "Ali", phone: "+92-345-3333333", email: "mali@yahoo.com", city: "Lahore", country: "Pakistan", type: "corporate" as const, passport: "MA3456789", company: "Ali & Sons Trading" },
    { firstName: "Sobia", lastName: "Aslam", phone: "+92-300-4444444", email: "sobia.aslam@gmail.com", city: "Karachi", country: "Pakistan", type: "individual" as const, passport: "SA4567890" },
    { firstName: "Tariq", lastName: "Mahmood", phone: "+971-50-5555555", email: "tariq.m@hotmail.com", city: "Dubai", country: "UAE", type: "corporate" as const, passport: "TM5678901", company: "Mahmood Holdings LLC" },
    { firstName: "Nadia", lastName: "Pervez", phone: "+92-321-6666666", email: "nadia.p@gmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "NP6789012" },
    { firstName: "Imran", lastName: "Sheikh", phone: "+92-333-7777777", email: "imran.s@outlook.com", city: "Faisalabad", country: "Pakistan", type: "individual" as const, passport: "IS7890123" },
    { firstName: "Amina", lastName: "Rashid", phone: "+971-55-8888888", email: "amina.r@gmail.com", city: "Dubai", country: "UAE", type: "individual" as const, passport: "AR8901234" },
    { firstName: "Kamran", lastName: "Butt", phone: "+92-345-9999999", email: "kamran.b@yahoo.com", city: "Lahore", country: "Pakistan", type: "corporate" as const, passport: "KB9012345", company: "Butt Enterprises" },
    { firstName: "Hira", lastName: "Saleem", phone: "+92-300-1010101", email: "hira.saleem@gmail.com", city: "Rawalpindi", country: "Pakistan", type: "individual" as const, passport: "HS0123456" },
    { firstName: "Danish", lastName: "Iqbal", phone: "+92-321-2020202", email: "danish.i@hotmail.com", city: "Sialkot", country: "Pakistan", type: "individual" as const, passport: "DI1234098" },
    { firstName: "Mehreen", lastName: "Baig", phone: "+971-50-3030303", email: "mehreen.b@gmail.com", city: "Abu Dhabi", country: "UAE", type: "individual" as const, passport: "MB2345098" },
    { firstName: "Saad", lastName: "Nawaz", phone: "+92-333-4040404", email: "saad.n@outlook.com", city: "Multan", country: "Pakistan", type: "corporate" as const, passport: "SN3456098", company: "Nawaz Group" },
    { firstName: "Rabia", lastName: "Chaudhry", phone: "+92-345-5050505", email: "rabia.c@gmail.com", city: "Lahore", country: "Pakistan", type: "individual" as const, passport: "RC4567098" },
    { firstName: "Faisal", lastName: "Warraich", phone: "+92-300-6060606", email: "faisal.w@yahoo.com", city: "Gujranwala", country: "Pakistan", type: "individual" as const, passport: "FW5678098" },
  ];

  const custIds: string[] = [];
  for (let i = 0; i < customers.length; i++) {
    const c = customers[i];
    const cid = `c${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    custIds.push(cid);
    await prisma.customer.create({
      data: {
        id: cid, agencyId: AGENCY_ID, customerRef: `CUS-2026-${String(i + 1).padStart(3, "0")}`,
        type: c.type, firstName: c.firstName, lastName: c.lastName,
        email: c.email, phone: c.phone, city: c.city, country: c.country,
        passportNumber: c.passport, companyName: (c as any).company || null,
        gender: i % 2 === 0 ? "male" : "female",
        dateOfBirth: new Date(1980 + Math.floor(Math.random() * 20), Math.floor(Math.random() * 12), 1 + Math.floor(Math.random() * 28)),
        internalNotes: i % 3 === 0 ? "VIP customer - priority handling" : null,
      },
    });
  }
  console.log(`Customers: ${customers.length}`);

  // ═══════════════════════════════════════════
  // 6. CUSTOMER NOTES
  // ═══════════════════════════════════════════
  await prisma.customerNote.createMany({
    data: [
      { agencyId: AGENCY_ID, customerId: custIds[0], note: "Prefers direct flights. Always travels business class.", addedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, customerId: custIds[0], note: "Family trip to Europe planned for December.", addedBy: "Ayesha Malik" },
      { agencyId: AGENCY_ID, customerId: custIds[1], note: "First-time international traveler. Needs visa assistance.", addedBy: "Hassan Raza" },
      { agencyId: AGENCY_ID, customerId: custIds[2], note: "Corporate account - monthly billing. Net 30 terms.", addedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, customerId: custIds[4], note: "Dubai-based. Frequently travels to London and Singapore.", addedBy: "Omar Farooq" },
      { agencyId: AGENCY_ID, customerId: custIds[4], note: "Prefers Emirates and Singapore Airlines.", addedBy: "Fatima Hussain" },
      { agencyId: AGENCY_ID, customerId: custIds[7], note: "Honeymoon trip to Maldives. Budget flexible.", addedBy: "Ayesha Malik" },
      { agencyId: AGENCY_ID, customerId: custIds[8], note: "Company retreat - 25 pax to Northern Areas.", addedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, customerId: custIds[11], note: "Abu Dhabi based. Family of 4.", addedBy: "Omar Farooq" },
    ],
  });
  console.log("Customer notes: 9");

  // ═══════════════════════════════════════════
  // 7. CUSTOMER DOCUMENTS
  // ═══════════════════════════════════════════
  await prisma.customerDocument.createMany({
    data: [
      { agencyId: AGENCY_ID, customerId: custIds[0], documentType: "passport", fileName: "ahmed_passport.pdf", fileSize: 245000, mimeType: "application/pdf", fileUrl: "/uploads/customers/ahmed_passport.pdf", uploadedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, customerId: custIds[1], documentType: "cnic", fileName: "fatima_cnic.pdf", fileSize: 189000, mimeType: "application/pdf", fileUrl: "/uploads/customers/fatima_cnic.pdf", uploadedBy: "Hassan Raza" },
      { agencyId: AGENCY_ID, customerId: custIds[2], documentType: "passport", fileName: "ali_passport.pdf", fileSize: 312000, mimeType: "application/pdf", fileUrl: "/uploads/customers/ali_passport.pdf", uploadedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, customerId: custIds[4], documentType: "visa", fileName: "tariq_uk_visa.pdf", fileSize: 156000, mimeType: "application/pdf", fileUrl: "/uploads/customers/tariq_uk_visa.pdf", uploadedBy: "Omar Farooq" },
      { agencyId: AGENCY_ID, customerId: custIds[7], documentType: "passport", fileName: "amina_passport.pdf", fileSize: 278000, mimeType: "application/pdf", fileUrl: "/uploads/customers/amina_passport.pdf", uploadedBy: "Fatima Hussain" },
    ],
  });
  console.log("Customer documents: 5");

  // ═══════════════════════════════════════════
  // 8. SUPPLIERS
  // ═══════════════════════════════════════════
  const suppliers = [
    { name: "PIA - Pakistan International Airlines", category: "airline", contact: "Reservations Desk", phone: "+92-21-111786786", city: "Karachi", country: "Pakistan" },
    { name: "Airblue", category: "airline", contact: "Trade Desk", phone: "+92-21-111247247", city: "Karachi", country: "Pakistan" },
    { name: "Emirates Airlines", category: "airline", contact: "Corporate Sales", phone: "+971-600-555555", city: "Dubai", country: "UAE" },
    { name: "Serena Hotels Pakistan", category: "hotel", contact: "Group Bookings", phone: "+92-51-2878070", city: "Islamabad", country: "Pakistan" },
    { name: "Pearl Continental Hotels", category: "hotel", contact: "MICE Desk", phone: "+92-42-35781000", city: "Lahore", country: "Pakistan" },
    { name: "Saudi Travel Agency", category: "ground_handler", contact: "Hajj/Umrah Desk", phone: "+966-11-2654321", city: "Jeddah", country: "Saudi Arabia" },
    { name: "VisaMaster Consultants", category: "visa_agent", contact: "Processing Team", phone: "+92-42-35678901", city: "Lahore", country: "Pakistan" },
    { name: "TravelGuard Insurance", category: "insurance", contact: "Policy Sales", phone: "+92-42-34567890", city: "Lahore", country: "Pakistan" },
  ];

  const supIds: string[] = [];
  for (let i = 0; i < suppliers.length; i++) {
    const sid = `s${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    supIds.push(sid);
    const s = suppliers[i];
    await prisma.supplier.create({
      data: {
        id: sid, agencyId: AGENCY_ID, name: s.name, category: s.category,
        contactPerson: s.contact, phone: s.phone, city: s.city, country: s.country,
        balance: 0,
      },
    });
  }
  console.log(`Suppliers: ${suppliers.length}`);

  // ═══════════════════════════════════════════
  // 9. LEADS
  // ═══════════════════════════════════════════
  const leads = [
    { name: "Zubair Ahmed", phone: "+92-300-1111001", dest: "London", src: "walk-in", status: "new", agent: U_AGENT1, branch: BR_HO, budget: 350000, adults: 2 },
    { name: "Maham Rizvi", phone: "+92-321-2222002", dest: "Istanbul", src: "instagram", status: "contacted", agent: U_AGENT2, branch: BR_HO, budget: 180000, adults: 1 },
    { name: "Saifullah Niazi", phone: "+92-333-3333003", dest: "Maldives", src: "referral", status: "qualified", agent: U_AGENT1, branch: BR_HO, budget: 500000, adults: 2, children: 1 },
    { name: "Bushra Bibi", phone: "+92-345-4444004", dest: "Umrah", src: "website", status: "new", agent: U_AGENT4, branch: BR_KHI, budget: 250000, adults: 4 },
    { name: "Adnan Shah", phone: "+971-50-5555005", dest: "Thailand", src: "whatsapp", status: "contacted", agent: U_AGENT3, branch: BR_DXB, budget: 120000, adults: 3 },
    { name: "Komal Sharma", phone: "+92-300-6666006", dest: "Paris", src: "facebook", status: "new", agent: U_AGENT2, branch: BR_HO, budget: 400000, adults: 2 },
    { name: "Rashid Mehmood", phone: "+92-321-7777007", dest: "Northern Areas", src: "walk-in", status: "converted", agent: U_AGENT1, branch: BR_HO, budget: 80000, adults: 5, children: 2 },
    { name: "Shazia Kanwal", phone: "+92-333-8888008", dest: "China", src: "referral", status: "qualified", agent: U_AGENT4, branch: BR_KHI, budget: 200000, adults: 2 },
    { name: "Asif Javed", phone: "+971-55-9999009", dest: "Malaysia", src: "website", status: "contacted", agent: U_AGENT3, branch: BR_DXB, budget: 150000, adults: 2 },
    { name: "Muniba Raza", phone: "+92-345-1010010", dest: "Turkey", src: "instagram", status: "new", agent: U_AGENT2, branch: BR_HO, budget: 200000, adults: 2, children: 1 },
    { name: "Talha Qureshi", phone: "+92-300-2020020", dest: "Umrah", src: "walk-in", status: "contacted", agent: U_AGENT1, branch: BR_HO, budget: 300000, adults: 2 },
    { name: "Sana Malik", phone: "+92-321-3030030", dest: "Bali", src: "website", status: "new", agent: U_AGENT2, branch: BR_HO, budget: 280000, adults: 2 },
    { name: "Bilal Tariq", phone: "+971-50-4040040", dest: "London", src: "whatsapp", status: "qualified", agent: U_AGENT3, branch: BR_DXB, budget: 450000, adults: 1 },
    { name: "Ayesha Siddiqui", phone: "+92-333-5050050", dest: "Australia", src: "referral", status: "new", agent: U_AGENT4, branch: BR_KHI, budget: 600000, adults: 2 },
    { name: "Waleed Khan", phone: "+92-345-6060060", dest: "Gilgit", src: "facebook", status: "contacted", agent: U_AGENT1, branch: BR_HO, budget: 60000, adults: 4 },
    { name: "Neha Aftab", phone: "+92-300-7070070", dest: "Japan", src: "instagram", status: "new", agent: U_AGENT2, branch: BR_HO, budget: 500000, adults: 2 },
    { name: "Omar Malik", phone: "+971-55-8080080", dest: "Singapore", src: "website", status: "qualified", agent: U_AGENT3, branch: BR_DXB, budget: 300000, adults: 3 },
    { name: "Iram Basit", phone: "+92-321-9090090", dest: "Switzerland", src: "walk-in", status: "new", agent: U_AGENT4, branch: BR_KHI, budget: 700000, adults: 2 },
  ];

  const leadIds: string[] = [];
  for (let i = 0; i < leads.length; i++) {
    const lid = `l${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    leadIds.push(lid);
    const l = leads[i];
    await prisma.lead.create({
      data: {
        id: lid, agencyId: AGENCY_ID, branchId: l.branch,
        leadRef: `LD-2026-${String(i + 1).padStart(3, "0")}`,
        name: l.name, phone: l.phone, destination: l.dest,
        source: l.src, status: l.status, assignedAgentId: l.agent,
        budget: l.budget, adults: l.adults, children: l.children || 0,
        travelDate: futureDate(30 + i * 7),
        lastContactedAt: l.status !== "new" ? daysAgo(18 - i) : null,
        notes: i === 0 ? "Walk-in customer, very interested in Europe packages" : null,
      },
    });
  }
  console.log(`Leads: ${leads.length}`);

  // Lead activities
  const activities: { agencyId: string; leadId: string; type: string; description: string; createdBy: string; createdAt: Date }[] = [];
  for (let i = 0; i < 12; i++) {
    const li = i % leadIds.length;
    activities.push({ agencyId: AGENCY_ID, leadId: leadIds[li], type: "note", description: `Initial inquiry about ${leads[li].dest}`, createdBy: "System", createdAt: daysAgo(20 - i) });
  }
  for (let i = 0; i < 8; i++) {
    const li = i % leadIds.length;
    activities.push({ agencyId: AGENCY_ID, leadId: leadIds[li], type: "call", description: `Follow-up call - discussed itinerary and pricing`, createdBy: "Ayesha Malik", createdAt: daysAgo(15 - i) });
  }
  for (let i = 0; i < 5; i++) {
    const li = i % leadIds.length;
    activities.push({ agencyId: AGENCY_ID, leadId: leadIds[li], type: "whatsapp", description: `Sent quotation via WhatsApp`, createdBy: "Hassan Raza", createdAt: daysAgo(10 - i) });
  }
  for (let i = 0; i < 3; i++) {
    const li = i % leadIds.length;
    activities.push({ agencyId: AGENCY_ID, leadId: leadIds[li], type: "booking_created", description: `Converted to Booking`, createdBy: "Sara Khan", createdAt: daysAgo(5 - i) });
  }
  await prisma.leadActivity.createMany({ data: activities });
  console.log(`Lead activities: ${activities.length}`);

  // ═══════════════════════════════════════════
  // 10. BOOKINGS
  // ═══════════════════════════════════════════
  const bookings = [
    { ref: "BK-2026-001", cust: custIds[0], sup: supIds[2], agent: U_AGENT1, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "London", dep: 15, cost: 185000, sale: 225000, payStatus: "paid", amtRec: 225000, lead: leadIds[6] },
    { ref: "BK-2026-002", cust: custIds[2], sup: supIds[0], agent: U_AGENT2, branch: BR_HO, airline: "PIA", from: "Lahore", to: "Karachi", dep: 5, cost: 35000, sale: 48000, payStatus: "paid", amtRec: 48000 },
    { ref: "BK-2026-003", cust: custIds[4], sup: supIds[2], agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "London", dep: 20, cost: 420000, sale: 520000, payStatus: "partial", amtRec: 300000 },
    { ref: "BK-2026-004", cust: custIds[1], sup: supIds[1], agent: U_AGENT1, branch: BR_HO, airline: "Airblue", from: "Lahore", to: "Istanbul", dep: 25, cost: 95000, sale: 135000, payStatus: "partial", amtRec: 70000, lead: leadIds[1] },
    { ref: "BK-2026-005", cust: custIds[5], sup: supIds[2], agent: U_AGENT2, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Paris", dep: 30, cost: 210000, sale: 275000, payStatus: "unpaid", amtRec: 0 },
    { ref: "BK-2026-006", cust: custIds[3], sup: supIds[0], agent: U_AGENT4, branch: BR_KHI, airline: "PIA", from: "Karachi", to: "Jeddah", dep: 10, cost: 150000, sale: 195000, payStatus: "paid", amtRec: 195000 },
    { ref: "BK-2026-007", cust: custIds[7], sup: supIds[2], agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "Male", dep: 18, cost: 280000, sale: 380000, payStatus: "partial", amtRec: 200000 },
    { ref: "BK-2026-008", cust: custIds[8], sup: supIds[0], agent: U_AGENT1, branch: BR_HO, airline: "PIA", from: "Lahore", to: "Gilgit", dep: 7, cost: 42000, sale: 65000, payStatus: "paid", amtRec: 65000 },
    { ref: "BK-2026-009", cust: custIds[6], sup: supIds[1], agent: U_AGENT2, branch: BR_HO, airline: "Airblue", from: "Lahore", to: "Dubai", dep: 12, cost: 65000, sale: 88000, payStatus: "paid", amtRec: 88000 },
    { ref: "BK-2026-010", cust: custIds[9], sup: supIds[2], agent: U_AGENT1, branch: BR_HO, airline: "Emirates", from: "Lahore", to: "Singapore", dep: 35, cost: 175000, sale: 230000, payStatus: "unpaid", amtRec: 0 },
    { ref: "BK-2026-011", cust: custIds[11], sup: supIds[2], agent: U_AGENT3, branch: BR_DXB, airline: "Emirates", from: "Dubai", to: "Bali", dep: 40, cost: 310000, sale: 420000, payStatus: "partial", amtRec: 210000 },
    { ref: "BK-2026-012", cust: custIds[10], sup: supIds[1], agent: U_AGENT4, branch: BR_KHI, airline: "Airblue", from: "Karachi", to: "Lahore", dep: 3, cost: 28000, sale: 38000, payStatus: "paid", amtRec: 38000 },
  ];

  const bookIds: string[] = [];
  for (let i = 0; i < bookings.length; i++) {
    const bid = `bk${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    bookIds.push(bid);
    const b = bookings[i];
    const profit = b.sale - b.cost;
    const margin = b.sale > 0 ? (profit / b.sale) * 100 : 0;
    await prisma.booking.create({
      data: {
        id: bid, agencyId: AGENCY_ID, bookingRef: b.ref,
        customerId: b.cust, supplierId: b.sup, branchId: b.branch, agentId: b.agent,
        leadId: b.lead || null,
        airline: b.airline, departureCity: b.from, arrivalCity: b.to,
        departureDate: futureDate(b.dep), returnDate: b.dep > 15 ? futureDate(b.dep + 7) : null,
        costPrice: b.cost, salePrice: b.sale, profit, profitMargin: margin,
        bookingStatus: "confirmed", paymentStatus: b.payStatus,
        amountReceived: b.amtRec, balance: b.sale - b.amtRec,
        pnr: `PNR${String.fromCharCode(65 + i)}${1000 + i * 137}`,
        ticketNumber: b.payStatus === "paid" ? `TKT-${2026}${String(i + 1).padStart(5, "0")}` : null,
      },
    });
  }
  console.log(`Bookings: ${bookings.length}`);

  // Booking activities
  const bActivities: any[] = [];
  for (let i = 0; i < bookIds.length; i++) {
    bActivities.push(
      { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "created", title: "Booking Created", description: "Initial reservation made", createdBy: "System", createdAt: daysAgo(25 - i) },
    );
    if (bookings[i].payStatus === "paid") {
      bActivities.push(
        { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "payment", title: "Payment Received", description: `Full payment of Rs ${bookings[i].sale.toLocaleString()} received`, createdBy: "Zainab Noor", createdAt: daysAgo(20 - i) },
      );
    } else if (bookings[i].payStatus === "partial") {
      bActivities.push(
        { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "payment", title: "Partial Payment", description: `Partial payment of Rs ${bookings[i].amtRec.toLocaleString()} received`, createdBy: "Zainab Noor", createdAt: daysAgo(18 - i) },
      );
    }
    if (i % 3 === 0) {
      bActivities.push(
        { agencyId: AGENCY_ID, bookingId: bookIds[i], type: "document", title: "Ticket Uploaded", description: "E-ticket uploaded to booking", createdBy: "Sara Khan", createdAt: daysAgo(15 - i) },
      );
    }
  }
  await prisma.bookingActivity.createMany({ data: bActivities });
  console.log(`Booking activities: ${bActivities.length}`);

  // Booking documents
  await prisma.bookingDocument.createMany({
    data: [
      { agencyId: AGENCY_ID, bookingId: bookIds[0], name: "e-ticket.pdf", url: "/uploads/bookings/bk001_eticket.pdf", type: "pdf", uploadedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, bookingId: bookIds[0], name: "visa_uk.pdf", url: "/uploads/bookings/bk001_visa.pdf", type: "pdf", uploadedBy: "Sara Khan" },
      { agencyId: AGENCY_ID, bookingId: bookIds[2], name: "e-ticket.pdf", url: "/uploads/bookings/bk003_eticket.pdf", type: "pdf", uploadedBy: "Omar Farooq" },
      { agencyId: AGENCY_ID, bookingId: bookIds[5], name: "e-ticket.pdf", url: "/uploads/bookings/bk006_eticket.pdf", type: "pdf", uploadedBy: "Zainab Noor" },
      { agencyId: AGENCY_ID, bookingId: bookIds[7], name: "hotel_voucher.pdf", url: "/uploads/bookings/bk008_hotel.pdf", type: "pdf", uploadedBy: "Ayesha Malik" },
    ],
  });
  console.log("Booking documents: 5");

  // ═══════════════════════════════════════════
  // 11. EXPENSES
  // ═══════════════════════════════════════════
  const expenses = [
    { title: "Office Rent - Lahore", category: "rent", amount: 85000, paidTo: "PROPERTY MANAGEMENT CO.", method: "bank_transfer", branch: BR_HO },
    { title: "Office Rent - Dubai", category: "rent", amount: 120000, paidTo: "Al Habtoor Properties", method: "bank_transfer", branch: BR_DXB, currency: "AED", convAmt: 120000 },
    { title: "Electricity Bill - HO", category: "utilities", amount: 12500, paidTo: "LESCO", method: "online", branch: BR_HO },
    { title: "Internet & Phone", category: "utilities", amount: 8500, paidTo: "PTCL", method: "online", branch: BR_HO },
    { title: "Staff Salaries - July", category: "salary", amount: 450000, paidTo: "Staff", method: "bank_transfer", branch: BR_HO },
    { title: "Office Supplies", category: "office_supplies", amount: 15000, paidTo: "Stationery Mart", method: "cash", branch: BR_HO },
    { title: "Marketing - Social Media Ads", category: "marketing", amount: 35000, paidTo: "Meta Ads", method: "online", branch: BR_HO },
    { title: "Client Entertainment", category: "entertainment", amount: 22000, paidTo: "Restaurant", method: "card", branch: BR_HO },
    { title: "Car Fuel - Manager", category: "transport", amount: 8000, paidTo: "PSO", method: "cash", branch: BR_HO },
    { title: "Website Hosting", category: "technology", amount: 5500, paidTo: "AWS", method: "online", branch: BR_HO },
    { title: "Insurance Premium", category: "insurance", amount: 45000, paidTo: "State Life Insurance", method: "cheque", branch: BR_HO },
    { title: "Staff Training Workshop", category: "training", amount: 28000, paidTo: "Travel Academy", method: "bank_transfer", branch: BR_HO },
  ];

  const expIds: string[] = [];
  for (let i = 0; i < expenses.length; i++) {
    const eid = `ex${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    expIds.push(eid);
    const e = expenses[i];
    await prisma.expense.create({
      data: {
        id: eid, agencyId: AGENCY_ID, branchId: e.branch,
        expenseRef: `EXP-2026-${String(i + 1).padStart(3, "0")}`,
        title: e.title, category: e.category, amount: e.amount,
        date: daysAgo(28 - i * 2),
        paidTo: e.paidTo, paymentMethod: e.method,
        recordedById: U_ACCT, status: "approved",
      },
    });
  }
  console.log(`Expenses: ${expenses.length}`);

  // ═══════════════════════════════════════════
  // 12. RECEIPTS
  // ═══════════════════════════════════════════
  const receipts = [
    { booking: 0, cust: custIds[0], amount: 225000, method: "bank_transfer", days: 22 },
    { booking: 1, cust: custIds[2], amount: 48000, method: "cash", days: 4 },
    { booking: 2, cust: custIds[4], amount: 150000, method: "bank_transfer", days: 18 },
    { booking: 3, cust: custIds[1], amount: 70000, method: "card", days: 20 },
    { booking: 5, cust: custIds[3], amount: 195000, method: "bank_transfer", days: 8 },
    { booking: 6, cust: custIds[7], amount: 100000, method: "bank_transfer", days: 16 },
    { booking: 7, cust: custIds[8], amount: 65000, method: "cash", days: 5 },
    { booking: 8, cust: custIds[6], amount: 88000, method: "online", days: 10 },
    { booking: 10, cust: custIds[11], amount: 100000, method: "bank_transfer", days: 35 },
    { booking: 11, cust: custIds[10], amount: 38000, method: "cash", days: 2 },
  ];

  for (let i = 0; i < receipts.length; i++) {
    const rid = `rc${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    const r = receipts[i];
    await prisma.receipt.create({
      data: {
        id: rid, agencyId: AGENCY_ID, branchId: BR_HO,
        receiptRef: `RCP-2026-${String(i + 1).padStart(3, "0")}`,
        bookingId: bookIds[r.booking], customerId: r.cust,
        amount: r.amount, paymentMethod: r.method,
        date: daysAgo(r.days),
        notes: i === 0 ? "Full payment received via bank transfer" : null,
      },
    });
  }
  console.log(`Receipts: ${receipts.length}`);

  // ═══════════════════════════════════════════
  // 13. INVOICES
  // ═══════════════════════════════════════════
  for (let i = 0; i < 6; i++) {
    const iid = `iv${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    const bi = i < bookings.length ? i : i - 2;
    const cust = i < 4 ? custIds[bi] : custIds[i + 2];
    const total = bookings[bi].sale;
    const tax = Math.round(total * 0.0);
    const invoice = await prisma.invoice.create({
      data: {
        id: iid, agencyId: AGENCY_ID, branchId: BR_HO,
        invoiceRef: `INV-2026-${String(i + 1).padStart(3, "0")}`,
        bookingId: bookIds[bi], customerId: cust,
        subtotal: total, tax, total,
        status: i < 3 ? "paid" : i < 5 ? "sent" : "draft",
        dueDate: futureDate(30 - i * 5),
        paidAt: i < 3 ? daysAgo(20 - i * 3) : null,
        notes: "Thank you for your business",
        items: {
          create: [{
            agencyId: AGENCY_ID,
            description: `Flight Booking - ${bookings[bi].airline} (${bookings[bi].from} to ${bookings[bi].to})`,
            quantity: 1, unitPrice: total, amount: total,
          }],
        },
      },
    });
  }
  console.log("Invoices: 6");

  // ═══════════════════════════════════════════
  // 14. QUOTATIONS
  // ═══════════════════════════════════════════
  const quotations = [
    { num: "QT-2026-001", title: "London Family Holiday", dest: "London", travel: "leisure", cust: custIds[0], status: "accepted", total: 450000, sub: 410000, tax: 0, fee: 25000, disc: 15000, profit: 45000 },
    { num: "QT-2026-002", title: "Istanbul Romantic Getaway", dest: "Istanbul", travel: "leisure", cust: custIds[1], status: "sent", total: 265000, sub: 240000, tax: 0, fee: 15000, disc: 10000, profit: 32000 },
    { num: "QT-2026-003", title: "Maldives Honeymoon", dest: "Maldives", travel: "honeymoon", cust: custIds[7], status: "accepted", total: 620000, sub: 580000, tax: 0, fee: 25000, disc: 0, profit: 68000 },
    { num: "QT-2026-004", title: "Umrah Package - Family", dest: "Makkah", travel: "religious", cust: custIds[3], status: "negotiation", total: 380000, sub: 350000, tax: 0, fee: 20000, disc: 10000, profit: 35000 },
    { num: "QT-2026-005", title: "Paris Tour - 2 Weeks", dest: "Paris", travel: "leisure", cust: custIds[5], status: "draft", total: 520000, sub: 480000, tax: 0, fee: 25000, disc: 15000, profit: 55000 },
    { num: "QT-2026-006", title: "Dubai Shopping Festival", dest: "Dubai", travel: "leisure", cust: custIds[9], status: "sent", total: 185000, sub: 170000, tax: 0, fee: 10000, disc: 5000, profit: 22000 },
    { num: "QT-2026-007", title: "Northern Areas Adventure", dest: "Gilgit-Baltistan", travel: "adventure", cust: custIds[8], status: "accepted", total: 125000, sub: 115000, tax: 0, fee: 8000, disc: 3000, profit: 18000 },
    { num: "QT-2026-008", title: "China Business Trip", dest: "Shanghai", travel: "business", cust: custIds[2], status: "rejected", total: 350000, sub: 320000, tax: 0, fee: 20000, disc: 10000, profit: 28000 },
  ];

  const quotIds: string[] = [];
  for (let i = 0; i < quotations.length; i++) {
    const qid = `qt${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    quotIds.push(qid);
    const q = quotations[i];
    await prisma.quotation.create({
      data: {
        id: qid, agencyId: AGENCY_ID,
        quotationNumber: q.num, title: q.title,
        customerId: q.cust, branchId: BR_HO,
        consultantId: i % 2 === 0 ? U_AGENT1 : U_AGENT2,
        travelType: q.travel, destination: q.dest,
        departureDate: futureDate(30 + i * 10),
        returnDate: futureDate(37 + i * 10),
        adults: 2, children: i === 6 ? 2 : 0, infants: 0,
        currency: "PKR",
        subtotal: q.sub, agencyFee: q.fee, discount: q.disc,
        taxTotal: q.tax, total: q.total, estimatedProfit: q.profit,
        status: q.status,
        validUntil: futureDate(60),
        customerNotes: "Looking forward to this trip!",
        internalNotes: i === 0 ? "VIP customer - priority" : null,
        terms: "Payment due within 14 days of confirmation. Cancellation charges apply as per policy.",
        items: {
          create: [
            { agencyId: AGENCY_ID, serviceCategory: "flight", title: "Return Flights", quantity: q.dest === "Makkah" ? 4 : 2, unit: "Person", costPrice: q.sub * 0.6 / (q.dest === "Makkah" ? 4 : 2), sellingPrice: q.sub * 0.7 / (q.dest === "Makkah" ? 4 : 2), total: q.sub * 0.7, sortOrder: 0 },
            { agencyId: AGENCY_ID, serviceCategory: "hotel", title: "Hotel Accommodation", quantity: 7, unit: "Night", costPrice: q.sub * 0.25 / 7, sellingPrice: q.sub * 0.25 / 7, total: q.sub * 0.25, sortOrder: 1 },
            { agencyId: AGENCY_ID, serviceCategory: "transfer", title: "Airport Transfers", quantity: 2, unit: "Trip", costPrice: 5000, sellingPrice: 8000, total: 16000, sortOrder: 2 },
          ],
        },
        taxes: {
          create: q.tax > 0 ? [
            { agencyId: AGENCY_ID, taxName: "GST", taxType: "percentage", taxValue: 0, taxAmount: 0 },
          ] : [],
        },
        versions: {
          create: [
            { agencyId: AGENCY_ID, version: 1, changes: "Created quotation", createdBy: i % 2 === 0 ? U_AGENT1 : U_AGENT2 },
            ...(q.status !== "draft" ? [{ agencyId: AGENCY_ID, version: 2, changes: "Quotation sent to client", createdBy: i % 2 === 0 ? U_AGENT1 : U_AGENT2 }] : []),
            ...(q.status === "accepted" ? [{ agencyId: AGENCY_ID, version: 3, changes: "Quotation accepted by client", createdBy: i % 2 === 0 ? U_AGENT1 : U_AGENT2 }] : []),
          ],
        },
      },
    });
  }
  console.log(`Quotations: ${quotations.length}`);

  // ═══════════════════════════════════════════
  // 15. TEMPLATES
  // ═══════════════════════════════════════════
  await prisma.template.createMany({
    data: [
      { agencyId: AGENCY_ID, name: "Default Quotation Notes", type: "quotation_notes", content: "Thank you for choosing TripTrails Travel Agency. This quotation is valid for 30 days from the date of issue. Prices are subject to availability and may change without prior notice. All prices are in PKR unless otherwise specified." },
      { agencyId: AGENCY_ID, name: "Standard Terms & Conditions", type: "quotation_terms", content: "1. Full payment required 14 days before departure.\n2. Cancellation charges: 30 days (10%), 15 days (25%), 7 days (50%), No-show (100%).\n3. Passport must be valid for 6 months beyond travel date.\n4. Travel insurance is mandatory and included in the package.\n5. Hotel check-in/out times are subject to hotel policy.\n6. Meal plans start from lunch on Day 1 and end at breakfast on the last day." },
      { agencyId: AGENCY_ID, name: "Default Invoice Notes", type: "invoice_notes", content: "Payment is due within 30 days of invoice date. Late payments will incur a 2% monthly surcharge. For payments via bank transfer, please reference the invoice number in the transfer description." },
      { agencyId: AGENCY_ID, name: "Standard Invoice Terms", type: "invoice_terms", content: "Payment Methods: Bank Transfer, Cash, Online Payment.\nAll amounts are in PKR.\nFor queries, contact accounts@trails.pk or call +92-42-35789012." },
      { agencyId: AGENCY_ID, name: "Umrah Package Notes", type: "quotation_notes", content: "Umrah package includes: Return flights, Hotel accommodation (Makkah & Madinah), Ground transfers, Visa processing, and Ziyarat tours. Zodiac/Cisco accommodation subject to availability." },
    ],
  });
  console.log("Templates: 5");

  // ═══════════════════════════════════════════
  // 16. NOTIFICATIONS
  // ═══════════════════════════════════════════
  await prisma.notification.createMany({
    data: [
      { agencyId: AGENCY_ID, recipientId: U_MANAGER1, type: "success", title: "New Booking Created", body: "BK-2026-001 created by Ayesha Malik", entityType: "booking", isRead: true },
      { agencyId: AGENCY_ID, recipientId: U_MANAGER1, type: "info", title: "New Lead Assigned", body: "Zubair Ahmed assigned to Ayesha Malik", entityType: "lead", isRead: true },
      { agencyId: AGENCY_ID, recipientId: U_AGENT1, type: "success", title: "Payment Received", body: "Receipt RCP-2026-001 for Rs 225,000", entityType: "receipt", isRead: false },
      { agencyId: AGENCY_ID, recipientId: U_AGENT2, type: "warning", title: "Quotation Expiring", body: "QT-2026-002 expires in 3 days", entityType: "quotation", isRead: false },
      { agencyId: AGENCY_ID, recipientId: U_AGENT3, type: "info", title: "Payment Received", body: "Partial payment of Rs 150,000 for BK-2026-003", entityType: "receipt", isRead: false },
      { agencyId: AGENCY_ID, recipientId: U_ADMIN, type: "error", title: "Payment Overdue", body: "BK-2026-005 payment is overdue", entityType: "booking", isRead: false },
    ],
  });
  console.log("Notifications: 6");

  // ═══════════════════════════════════════════
  // 17. RECENT ACTIVITIES
  // ═══════════════════════════════════════════
  await prisma.recentActivity.createMany({
    data: [
      { agencyId: AGENCY_ID, type: "booking", title: "Booking Created", detail: "BK-2026-001 - London trip for Ahmed Khan", createdBy: "Ayesha Malik", createdAt: daysAgo(25) },
      { agencyId: AGENCY_ID, type: "receipt", title: "Payment Received", detail: "Rs 225,000 from Ahmed Khan (RCP-2026-001)", createdBy: "Zainab Noor", createdAt: daysAgo(22) },
      { agencyId: AGENCY_ID, type: "booking", title: "Booking Created", detail: "BK-2026-002 - Karachi trip for Ali & Sons", createdBy: "Hassan Raza", createdAt: daysAgo(15) },
      { agencyId: AGENCY_ID, type: "lead", title: "New Lead", detail: "Zubair Ahmed - London inquiry", createdBy: "Ayesha Malik", createdAt: daysAgo(20) },
      { agencyId: AGENCY_ID, type: "payment", title: "Payment to Supplier", detail: "Rs 185,000 to Emirates Airlines", createdBy: "Zainab Noor", createdAt: daysAgo(18) },
      { agencyId: AGENCY_ID, type: "expense", title: "Expense Recorded", detail: "Office Rent Lahore - Rs 85,000", createdBy: "Zainab Noor", createdAt: daysAgo(28) },
      { agencyId: AGENCY_ID, type: "quotation", title: "Quotation Sent", detail: "QT-2026-002 sent to Fatima Zahra", createdBy: "Hassan Raza", createdAt: daysAgo(12) },
      { agencyId: AGENCY_ID, type: "booking", title: "Booking Created", detail: "BK-2026-003 - Dubai-London for Tariq Mahmood", createdBy: "Fatima Hussain", createdAt: daysAgo(18) },
      { agencyId: AGENCY_ID, type: "receipt", title: "Payment Received", detail: "Rs 150,000 from Tariq Mahmood (RCP-2026-003)", createdBy: "Omar Farooq", createdAt: daysAgo(16) },
      { agencyId: AGENCY_ID, type: "quotation", title: "Quotation Accepted", detail: "QT-2026-003 accepted by Amina Rashid", createdBy: "Fatima Hussain", createdAt: daysAgo(14) },
    ],
  });
  console.log("Recent activities: 10");

  // ═══════════════════════════════════════════
  // 18. CHART OF ACCOUNTS
  // ═══════════════════════════════════════════
  const coaAccounts = [
    // Assets
    { code: "1000", name: "Cash & Bank", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "1100", name: "Accounts Receivable", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance },
    { code: "1200", name: "Prepaid Expenses", type: "ASSET" as AccountType, normal: "DEBIT" as NormalBalance },
    // Liabilities
    { code: "2000", name: "Accounts Payable", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "2100", name: "Unearned Revenue", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "2200", name: "Tax Payable", type: "LIABILITY" as AccountType, normal: "CREDIT" as NormalBalance },
    // Equity
    { code: "3000", name: "Owner's Equity", type: "EQUITY" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "3100", name: "Retained Earnings", type: "EQUITY" as AccountType, normal: "CREDIT" as NormalBalance },
    // Revenue
    { code: "4000", name: "Flight Booking Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4100", name: "Hotel Booking Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4200", name: "Visa Service Revenue", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    { code: "4300", name: "Insurance Commission", type: "REVENUE" as AccountType, normal: "CREDIT" as NormalBalance },
    // Expenses
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
    const aid = `coa${String(i + 1).padStart(3, "0")}0000-0000-0000-0000-000000000001`;
    coaIds.push(aid);
    const a = coaAccounts[i];
    await prisma.chartOfAccount.create({
      data: {
        id: aid, agencyId: AGENCY_ID, code: a.code, name: a.name,
        type: a.type, normalBalance: a.normal, isActive: true,
      },
    });
  }
  console.log(`Chart of Accounts: ${coaAccounts.length}`);

  // ═══════════════════════════════════════════
  // 19. FISCAL PERIODS
  // ═══════════════════════════════════════════
  await prisma.fiscalPeriod.createMany({
    data: [
      { id: "fp0010000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, name: "FY 2025-2026", startDate: new Date("2025-07-01"), endDate: new Date("2026-06-30"), status: "CLOSED" },
      { id: "fp0010000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, name: "FY 2026-2027", startDate: new Date("2026-07-01"), endDate: new Date("2027-06-30"), status: "OPEN" },
    ],
  });
  console.log("Fiscal periods: 2");

  // ═══════════════════════════════════════════
  // 20. JOURNAL ENTRIES
  // ═══════════════════════════════════════════
  // Entry 1: Booking revenue
  const je1 = await prisma.journalEntry.create({
    data: {
      id: "je0010000-0000-0000-0000-000000000001",
      agencyId: AGENCY_ID, branchId: BR_HO,
      entryNumber: "JE-2026-001", date: daysAgo(22),
      description: "Revenue from BK-2026-001 - London trip",
      status: "POSTED", sourceModule: "BOOKING", sourceId: bookIds[0],
      createdBy: U_ADMIN, postedAt: daysAgo(22),
    },
  });

  await prisma.journalLine.createMany({
    data: [
      { id: "jl0010000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, journalEntryId: je1.id, accountId: coaIds[1], debit: 225000, credit: 0, currency: "PKR", exchangeRate: 1, baseDebit: 225000, baseCredit: 0, description: "AR from Ahmed Khan" },
      { id: "jl0010000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, journalEntryId: je1.id, accountId: coaIds[8], debit: 0, credit: 225000, currency: "PKR", exchangeRate: 1, baseDebit: 0, baseCredit: 225000, description: "Flight booking revenue" },
    ],
  });

  // Entry 2: Payment received
  const je2 = await prisma.journalEntry.create({
    data: {
      id: "je0010000-0000-0000-0000-000000000002",
      agencyId: AGENCY_ID, branchId: BR_HO,
      entryNumber: "JE-2026-002", date: daysAgo(20),
      description: "Payment received from Ahmed Khan",
      status: "POSTED", sourceModule: "RECEIPT", sourceId: "rc0010000-0000-0000-0000-000000000001",
      createdBy: U_ACCT, postedAt: daysAgo(20),
    },
  });

  await prisma.journalLine.createMany({
    data: [
      { id: "jl0020000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, journalEntryId: je2.id, accountId: coaIds[0], debit: 225000, credit: 0, currency: "PKR", exchangeRate: 1, baseDebit: 225000, baseCredit: 0, description: "Bank transfer received" },
      { id: "jl0020000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, journalEntryId: je2.id, accountId: coaIds[1], debit: 0, credit: 225000, currency: "PKR", exchangeRate: 1, baseDebit: 0, baseCredit: 225000, description: "Clear AR - Ahmed Khan" },
    ],
  });

  // Entry 3: Office rent expense
  const je3 = await prisma.journalEntry.create({
    data: {
      id: "je0010000-0000-0000-0000-000000000003",
      agencyId: AGENCY_ID, branchId: BR_HO,
      entryNumber: "JE-2026-003", date: daysAgo(28),
      description: "Office rent payment - July 2026",
      status: "POSTED", sourceModule: "EXPENSE", sourceId: expIds[0],
      createdBy: U_ACCT, postedAt: daysAgo(28),
    },
  });

  await prisma.journalLine.createMany({
    data: [
      { id: "jl0030000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, journalEntryId: je3.id, accountId: coaIds[14], debit: 85000, credit: 0, currency: "PKR", exchangeRate: 1, baseDebit: 85000, baseCredit: 0, description: "Office rent expense" },
      { id: "jl0030000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, journalEntryId: je3.id, accountId: coaIds[0], debit: 0, credit: 85000, currency: "PKR", exchangeRate: 1, baseDebit: 0, baseCredit: 85000, description: "Cash outflow" },
    ],
  });

  // Entry 4: Salary expense
  const je4 = await prisma.journalEntry.create({
    data: {
      id: "je0010000-0000-0000-0000-000000000004",
      agencyId: AGENCY_ID, branchId: BR_HO,
      entryNumber: "JE-2026-004", date: daysAgo(18),
      description: "Staff salaries - July 2026",
      status: "POSTED", sourceModule: "EXPENSE", sourceId: expIds[4],
      createdBy: U_ACCT, postedAt: daysAgo(18),
    },
  });

  await prisma.journalLine.createMany({
    data: [
      { id: "jl0040000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, journalEntryId: je4.id, accountId: coaIds[15], debit: 450000, credit: 0, currency: "PKR", exchangeRate: 1, baseDebit: 450000, baseCredit: 0, description: "Staff salaries for July" },
      { id: "jl0040000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, journalEntryId: je4.id, accountId: coaIds[0], debit: 0, credit: 450000, currency: "PKR", exchangeRate: 1, baseDebit: 0, baseCredit: 450000, description: "Bank transfer - salary disbursement" },
    ],
  });

  // Entry 5: Draft entry (not posted yet)
  const je5 = await prisma.journalEntry.create({
    data: {
      id: "je0010000-0000-0000-0000-000000000005",
      agencyId: AGENCY_ID, branchId: BR_HO,
      entryNumber: "JE-2026-005", date: daysAgo(2),
      description: "Marketing expense - pending approval",
      status: "DRAFT", sourceModule: "EXPENSE", sourceId: expIds[6],
      createdBy: U_ACCT,
    },
  });

  await prisma.journalLine.createMany({
    data: [
      { id: "jl0050000-0000-0000-0000-000000000001", agencyId: AGENCY_ID, journalEntryId: je5.id, accountId: coaIds[16], debit: 35000, credit: 0, currency: "PKR", exchangeRate: 1, baseDebit: 35000, baseCredit: 0, description: "Facebook/Instagram ads" },
      { id: "jl0050000-0000-0000-0000-000000000002", agencyId: AGENCY_ID, journalEntryId: je5.id, accountId: coaIds[0], debit: 0, credit: 35000, currency: "PKR", exchangeRate: 1, baseDebit: 0, baseCredit: 35000, description: "Online payment" },
    ],
  });

  console.log("Journal entries: 5 (4 posted, 1 draft)");

  // ═══════════════════════════════════════════
  // 21. COUNTERS (for ref generation)
  // ═══════════════════════════════════════════
  await prisma.counter.createMany({
    data: [
      { id: `BK_${AGENCY_ID}_2026`, seq: 12 },
      { id: `LD_${AGENCY_ID}_2026`, seq: 18 },
      { id: `CUS_${AGENCY_ID}_2026`, seq: 15 },
      { id: `SUP_${AGENCY_ID}_2026`, seq: 0 },
      { id: `EXP_${AGENCY_ID}_2026`, seq: 12 },
      { id: `RCP_${AGENCY_ID}_2026`, seq: 10 },
      { id: `INV_${AGENCY_ID}_2026`, seq: 6 },
    ],
  });
  console.log("Counters: 7");

  // ═══════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════
  console.log("\n=== SEED COMPLETE ===");
  console.log(`Agency:        1 (TripTrails Travel Agency)`);
  console.log(`Branches:      3 (Lahore HQ, Dubai, Karachi)`);
  console.log(`Roles:         4 (admin, manager, agent, accountant)`);
  console.log(`Users:         8`);
  console.log(`Customers:     ${customers.length}`);
  console.log(`Customer Notes: 9`);
  console.log(`Customer Docs: 5`);
  console.log(`Suppliers:     ${suppliers.length}`);
  console.log(`Leads:         ${leads.length}`);
  console.log(`Lead Activities: ${activities.length}`);
  console.log(`Bookings:      ${bookings.length}`);
  console.log(`Booking Activities: ${bActivities.length}`);
  console.log(`Booking Docs:  5`);
  console.log(`Expenses:      ${expenses.length}`);
  console.log(`Receipts:      ${receipts.length}`);
  console.log(`Invoices:      6`);
  console.log(`Quotations:    ${quotations.length}`);
  console.log(`Templates:     5`);
  console.log(`Notifications: 6`);
  console.log(`Recent Activities: 10`);
  console.log(`Chart of Accounts: ${coaAccounts.length}`);
  console.log(`Fiscal Periods: 2`);
  console.log(`Journal Entries: 5 (with 10 journal lines)`);
  console.log(`Counters:      7`);
  console.log(`\nLogin credentials:`);
  console.log(`  Admin:      admin@trails.pk      / admin123`);
  console.log(`  Manager HO: sara@trails.pk       / admin123`);
  console.log(`  Manager DXB: omar@trails.pk      / admin123`);
  console.log(`  Agent HO:   ayesha@trails.pk     / admin123`);
  console.log(`  Agent HO2:  hassan@trails.pk     / admin123`);
  console.log(`  Agent DXB:  fatima@trails.pk     / admin123`);
  console.log(`  Agent KHI:  usman@trails.pk      / admin123`);
  console.log(`  Accountant: zainab@trails.pk     / admin123`);
}

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
