const express = require('express');
const router = express.Router({ mergeParams: true });
const guestGiftController = require('../controllers/guestGift.controller');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const {
  createGiftSchema,
  updateGiftSchema,
  guestGiftParamsSchema,
  giftActionParamsSchema,
} = require('../validations/guestGift.validation');

// POST /api/v1/guests/:guestId/gifts (protected)
router.post(
  '/',
  authenticate,
  validate({ params: guestGiftParamsSchema, body: createGiftSchema }),
  guestGiftController.addGift
);

// GET /api/v1/guests/:guestId/gifts
router.get(
  '/',
  validate({ params: guestGiftParamsSchema }),
  guestGiftController.listGifts
);

// PUT /api/v1/guests/:guestId/gifts/:giftId (protected)
router.put(
  '/:giftId',
  authenticate,
  validate({ params: giftActionParamsSchema, body: updateGiftSchema }),
  guestGiftController.updateGift
);

// DELETE /api/v1/guests/:guestId/gifts/:giftId (protected)
router.delete(
  '/:giftId',
  authenticate,
  validate({ params: giftActionParamsSchema }),
  guestGiftController.deleteGift
);

module.exports = router;
