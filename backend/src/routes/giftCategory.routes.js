const express = require('express');
const router = express.Router();
const giftCategoryController = require('../controllers/giftCategory.controller');

// GET /api/v1/gift-categories (public)
router.get('/', giftCategoryController.listGiftCategories);

module.exports = router;
