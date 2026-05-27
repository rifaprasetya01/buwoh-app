import { Request, Response } from 'express';
import { AuthService } from './auth.service';

export class AuthController {
  static async register(req: Request, res: Response): Promise<void> {
    try {
      const data = await AuthService.register(req.body);
      res.status(201).json({
        message: 'Registration successful',
        ...data,
      });
    } catch (error: any) {
      console.error(`[${new Date().toISOString()}] Registration Error:`, error);
      if (error.message === 'Email already registered') {
        res.status(409).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Internal server error', error: error.message });
      }
    }
  }

  static async login(req: Request, res: Response): Promise<void> {
    try {
      const data = await AuthService.login(req.body);
      res.status(200).json(data);
    } catch (error: any) {
      console.error('Login Error:', error);
      if (error.message === 'Invalid email or password') {
        res.status(401).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Internal server error', error: error.message });
      }
    }
  }

  static async logout(req: Request, res: Response): Promise<void> {
    // Since JWT is stateless, logout is typically handled client-side by dropping the token.
    // If we wanted to, we could implement a token blacklist here.
    res.status(200).json({ message: 'Logged out successfully' });
  }
}
