const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');
const config = require('./config');
const routes = require('./routes');
const errorHandler = require('./middlewares/errorHandler');
const ApiError = require('./utils/ApiError');

// Global BigInt serializer for JSON.stringify
BigInt.prototype.toJSON = function () {
  return this.toString();
};

const app = express();

// ─── 1. Security Headers ───
app.use(helmet());

// ─── 2. CORS ───
app.use(cors({
  origin: config.cors.origin,
  credentials: true,
}));

// ─── 3. Request Logging ───
if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// ─── 4. Body Parser ───
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ─── 5. Cookie Parser ───
app.use(cookieParser());

// ─── 6. Rate Limiting ───
const limiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.max,
  message: {
    success: false,
    message: 'Terlalu banyak request. Silakan coba lagi nanti.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', limiter);

// ─── 7. Routes ───
app.use('/api/v1', routes);

// ─── 8. 404 Handler ───
app.use((_req, _res, next) => {
  next(ApiError.notFound('Endpoint tidak ditemukan.'));
});

// ─── 9. Global Error Handler (must be last) ───
app.use(errorHandler);

module.exports = app;
