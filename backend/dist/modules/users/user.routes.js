"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const user_controller_1 = require("./user.controller");
const auth_middleware_1 = require("../../middlewares/auth.middleware");
const upload_middleware_1 = require("../../middlewares/upload.middleware");
const validate_middleware_1 = require("../../middlewares/validate.middleware");
const user_schema_1 = require("./user.schema");
const router = (0, express_1.Router)();
// Get current user profile
router.get('/profile', auth_middleware_1.authenticateToken, user_controller_1.UserController.getProfile);
// Update profile (with photo upload)
router.put('/profile', auth_middleware_1.authenticateToken, upload_middleware_1.uploadProfile.single('photo'), (0, validate_middleware_1.validate)(user_schema_1.updateProfileSchema), user_controller_1.UserController.updateProfile);
exports.default = router;
