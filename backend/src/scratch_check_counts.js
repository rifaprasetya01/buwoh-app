const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkCounts() {
  const users = await prisma.user.findMany({
    include: {
      _count: {
        select: { eventsHosted: true }
      }
    }
  });

  console.log('--- USER STATS CHECK ---');
  for (const user of users) {
    const hostedCount = await prisma.event.count({
      where: { hostId: user.id, deletedAt: null }
    });
    console.log(`User: ${user.name} (${user.id})`);
    console.log(`  Events Hosted (prisma count): ${hostedCount}`);
    console.log(`  Events Hosted (relation count): ${user._count.eventsHosted}`);
  }

  const allEvents = await prisma.event.findMany({
    select: { id: true, title: true, hostId: true }
  });
  console.log('\n--- ALL EVENTS ---');
  console.log(allEvents);
}

checkCounts()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
