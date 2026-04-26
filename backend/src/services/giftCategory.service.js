const prisma = require('../lib/prisma');

/**
 * List semua gift categories
 */
const listGiftCategories = async () => {
  const categories = await prisma.giftCategory.findMany({
    orderBy: { name: 'asc' },
  });
  return categories;
};

module.exports = {
  listGiftCategories,
};
