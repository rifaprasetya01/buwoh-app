const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const eventGuestService = require('../services/eventGuest.service');

/**
 * POST /api/v1/events/:eventId/guests
 */
const applyAsGuest = catchAsync(async (req, res) => {
  const guest = await eventGuestService.applyAsGuest(
    req.params.eventId,
    req.user.id,
    req.body
  );
  ApiResponse.created(res, 'Pengajuan berhasil dikirim.', guest);
});

/**
 * GET /api/v1/events/:eventId/guests
 */
const listEventGuests = catchAsync(async (req, res) => {
  const guests = await eventGuestService.listEventGuests(
    req.params.eventId,
    req.user.id
  );
  ApiResponse.success(res, 200, 'Daftar tamu berhasil diambil.', guests);
});

/**
 * PATCH /api/v1/events/:eventId/guests/:guestId/status
 */
const updateGuestStatus = catchAsync(async (req, res) => {
  const guest = await eventGuestService.updateGuestStatus(
    req.params.eventId,
    req.params.guestId,
    req.user.id,
    req.body
  );
  ApiResponse.success(res, 200, 'Status pengajuan berhasil diperbarui.', guest);
});

/**
 * PATCH /api/v1/events/:eventId/guests/:guestId/attendance
 */
const updateAttendance = catchAsync(async (req, res) => {
  const guest = await eventGuestService.updateAttendance(
    req.params.eventId,
    req.params.guestId,
    req.user.id,
    req.body
  );
  ApiResponse.success(res, 200, 'Status kehadiran berhasil diperbarui.', guest);
});

/**
 * PATCH /api/v1/events/:eventId/guests/:guestId/verify-gift
 */
const verifyGift = catchAsync(async (req, res) => {
  const guest = await eventGuestService.verifyGift(
    req.params.eventId,
    req.params.guestId,
    req.user.id
  );
  ApiResponse.success(res, 200, 'Bawaan berhasil diverifikasi.', guest);
});

module.exports = {
  applyAsGuest,
  listEventGuests,
  updateGuestStatus,
  updateAttendance,
  verifyGift,
};
