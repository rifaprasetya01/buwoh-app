const express = require('express');
const router = express.Router();
const eventCategoryController = require('../controllers/eventCategory.controller');

// GET /api/v1/event-categories (public)
router.get('/', eventCategoryController.listEventCategories);

module.exports = router;
