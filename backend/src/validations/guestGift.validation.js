const Joi = require('joi');

const createGiftSchema = Joi.object({
  giftCategoryId: Joi.number().integer().positive().required()
    .messages({ 'any.required': 'Kategori bawaan wajib dipilih' }),
  quantity: Joi.number().positive().required()
    .messages({
      'any.required': 'Jumlah bawaan wajib diisi',
      'number.positive': 'Jumlah bawaan harus lebih dari 0',
    }),
  notes: Joi.string().trim().max(300).allow(null, '').optional(),
});

const updateGiftSchema = Joi.object({
  giftCategoryId: Joi.number().integer().positive().optional(),
  quantity: Joi.number().positive().optional()
    .messages({ 'number.positive': 'Jumlah bawaan harus lebih dari 0' }),
  notes: Joi.string().trim().max(300).allow(null, '').optional(),
}).min(1).messages({ 'object.min': 'Minimal satu field harus diisi untuk update' });

const guestGiftParamsSchema = Joi.object({
  guestId: Joi.number().integer().positive().required(),
});

const giftActionParamsSchema = Joi.object({
  guestId: Joi.number().integer().positive().required(),
  giftId: Joi.number().integer().positive().required(),
});

module.exports = {
  createGiftSchema,
  updateGiftSchema,
  guestGiftParamsSchema,
  giftActionParamsSchema,
};
