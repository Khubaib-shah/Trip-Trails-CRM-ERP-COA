import { prisma } from "./lib/prisma";
import { processAmortizations } from "./services/accounting.service";

async function main() {
  console.log("Starting Daily Amortization Processing...");
  try {
    const agencies = await prisma.agency.findMany({ where: { status: "active", isDeleted: false } });
    
    let totalProcessed = 0;
    let totalErrors = 0;

    for (const agency of agencies) {
      console.log(`Processing amortizations for agency ${agency.name} (${agency.id})...`);
      const result = await processAmortizations(agency.id);
      totalProcessed += result.processed;
      totalErrors += result.errors;
    }

    console.log(`Amortization processing complete. Processed: ${totalProcessed}, Errors: ${totalErrors}`);
  } catch (error) {
    console.error("Critical error in amortization processing:", error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

if (require.main === module) {
  main();
}
