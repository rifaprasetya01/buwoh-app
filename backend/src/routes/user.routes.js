const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { updateProfileSchema } = require('../validations/auth.validation');

// PUT /api/v1/users/profile (protected)
router.put('/profile', authenticate, validate({ body: updateProfileSchema }), userController.updateProfile);

// GET /api/v1/users/:id
router.get('/:id', userController.getUserById);

module.exports = router;
