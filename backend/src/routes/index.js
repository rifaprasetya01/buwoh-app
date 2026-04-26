const express = require('express');
const router = express.Router();

// Import all route modules
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const eventRoutes = require('./event.routes');
const eventGuestRoutes = require('./eventGuest.routes');
const guestGiftRoutes = require('./guestGift.routes');
const giftCategoryRoutes = require('./giftCategory.routes');
const eventCategoryRoutes = require('./eventCategory.routes');
const notificationRoutes = require('./notification.routes');

// Health check
router.get('/health', (_req, res) => {
  res.status(200).json({
    success: true,
    message: '🚀 Buwoh API is running!',
    timestamp: new Date().toISOString(),
  });
});

// Mount routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/events', eventRoutes);
router.use('/events/:eventId/guests', eventGuestRoutes);
router.use('/guests/:guestId/gifts', guestGiftRoutes);
router.use('/gift-categories', giftCategoryRoutes);
router.use('/event-categories', eventCategoryRoutes);
router.use('/notifications', notificationRoutes);

module.exports = router;
