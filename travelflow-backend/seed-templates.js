const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seedTemplates() {
  try {
    const agency = await prisma.agency.findFirst();
    if (!agency) {
      console.error('No agency found to seed templates to.');
      return;
    }

    const templates = [
      // Quotation Terms
      {
        agencyId: agency.id,
        name: 'Standard Quotation Terms',
        type: 'quotation_terms',
        content: '1. This quotation is valid for 15 days from the date of issue.\n2. Fares and availability are subject to change without prior notice.\n3. A 50% advance payment is required to confirm the booking.\n4. Standard cancellation policies apply.'
      },
      {
        agencyId: agency.id,
        name: 'Strict Quotation Terms',
        type: 'quotation_terms',
        content: '1. Quotation valid for 48 hours only.\n2. Fares are strictly non-refundable once booked.\n3. 100% upfront payment required to guarantee rates.'
      },
      
      // Quotation Notes
      {
        agencyId: agency.id,
        name: 'General Greeting Notes',
        type: 'quotation_notes',
        content: 'Thank you for choosing TravelFlow for your upcoming trip! We are excited to present you with this customized travel itinerary.'
      },
      {
        agencyId: agency.id,
        name: 'Visa Requirements Note',
        type: 'quotation_notes',
        content: 'Please note: Visa processing times vary by embassy. Ensure your passport has at least 6 months validity from your date of travel.'
      },

      // Invoice Terms
      {
        agencyId: agency.id,
        name: 'Standard Invoice Terms',
        type: 'invoice_terms',
        content: '1. Payment is due within 7 days of invoice date.\n2. Late payments may incur a 2% penalty charge.\n3. Please include the invoice number as the payment reference.'
      },
      {
        agencyId: agency.id,
        name: 'Corporate Invoice Terms',
        type: 'invoice_terms',
        content: '1. Net 30 days payment terms apply as per corporate agreement.\n2. Make all checks payable to TravelFlow LLC.\n3. For billing inquiries, contact billing@travelflow.com.'
      },

      // Invoice Notes
      {
        agencyId: agency.id,
        name: 'Thank You Note',
        type: 'invoice_notes',
        content: 'Thank you for your business! We hope you had a wonderful trip and look forward to serving you again.'
      },
      {
        agencyId: agency.id,
        name: 'Bank Transfer Instructions',
        type: 'invoice_notes',
        content: 'Bank Transfer Details:\nBank: Global Trust Bank\nAccount Name: TravelFlow LLC\nAccount No: 1234567890\nSWIFT: GBTBXXXX'
      }
    ];

    for (const t of templates) {
      await prisma.template.create({ data: t });
    }

    console.log(`Successfully seeded ${templates.length} templates for agency ${agency.name}`);
  } catch (e) {
    console.error('Error seeding templates:', e);
  } finally {
    await prisma.$disconnect();
  }
}

seedTemplates();
