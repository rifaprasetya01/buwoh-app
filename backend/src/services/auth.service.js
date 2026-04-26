const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../lib/prisma');
const config = require('../config');
const ApiError = require('../utils/ApiError');

/**
 * Helper: Serialize BigInt fields untuk JSON response
 */
const serializeUser = (user) => ({
  ...user,
  id: user.id.toString(),
});

/**
 * Register user baru
 */
const register = async ({ name, email, password, phoneNumber, address }) => {
  // Cek email sudah terpakai
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw ApiError.conflict('Email sudah terdaftar.');
  }

  // Cek phone number jika diberikan
  if (phoneNumber) {
    const existingPhone = await prisma.user.findUnique({
      where: { phoneNumber },
    });
    if (existingPhone) {
      throw ApiError.conflict('Nomor HP sudah terdaftar.');
    }
  }

  // Hash password
  const passwordHash = await bcrypt.hash(password, 12);

  // Create user
  const user = await prisma.user.create({
    data: {
      name,
      email,
      phoneNumber: phoneNumber || null,
      passwordHash,
      address: address || null,
    },
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

  // Generate JWT
  const token = generateToken(user.id);

  return { user: serializeUser(user), token };
};

/**
 * Login user
 */
const login = async ({ email, password }) => {
  // Cari user by email
  const user = await prisma.user.findUnique({
    where: { email },
  });

  if (!user) {
    throw ApiError.unauthorized('Email atau password salah.');
  }

  if (!user.isActive) {
    throw ApiError.unauthorized('Akun telah dinonaktifkan.');
  }

  // Verifikasi password
  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
  if (!isPasswordValid) {
    throw ApiError.unauthorized('Email atau password salah.');
  }

  // Generate JWT
  const token = generateToken(user.id);

  const userData = {
    id: user.id,
    name: user.name,
    email: user.email,
    phoneNumber: user.phoneNumber,
    profilePhotoUrl: user.profilePhotoUrl,
    address: user.address,
  };

  return { user: serializeUser(userData), token };
};

/**
 * Get current user profile (dari token)
 */
const getMe = async (userId) => {
  const user = await prisma.user.findUnique({
    where: { id: BigInt(userId) },
    select: {
      id: true,
      name: true,
      email: true,
      phoneNumber: true,
      profilePhotoUrl: true,
      address: true,
      emailVerifiedAt: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  if (!user) {
    throw ApiError.notFound('User tidak ditemukan.');
  }

  return serializeUser(user);
};

/**
 * Generate JWT token
 */
const generateToken = (userId) => {
  return jwt.sign(
    { id: userId.toString() },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );
};

module.exports = {
  register,
  login,
  getMe,
};
