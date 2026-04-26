const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // ─── Seed Event Categories ───
  const eventCategories = [
    { name: 'Pernikahan', iconUrl: null },
    { name: 'Khitan', iconUrl: null },
    { name: 'Syukuran', iconUrl: null },
    { name: 'Aqiqah', iconUrl: null },
    { name: 'Sunatan', iconUrl: null },
  ];

  for (const category of eventCategories) {
    await prisma.eventCategory.upsert({
      where: { name: category.name },
      update: {},
      create: category,
    });
  }

  console.log('✅ Event categories seeded successfully');

  // ─── Seed Gift Categories ───
  const giftCategories = [
    { name: 'Beras', unit: 'kg', isMonetary: false, iconUrl: null },
    { name: 'Gula', unit: 'kg', isMonetary: false, iconUrl: null },
    { name: 'Minyak Goreng', unit: 'liter', isMonetary: false, iconUrl: null },
    { name: 'Uang', unit: 'Rp', isMonetary: true, iconUrl: null },
    { name: 'Telur', unit: 'pcs', isMonetary: false, iconUrl: null },
    { name: 'Tepung', unit: 'kg', isMonetary: false, iconUrl: null },
    { name: 'Mie Instan', unit: 'pcs', isMonetary: false, iconUrl: null },
    { name: 'Kopi', unit: 'pcs', isMonetary: false, iconUrl: null },
    { name: 'Teh', unit: 'pcs', isMonetary: false, iconUrl: null },
    { name: 'Susu', unit: 'pcs', isMonetary: false, iconUrl: null },
  ];

  for (const category of giftCategories) {
    await prisma.giftCategory.upsert({
      where: { name: category.name },
      update: {},
      create: category,
    });
  }

  console.log('✅ Gift categories seeded successfully');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('❌ Seed error:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
