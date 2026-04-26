const ApiError = require('../utils/ApiError');

/**
 * Generic Joi Validation Middleware
 * Validates req.body, req.params, and req.query against Joi schemas
 *
 * @param {object} schema - Object with optional keys: body, params, query
 *                          Each key maps to a Joi schema
 * @returns {Function} Express middleware
 *
 * @example
 * router.post('/', validate({ body: createEventSchema }), controller.create);
 * router.get('/:id', validate({ params: idParamSchema }), controller.getById);
 */
const validate = (schema) => {
  return (req, _res, next) => {
    const validationErrors = [];

    ['params', 'query', 'body'].forEach((key) => {
      if (schema[key]) {
        const { error, value } = schema[key].validate(req[key], {
          abortEarly: false,
          stripUnknown: true,
          allowUnknown: false,
        });

        if (error) {
          const messages = error.details.map((detail) => detail.message);
          validationErrors.push(...messages);
        } else {
          // Replace request data with validated (and stripped) value
          req[key] = value;
        }
      }
    });

    if (validationErrors.length > 0) {
      throw ApiError.badRequest(validationErrors.join('. '));
    }

    next();
  };
};

module.exports = validate;
