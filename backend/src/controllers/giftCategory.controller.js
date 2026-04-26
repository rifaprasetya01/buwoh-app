const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const giftCategoryService = require('../services/giftCategory.service');

/**
 * GET /api/v1/gift-categories
 */
const listGiftCategories = catchAsync(async (_req, res) => {
  const categories = await giftCategoryService.listGiftCategories();
  ApiResponse.success(res, 200, 'Daftar kategori bawaan berhasil diambil.', categories);
});

module.exports = {
  listGiftCategories,
};
