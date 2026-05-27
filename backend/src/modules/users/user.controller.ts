import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import { UserService } from './user.service';

export class UserController {
  static async getProfile(req: AuthenticatedRequest, res: Response) {
    try {
      const userId = req.user!.id;
      const profile = await UserService.getProfile(userId);
      res.status(200).json(profile);
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching profile', error: error.message });
    }
  }

  static async updateProfile(req: AuthenticatedRequest, res: Response) {
    try {
      const userId = req.user!.id;
      
      // If address is sent as a JSON string in multipart, parse it
      let bodyData = req.body;
      if (typeof bodyData.address === 'string') {
        try {
          bodyData.address = JSON.parse(bodyData.address);
        } catch (e) {
          // Keep it as is if it's not JSON
        }
      }

      const photoUrl = req.file ? `/uploads/profiles/${req.file.filename}` : undefined;
      const updatedUser = await UserService.updateProfile(userId, bodyData, photoUrl);

      res.status(200).json({
        message: 'Profile updated successfully',
        user: updatedUser,
      });
    } catch (error: any) {
      res.status(500).json({ message: 'Error updating profile', error: error.message });
    }
  }
}
