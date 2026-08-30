const { PrismaClient } = require("@prisma/client");
const p = new PrismaClient();

async function main() {
  const users = await p.user.findMany({
    select: { id: true, email: true, role: true, status: true, agencyId: true, branchId: true, password: true }
  });
  console.log("User count:", users.length);
  for (const u of users) {
    console.log(`  ${u.email} | role=${u.role} | status=${u.status} | agency=${u.agencyId} | branch=${u.branchId} | pw_len=${u.password?.length}`);
  }
  await p.$disconnect();
}

main().catch(e => { console.error(e); process.exit(1); });
