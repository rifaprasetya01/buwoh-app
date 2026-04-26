const prisma = require('../lib/prisma');

/**
 * List semua event categories
 */
const listEventCategories = async () => {
  const categories = await prisma.eventCategory.findMany({
    orderBy: { name: 'asc' },
  });
  return categories;
};

module.exports = {
  listEventCategories,
};
