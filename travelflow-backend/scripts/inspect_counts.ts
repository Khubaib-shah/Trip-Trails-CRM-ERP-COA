import { prisma } from "../src/lib/prisma";

async function inspectCounts() {
  const models = [
    { name: "Agency", accessor: "agency" },
    { name: "Branch", accessor: "branch" },
    { name: "User (Staff/Admin)", accessor: "user" },
    { name: "Role", accessor: "role" },
    { name: "Supplier", accessor: "supplier" },
    { name: "ChartOfAccount", accessor: "chartOfAccount" },
    { name: "FiscalPeriod", accessor: "fiscalPeriod" },
    { name: "Template", accessor: "template" },
    { name: "Customer", accessor: "customer" },
    { name: "CustomerNote", accessor: "customerNote" },
    { name: "CustomerDocument", accessor: "customerDocument" },
    { name: "Lead", accessor: "lead" },
    { name: "LeadActivity", accessor: "leadActivity" },
    { name: "Booking", accessor: "booking" },
    { name: "BookingService", accessor: "bookingService" },
    { name: "BookingTraveler", accessor: "bookingTraveler" },
    { name: "BookingDocument", accessor: "bookingDocument" },
    { name: "BookingActivity", accessor: "bookingActivity" },
    { name: "Quotation", accessor: "quotation" },
    { name: "QuotationItem", accessor: "quotationItem" },
    { name: "QuotationTax", accessor: "quotationTax" },
    { name: "QuotationAttachment", accessor: "quotationAttachment" },
    { name: "QuotationVersion", accessor: "quotationVersion" },
    { name: "PaymentSchedule", accessor: "paymentSchedule" },
    { name: "PaymentScheduleItem", accessor: "paymentScheduleItem" },
    { name: "Invoice", accessor: "invoice" },
    { name: "InvoiceLine", accessor: "invoiceLine" },
    { name: "CreditNote", accessor: "creditNote" },
    { name: "CustomerPayment", accessor: "customerPayment" },
    { name: "PaymentAllocation", accessor: "paymentAllocation" },
    { name: "SupplierPayment", accessor: "supplierPayment" },
    { name: "SupplierPaymentAllocation", accessor: "supplierPaymentAllocation" },
    { name: "Expense", accessor: "expense" },
    { name: "AmortizationSchedule", accessor: "amortizationSchedule" },
    { name: "AmortizationScheduleItem", accessor: "amortizationScheduleItem" },
    { name: "JournalEntry", accessor: "journalEntry" },
    { name: "JournalLine", accessor: "journalLine" },
    { name: "Notification", accessor: "notification" },
    { name: "RecentActivity", accessor: "recentActivity" },
    { name: "Counter", accessor: "counter" },
  ];

  console.log("=== CURRENT DATABASE TABLE ROW COUNTS ===");
  for (const m of models) {
    try {
      const count = await (prisma as any)[m.accessor].count();
      console.log(`${m.name.padEnd(30)}: ${count}`);
    } catch (err: any) {
      console.log(`${m.name.padEnd(30)}: Error (${err.message.split("\n")[0]})`);
    }
  }
}

inspectCounts()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
