const jwt = require('jsonwebtoken');
const config = require('../config');
const prisma = require('../lib/prisma');
const ApiError = require('../utils/ApiError');
const catchAsync = require('../utils/catchAsync');

/**
 * JWT Authentication Middleware
 * Verifies Bearer token from Authorization header
 * Attaches user data to req.user
 */
const authenticate = catchAsync(async (req, _res, next) => {
  // 1. Ambil token dari header
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    throw ApiError.unauthorized('Akses ditolak. Token tidak ditemukan.');
  }

  // 2. Verifikasi token
  let decoded;
  try {
    decoded = jwt.verify(token, config.jwt.secret);
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      throw ApiError.unauthorized('Token sudah kadaluarsa. Silakan login ulang.');
    }
    throw ApiError.unauthorized('Token tidak valid.');
  }

  // 3. Cek apakah user masih ada di database
  const user = await prisma.user.findUnique({
    where: { id: BigInt(decoded.id) },
    select: {
      id: true,
      name: true,
      email: true,
      phoneNumber: true,
      profilePhotoUrl: true,
      isActive: true,
    },
  });

  if (!user) {
    throw ApiError.unauthorized('User tidak ditemukan.');
  }

  if (!user.isActive) {
    throw ApiError.unauthorized('Akun telah dinonaktifkan.');
  }

  // 4. Attach user ke request — serialize BigInt
  req.user = {
    ...user,
    id: user.id.toString(),
  };

  next();
});

module.exports = { authenticate };
