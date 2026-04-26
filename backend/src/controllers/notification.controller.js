const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const notificationService = require('../services/notification.service');

/**
 * GET /api/v1/notifications
 */
const listNotifications = catchAsync(async (req, res) => {
  const result = await notificationService.listNotifications(req.user.id, req.query);
  ApiResponse.success(res, 200, 'Daftar notifikasi berhasil diambil.', {
    notifications: result.notifications,
    unreadCount: result.unreadCount,
    pagination: result.pagination,
  });
});

/**
 * PATCH /api/v1/notifications/:id/read
 */
const markAsRead = catchAsync(async (req, res) => {
  const notif = await notificationService.markAsRead(req.params.id, req.user.id);
  ApiResponse.success(res, 200, 'Notifikasi ditandai sudah dibaca.', notif);
});

/**
 * PATCH /api/v1/notifications/read-all
 */
const markAllAsRead = catchAsync(async (req, res) => {
  await notificationService.markAllAsRead(req.user.id);
  ApiResponse.success(res, 200, 'Semua notifikasi ditandai sudah dibaca.');
});

module.exports = {
  listNotifications,
  markAsRead,
  markAllAsRead,
};
