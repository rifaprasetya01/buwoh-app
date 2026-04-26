const express = require('express');
const router = express.Router({ mergeParams: true });
const eventGuestController = require('../controllers/eventGuest.controller');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const {
  applyAsGuestSchema,
  updateGuestStatusSchema,
  updateAttendanceSchema,
  eventGuestParamsSchema,
  eventGuestActionParamsSchema,
} = require('../validations/eventGuest.validation');

// POST /api/v1/events/:eventId/guests (protected)
router.post(
  '/',
  authenticate,
  validate({ params: eventGuestParamsSchema, body: applyAsGuestSchema }),
  eventGuestController.applyAsGuest
);

// GET /api/v1/events/:eventId/guests (protected — owner only)
router.get(
  '/',
  authenticate,
  validate({ params: eventGuestParamsSchema }),
  eventGuestController.listEventGuests
);

// PATCH /api/v1/events/:eventId/guests/:guestId/status (protected — owner only)
router.patch(
  '/:guestId/status',
  authenticate,
  validate({ params: eventGuestActionParamsSchema, body: updateGuestStatusSchema }),
  eventGuestController.updateGuestStatus
);

// PATCH /api/v1/events/:eventId/guests/:guestId/attendance (protected — owner only)
router.patch(
  '/:guestId/attendance',
  authenticate,
  validate({ params: eventGuestActionParamsSchema, body: updateAttendanceSchema }),
  eventGuestController.updateAttendance
);

// PATCH /api/v1/events/:eventId/guests/:guestId/verify-gift (protected — owner only)
router.patch(
  '/:guestId/verify-gift',
  authenticate,
  validate({ params: eventGuestActionParamsSchema }),
  eventGuestController.verifyGift
);

module.exports = router;
