import prisma from '../../config/prisma';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { RegisterInput, LoginInput } from './auth.schema';

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey123';
const JWT_EXPIRES_IN = '7d';

export class AuthService {
  static async register(data: RegisterInput) {
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      throw new Error('Email already registered');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    const user = await prisma.user.create({
      data: {
        name: data.name,
        email: data.email,
        passwordHash,
      },
    });

    // Generate token
    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN,
    });

    // Exclude password from returned user object
    const { passwordHash: _, ...userWithoutPassword } = user;
    return {
      user: {
        ...userWithoutPassword,
        stats: { totalBuwoh: 0, totalEventsHosted: 0 }
      },
      token,
    };
  }

  static async login(data: LoginInput) {
    const user = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (!user || user.deletedAt) {
      throw new Error('Invalid email or password');
    }

    const isPasswordValid = await bcrypt.compare(data.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN,
    });

    const { passwordHash: _, ...userWithoutPassword } = user;

    // Fetch stats
    const totalBuwoh = await prisma.eventGuest.count({
      where: { guestId: user.id, status: { in: ['validated', 'attended'] } },
    });
    const totalEventsHosted = await prisma.event.count({
      where: { hostId: user.id, deletedAt: null },
    });

    return {
      user: {
        ...userWithoutPassword,
        stats: { totalBuwoh, totalEventsHosted }
      },
      token,
    };
  }
}
