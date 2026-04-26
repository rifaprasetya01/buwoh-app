const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const eventCategoryService = require('../services/eventCategory.service');

/**
 * GET /api/v1/event-categories
 */
const listEventCategories = catchAsync(async (_req, res) => {
  const categories = await eventCategoryService.listEventCategories();
  ApiResponse.success(res, 200, 'Daftar kategori acara berhasil diambil.', categories);
});

module.exports = {
  listEventCategories,
};
