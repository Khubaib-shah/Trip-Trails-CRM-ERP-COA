const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function test() {
  try {
    const filter = { agencyId: '30010000-0000-0000-0000-000000000001', customerId: '40290000-0000-0000-0000-000000000001' };
    
    console.log('Testing customer query...');
    const customer = await prisma.customer.findFirst({ where: filter });
    console.log('Customer:', customer ? customer.firstName + ' ' + customer.lastName : 'NOT FOUND');
    
    console.log('Testing bookings query...');
    const bookings = await prisma.booking.findMany({ where: filter, orderBy: { createdAt: 'asc' } });
    console.log('Bookings:', bookings.length);
    
    console.log('Testing payments query...');
    const payments = await prisma.customerPayment.findMany({ where: filter, orderBy: { date: 'asc' } });
    console.log('Payments:', payments.length);
    
    if (bookings.length > 0) {
      const bookingIds = bookings.map(b => b.id);
      console.log('Testing services query...');
      const services = await prisma.bookingService.findMany({ where: { agencyId: '30010000-0000-0000-0000-000000000001', bookingId: { in: bookingIds } } });
      console.log('Services:', services.length);
    }
    
    console.log('ALL QUERIES PASSED');
  } catch (e) {
    console.error('ERROR:', e.message);
    console.error('CODE:', e.code);
    console.error('STACK:', e.stack);
  } finally {
    await prisma.$disconnect();
  }
}

test();
