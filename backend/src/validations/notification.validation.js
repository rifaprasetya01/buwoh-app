const Joi = require('joi');

const notificationQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(50).default(20),
  isRead: Joi.boolean().optional(),
  type: Joi.string().valid(
    'balas_budi',
    'application_accepted',
    'application_rejected',
    'new_applicant',
    'attendance_verified'
  ).optional(),
});

const notificationIdParamSchema = Joi.object({
  id: Joi.number().integer().positive().required(),
});

module.exports = {
  notificationQuerySchema,
  notificationIdParamSchema,
};
