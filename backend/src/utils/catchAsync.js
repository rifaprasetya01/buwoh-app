/**
 * Async error wrapper for Express controllers
 * Catches async errors and passes them to the global error handler
 * Eliminates the need for try-catch in every controller method
 *
 * @param {Function} fn - Async controller function
 * @returns {Function} Express middleware function
 */
const catchAsync = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = catchAsync;
