const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const guestGiftService = require('../services/guestGift.service');

/**
 * POST /api/v1/guests/:guestId/gifts
 */
const addGift = catchAsync(async (req, res) => {
  const gift = await guestGiftService.addGift(
    req.params.guestId,
    req.user.id,
    req.body
  );
  ApiResponse.created(res, 'Bawaan berhasil ditambahkan.', gift);
});

/**
 * GET /api/v1/guests/:guestId/gifts
 */
const listGifts = catchAsync(async (req, res) => {
  const gifts = await guestGiftService.listGifts(req.params.guestId);
  ApiResponse.success(res, 200, 'Daftar bawaan berhasil diambil.', gifts);
});

/**
 * PUT /api/v1/guests/:guestId/gifts/:giftId
 */
const updateGift = catchAsync(async (req, res) => {
  const gift = await guestGiftService.updateGift(
    req.params.guestId,
    req.params.giftId,
    req.user.id,
    req.body
  );
  ApiResponse.success(res, 200, 'Bawaan berhasil diperbarui.', gift);
});

/**
 * DELETE /api/v1/guests/:guestId/gifts/:giftId
 */
const deleteGift = catchAsync(async (req, res) => {
  await guestGiftService.deleteGift(
    req.params.guestId,
    req.params.giftId,
    req.user.id
  );
  ApiResponse.success(res, 200, 'Bawaan berhasil dihapus.');
});

module.exports = {
  addGift,
  listGifts,
  updateGift,
  deleteGift,
};
