const Joi = require('joi');

const registerSchema = Joi.object({
  name: Joi.string().trim().min(2).max(100).required()
    .messages({
      'string.min': 'Nama minimal 2 karakter',
      'string.max': 'Nama maksimal 100 karakter',
      'any.required': 'Nama wajib diisi',
    }),
  email: Joi.string().trim().email().max(150).required()
    .messages({
      'string.email': 'Format email tidak valid',
      'any.required': 'Email wajib diisi',
    }),
  password: Joi.string().min(6).max(128).required()
    .messages({
      'string.min': 'Password minimal 6 karakter',
      'any.required': 'Password wajib diisi',
    }),
  phoneNumber: Joi.string().trim().max(20).allow(null, '').optional(),
  address: Joi.string().trim().allow(null, '').optional(),
});

const loginSchema = Joi.object({
  email: Joi.string().trim().email().required()
    .messages({
      'string.email': 'Format email tidak valid',
      'any.required': 'Email wajib diisi',
    }),
  password: Joi.string().required()
    .messages({
      'any.required': 'Password wajib diisi',
    }),
});

const updateProfileSchema = Joi.object({
  name: Joi.string().trim().min(2).max(100).optional(),
  phoneNumber: Joi.string().trim().max(20).allow(null, '').optional(),
  address: Joi.string().trim().allow(null, '').optional(),
  profilePhotoUrl: Joi.string().trim().uri().max(500).allow(null, '').optional(),
});

module.exports = {
  registerSchema,
  loginSchema,
  updateProfileSchema,
};
