const express = require('express');
const router = express.Router();
const eventController = require('../controllers/event.controller');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const {
  createEventSchema,
  updateEventSchema,
  updateStatusSchema,
  eventIdParamSchema,
  eventQuerySchema,
} = require('../validations/event.validation');

// POST /api/v1/events (protected)
router.post(
  '/',
  authenticate,
  validate({ body: createEventSchema }),
  eventController.createEvent
);

// GET /api/v1/events (public — list published events)
router.get(
  '/',
  validate({ query: eventQuerySchema }),
  eventController.listPublicEvents
);

// GET /api/v1/events/my-events (protected — user's own events)
router.get(
  '/my-events',
  authenticate,
  validate({ query: eventQuerySchema }),
  eventController.listMyEvents
);

// GET /api/v1/events/:id
router.get(
  '/:id',
  validate({ params: eventIdParamSchema }),
  eventController.getEventById
);

// PUT /api/v1/events/:id (protected)
router.put(
  '/:id',
  authenticate,
  validate({ params: eventIdParamSchema, body: updateEventSchema }),
  eventController.updateEvent
);

// PATCH /api/v1/events/:id/status (protected)
router.patch(
  '/:id/status',
  authenticate,
  validate({ params: eventIdParamSchema, body: updateStatusSchema }),
  eventController.updateStatus
);

// DELETE /api/v1/events/:id (protected)
router.delete(
  '/:id',
  authenticate,
  validate({ params: eventIdParamSchema }),
  eventController.deleteEvent
);

module.exports = router;
