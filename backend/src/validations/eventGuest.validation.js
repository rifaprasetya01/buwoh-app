const Joi = require('joi');

const applyAsGuestSchema = Joi.object({
  notesFromGuest: Joi.string().trim().max(500).allow(null, '').optional(),
  gifts: Joi.array().items(
    Joi.object({
      giftCategoryId: Joi.number().integer().positive().required()
        .messages({ 'any.required': 'Kategori bawaan wajib dipilih' }),
      quantity: Joi.number().positive().required()
        .messages({
          'any.required': 'Jumlah bawaan wajib diisi',
          'number.positive': 'Jumlah bawaan harus lebih dari 0',
        }),
      notes: Joi.string().trim().max(300).allow(null, '').optional(),
    })
  ).min(1).required()
    .messages({
      'array.min': 'Minimal harus ada 1 bawaan',
      'any.required': 'Data bawaan wajib diisi',
    }),
});

const updateGuestStatusSchema = Joi.object({
  applicationStatus: Joi.string().valid('accepted', 'rejected').required()
    .messages({ 'any.required': 'Status pengajuan wajib diisi' }),
  rejectionReason: Joi.string().trim().max(300).allow(null, '')
    .when('applicationStatus', {
      is: 'rejected',
      then: Joi.optional(),
      otherwise: Joi.forbidden(),
    }),
});

const updateAttendanceSchema = Joi.object({
  attendanceStatus: Joi.string().valid('present', 'absent').required()
    .messages({ 'any.required': 'Status kehadiran wajib diisi' }),
});

const eventGuestParamsSchema = Joi.object({
  eventId: Joi.number().integer().positive().required(),
});

const eventGuestActionParamsSchema = Joi.object({
  eventId: Joi.number().integer().positive().required(),
  guestId: Joi.number().integer().positive().required(),
});

module.exports = {
  applyAsGuestSchema,
  updateGuestStatusSchema,
  updateAttendanceSchema,
  eventGuestParamsSchema,
  eventGuestActionParamsSchema,
};
