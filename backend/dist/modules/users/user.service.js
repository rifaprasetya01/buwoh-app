"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class UserService {
    static async getProfile(userId) {
        const user = await prisma_1.default.user.findUnique({
            where: { id: userId },
            include: {
                address: true,
            },
        });
        if (!user) {
            throw new Error('User not found');
        }
        // Calculate statistics
        const totalBuwoh = await prisma_1.default.eventGuest.count({
            where: {
                guestId: userId,
                status: 'validated',
            },
        });
        const totalEventsHosted = await prisma_1.default.event.count({
            where: {
                hostId: userId,
            },
        });
        const { passwordHash, ...userWithoutPassword } = user;
        return {
            ...userWithoutPassword,
            stats: {
                totalBuwoh,
                totalEventsHosted,
            },
        };
    }
    static async updateProfile(userId, data, photoUrl) {
        const updateData = {
            name: data.name,
            birthDate: data.birthDate ? new Date(data.birthDate) : undefined,
        };
        if (photoUrl) {
            updateData.photoUrl = photoUrl;
        }
        // Handle Address
        if (data.address) {
            const user = await prisma_1.default.user.findUnique({
                where: { id: userId },
                select: { addressId: true },
            });
            if (user?.addressId) {
                // Update existing address
                await prisma_1.default.address.update({
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
            }
            else {
                // Create new address and link to user
                const newAddress = await prisma_1.default.address.create({
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
        const updatedUser = await prisma_1.default.user.update({
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
exports.UserService = UserService;
