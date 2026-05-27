import { Router } from 'express';
import { UserController } from './user.controller';
import { authenticateToken } from '../../middlewares/auth.middleware';
import { uploadProfile } from '../../middlewares/upload.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { updateProfileSchema } from './user.schema';

const router = Router();

// Get current user profile
router.get('/profile', authenticateToken, UserController.getProfile);

// Update profile (with photo upload)
router.put(
  '/profile',
  authenticateToken,
  uploadProfile.single('photo'),
  validate(updateProfileSchema),
  UserController.updateProfile
);

export default router;
