const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function deleteBooking() {
  const id = '890D1E93-B218-4A68-B747-847EE7A4E390';
  try {
    await prisma.booking.update({
      where: { id: id },
      data: { isDeleted: true, deletedAt: new Date() }
    });
    console.log('Successfully soft-deleted booking', id);
  } catch (e) {
    console.error('Error deleting booking', e);
  } finally {
    await prisma.$disconnect();
  }
}

deleteBooking();
