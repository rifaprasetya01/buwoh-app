const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { registerSchema, loginSchema } = require('../validations/auth.validation');

// POST /api/v1/auth/register
router.post('/register', validate({ body: registerSchema }), authController.register);

// POST /api/v1/auth/login
router.post('/login', validate({ body: loginSchema }), authController.login);

// GET /api/v1/auth/me (protected)
router.get('/me', authenticate, authController.getMe);

module.exports = router;
