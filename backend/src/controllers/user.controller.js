const catchAsync = require('../utils/catchAsync');
const ApiResponse = require('../utils/ApiResponse');
const userService = require('../services/user.service');

/**
 * GET /api/v1/users/:id
 */
const getUserById = catchAsync(async (req, res) => {
  const user = await userService.getUserById(req.params.id);
  ApiResponse.success(res, 200, 'Data user berhasil diambil.', user);
});

/**
 * PUT /api/v1/users/profile
 */
const updateProfile = catchAsync(async (req, res) => {
  const user = await userService.updateProfile(req.user.id, req.body);
  ApiResponse.success(res, 200, 'Profil berhasil diperbarui.', user);
});

module.exports = {
  getUserById,
  updateProfile,
};
