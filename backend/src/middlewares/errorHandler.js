const { Prisma } = require('@prisma/client');
const ApiError = require('../utils/ApiError');
const config = require('../config');

/**
 * Global Error Handler Middleware
 * Catches all errors and returns consistent JSON responses
 * Must be the LAST middleware in the express pipeline
 */
// eslint-disable-next-line no-unused-vars
const errorHandler = (err, _req, res, _next) => {
  let error = { ...err };
  error.message = err.message;
  error.stack = err.stack;

  // ─── Prisma Error Mapping ───

  // P2002: Unique constraint violation
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') {
      const target = err.meta?.target;
      const field = Array.isArray(target) ? target.join(', ') : (target || 'field');
      error = ApiError.conflict(`Data dengan ${field} tersebut sudah ada.`);
    }

    // P2025: Record not found
    if (err.code === 'P2025') {
      error = ApiError.notFound('Data tidak ditemukan.');
    }

    // P2003: Foreign key constraint violation
    if (err.code === 'P2003') {
      error = ApiError.badRequest('Referensi data tidak valid.');
    }
  }

  // Prisma validation error
  if (err instanceof Prisma.PrismaClientValidationError) {
    error = ApiError.badRequest('Data yang dikirim tidak valid.');
  }

  // JWT Errors (backup — biasanya sudah ditangkap di auth middleware)
  if (err.name === 'JsonWebTokenError') {
    error = ApiError.unauthorized('Token tidak valid.');
  }

  if (err.name === 'TokenExpiredError') {
    error = ApiError.unauthorized('Token sudah kadaluarsa.');
  }

  // Default values
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  const response = {
    success: false,
    message,
  };

  // Tampilkan stack trace hanya di development
  if (config.nodeEnv === 'development') {
    response.error = err.message;
    response.stack = err.stack;
  }

  res.status(statusCode).json(response);
};

module.exports = errorHandler;
