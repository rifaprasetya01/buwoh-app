const Joi = require('joi');

const createEventSchema = Joi.object({
  eventCategoryId: Joi.number().integer().positive().required()
    .messages({ 'any.required': 'Kategori acara wajib dipilih' }),
  title: Joi.string().trim().min(3).max(200).required()
    .messages({ 'any.required': 'Judul acara wajib diisi' }),
  description: Joi.string().trim().allow(null, '').optional(),
  locationName: Joi.string().trim().min(3).max(300).required()
    .messages({ 'any.required': 'Nama lokasi wajib diisi' }),
  locationAddress: Joi.string().trim().min(5).required()
    .messages({ 'any.required': 'Alamat lokasi wajib diisi' }),
  locationLat: Joi.number().min(-90).max(90).allow(null).optional(),
  locationLng: Joi.number().min(-180).max(180).allow(null).optional(),
  startDatetime: Joi.date().iso().required()
    .messages({ 'any.required': 'Waktu mulai wajib diisi' }),
  endDatetime: Joi.date().iso().greater(Joi.ref('startDatetime')).required()
    .messages({
      'any.required': 'Waktu selesai wajib diisi',
      'date.greater': 'Waktu selesai harus setelah waktu mulai',
    }),
  maxGuests: Joi.number().integer().positive().allow(null).optional(),
  coverImageUrl: Joi.string().trim().uri().max(500).allow(null, '').optional(),
});

const updateEventSchema = Joi.object({
  eventCategoryId: Joi.number().integer().positive().optional(),
  title: Joi.string().trim().min(3).max(200).optional(),
  description: Joi.string().trim().allow(null, '').optional(),
  locationName: Joi.string().trim().min(3).max(300).optional(),
  locationAddress: Joi.string().trim().min(5).optional(),
  locationLat: Joi.number().min(-90).max(90).allow(null).optional(),
  locationLng: Joi.number().min(-180).max(180).allow(null).optional(),
  startDatetime: Joi.date().iso().optional(),
  endDatetime: Joi.date().iso().optional(),
  maxGuests: Joi.number().integer().positive().allow(null).optional(),
  coverImageUrl: Joi.string().trim().uri().max(500).allow(null, '').optional(),
}).min(1).messages({ 'object.min': 'Minimal satu field harus diisi untuk update' });

const updateStatusSchema = Joi.object({
  status: Joi.string().valid('draft', 'published', 'ongoing', 'completed', 'cancelled').required()
    .messages({ 'any.required': 'Status wajib diisi' }),
});

const eventIdParamSchema = Joi.object({
  id: Joi.number().integer().positive().required(),
});

const eventQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(50).default(10),
  status: Joi.string().valid('draft', 'published', 'ongoing', 'completed', 'cancelled').optional(),
  categoryId: Joi.number().integer().positive().optional(),
  search: Joi.string().trim().max(100).optional(),
});

module.exports = {
  createEventSchema,
  updateEventSchema,
  updateStatusSchema,
  eventIdParamSchema,
  eventQuerySchema,
};
