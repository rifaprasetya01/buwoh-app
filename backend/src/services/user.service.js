const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');

/**
 * Serialize BigInt fields
 */
const serializeUser = (user) => ({
  ...user,
  id: user.id.toString(),
});

/**
 * Get user profile by ID
 */
const getUserById = async (userId) => {
  const user = await prisma.user.findUnique({
    where: { id: BigInt(userId) },
    select: {
      id: true,
      name: true,
      email: true,
      phoneNumber: true,
      profilePhotoUrl: true,
      address: true,
      createdAt: true,
    },
  });

  if (!user) {
    throw ApiError.notFound('User tidak ditemukan.');
  }

  return serializeUser(user);
};

/**
 * Update own profile
 */
const updateProfile = async (userId, data) => {
  // Cek phone number uniqueness jika diubah
  if (data.phoneNumber) {
    const existingPhone = await prisma.user.findFirst({
      where: {
        phoneNumber: data.phoneNumber,
        id: { not: BigInt(userId) },
      },
    });
    if (existingPhone) {
      throw ApiError.conflict('Nomor HP sudah digunakan user lain.');
    }
  }

  const user = await prisma.user.update({
    where: { id: BigInt(userId) },
    data: {
      ...(data.name && { name: data.name }),
      ...(data.phoneNumber !== undefined && { phoneNumber: data.phoneNumber || null }),
      ...(data.address !== undefined && { address: data.address || null }),
      ...(data.profilePhotoUrl !== undefined && { profilePhotoUrl: data.profilePhotoUrl || null }),
    },
    select: {
      id: true,
      name: true,
      email: true,
      phoneNumber: true,
      profilePhotoUrl: true,
      address: true,
      updatedAt: true,
    },
  });

  return serializeUser(user);
};

module.exports = {
  getUserById,
  updateProfile,
};
