const { PrismaClient } = require('@prisma/client'); 
const prisma = new PrismaClient(); 
async function run() { 
  const events = await prisma.event.findMany({ 
    select: { 
      id: true, 
      title: true, 
      status: true, 
      host: { select: { name: true } }, 
      address: { select: { province: true, city: true } } 
    } 
  }); 
  
  const users = await prisma.user.findMany({
    select: {
      name: true,
      address: { select: { province: true, city: true } }
    }
  });

  const guests = await prisma.eventGuest.findMany({
    select: { guest: { select: { name: true } }, event: { select: { title: true } }, status: true }
  });

  console.log("EVENTS:", JSON.stringify(events, null, 2)); 
  console.log("USERS:", JSON.stringify(users, null, 2));
  console.log("GUESTS:", JSON.stringify(guests, null, 2));
} 
run().catch(console.error).finally(() => prisma.$disconnect());
