const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const eventService = require('../services/event.service');

/**
 * POST /api/v1/events
 */
const createEvent = catchAsync(async (req, res) => {
  const event = await eventService.createEvent(req.user.id, req.body);
  ApiResponse.created(res, 'Acara berhasil dibuat.', event);
});

/**
 * GET /api/v1/events
 */
const listPublicEvents = catchAsync(async (req, res) => {
  const result = await eventService.listPublicEvents(req.query);
  ApiResponse.paginated(res, 'Daftar acara berhasil diambil.', result.events, result.pagination);
});

/**
 * GET /api/v1/events/my-events
 */
const listMyEvents = catchAsync(async (req, res) => {
  const result = await eventService.listMyEvents(req.user.id, req.query);
  ApiResponse.paginated(res, 'Daftar acara Anda berhasil diambil.', result.events, result.pagination);
});

/**
 * GET /api/v1/events/:id
 */
const getEventById = catchAsync(async (req, res) => {
  const event = await eventService.getEventById(req.params.id);
  ApiResponse.success(res, 200, 'Detail acara berhasil diambil.', event);
});

/**
 * PUT /api/v1/events/:id
 */
const updateEvent = catchAsync(async (req, res) => {
  const event = await eventService.updateEvent(req.params.id, req.user.id, req.body);
  ApiResponse.success(res, 200, 'Acara berhasil diperbarui.', event);
});

/**
 * PATCH /api/v1/events/:id/status
 */
const updateStatus = catchAsync(async (req, res) => {
  const event = await eventService.updateStatus(req.params.id, req.user.id, req.body.status);
  ApiResponse.success(res, 200, 'Status acara berhasil diperbarui.', event);
});

/**
 * DELETE /api/v1/events/:id
 */
const deleteEvent = catchAsync(async (req, res) => {
  await eventService.deleteEvent(req.params.id, req.user.id);
  ApiResponse.success(res, 200, 'Acara berhasil dihapus.');
});

module.exports = {
  createEvent,
  listPublicEvents,
  listMyEvents,
  getEventById,
  updateEvent,
  updateStatus,
  deleteEvent,
};
