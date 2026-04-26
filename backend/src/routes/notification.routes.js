const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const {
  notificationQuerySchema,
  notificationIdParamSchema,
} = require('../validations/notification.validation');

// GET /api/v1/notifications (protected)
router.get(
  '/',
  authenticate,
  validate({ query: notificationQuerySchema }),
  notificationController.listNotifications
);

// PATCH /api/v1/notifications/read-all (protected) — harus di atas /:id
router.patch(
  '/read-all',
  authenticate,
  notificationController.markAllAsRead
);

// PATCH /api/v1/notifications/:id/read (protected)
router.patch(
  '/:id/read',
  authenticate,
  validate({ params: notificationIdParamSchema }),
  notificationController.markAsRead
);

module.exports = router;
