const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const authService = require('../services/auth.service');

/**
 * POST /api/v1/auth/register
 */
const register = catchAsync(async (req, res) => {
  const result = await authService.register(req.body);
  ApiResponse.created(res, 'Registrasi berhasil.', result);
});

/**
 * POST /api/v1/auth/login
 */
const login = catchAsync(async (req, res) => {
  const result = await authService.login(req.body);
  ApiResponse.success(res, 200, 'Login berhasil.', result);
});

/**
 * GET /api/v1/auth/me
 */
const getMe = catchAsync(async (req, res) => {
  const user = await authService.getMe(req.user.id);
  ApiResponse.success(res, 200, 'Data user berhasil diambil.', user);
});

module.exports = {
  register,
  login,
  getMe,
};
