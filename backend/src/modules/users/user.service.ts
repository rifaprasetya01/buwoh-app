import prisma from '../../config/prisma';
import { UpdateProfileInput } from './user.schema';
const fs = require('fs');
const path = require('path');

const logFile = 'c:/Users/reeal/Documents/kuliah/pemograman mobile/buwoh-app/backend/debug_backend.log';
function logToFile(msg: string) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  fs.appendFileSync(logFile, line);
}

export class UserService {
  static async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        address: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    logToFile(`Fetching stats for userId: ${userId}`);

    // Calculate statistics
    const totalBuwoh = await prisma.eventGuest.count({
      where: {
        guestId: userId,
        status: { in: ['validated', 'attended'] },
      },
    });

    const events = await prisma.event.findMany({
      where: { hostId: userId, deletedAt: null },
      select: { id: true, title: true }
    });
    const totalEventsHosted = events.length;

    logToFile(`Stats for ${userId}: totalBuwoh=${totalBuwoh}, totalEventsHosted=${totalEventsHosted}`);
    logToFile(`Events found: ${JSON.stringify(events)}`);

    const { passwordHash, ...userWithoutPassword } = user;

    return {
      ...userWithoutPassword,
      stats: {
        totalBuwoh,
        totalEventsHosted,
      },
    };
  }

  static async updateProfile(userId: string, data: UpdateProfileInput, photoUrl?: string) {
    const updateData: any = {
      name: data.name,
      birthDate: data.birthDate ? new Date(data.birthDate) : undefined,
    };

    if (photoUrl) {
      updateData.photoUrl = photoUrl;
    }

    // Handle Address
    if (data.address) {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: { addressId: true },
      });

      if (user?.addressId) {
        // Update existing address
        await prisma.address.update({
          where: { id: user.addressId },
          data: {
            street: data.address.street,
            rt_rw: data.address.rtRw,
            village: data.address.village,
            district: data.address.district,
            city: data.address.city,
            province: data.address.province,
            postal_code: data.address.postalCode,
            latitude: data.address.latitude,
            longitude: data.address.longitude,
          },
        });
      } else {
        // Create new address and link to user
        const newAddress = await prisma.address.create({
          data: {
            street: data.address.street,
            rt_rw: data.address.rtRw,
            village: data.address.village,
            district: data.address.district,
            city: data.address.city,
            province: data.address.province,
            postal_code: data.address.postalCode,
            latitude: data.address.latitude,
            longitude: data.address.longitude,
          },
        });
        updateData.addressId = newAddress.id;
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: updateData,
      include: {
        address: true,
      },
    });

    const { passwordHash, ...userWithoutPassword } = updatedUser;
    return userWithoutPassword;
  }
}
