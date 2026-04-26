/**
 * Standardized API Response helper
 * Ensures consistent JSON response format across all endpoints
 */
class ApiResponse {
  /**
   * Success response
   * @param {import('express').Response} res
   * @param {number} statusCode - HTTP status code (200, 201, etc.)
   * @param {string} message - Response message
   * @param {*} data - Response data payload
   */
  static success(res, statusCode = 200, message = 'Success', data = null) {
    const response = {
      success: true,
      message,
    };

    if (data !== null && data !== undefined) {
      response.data = data;
    }

    return res.status(statusCode).json(response);
  }

  /**
   * Created response (201)
   */
  static created(res, message = 'Created successfully', data = null) {
    return ApiResponse.success(res, 201, message, data);
  }

  /**
   * No Content response (204)
   */
  static noContent(res) {
    return res.status(204).send();
  }

  /**
   * Paginated response
   * @param {import('express').Response} res
   * @param {string} message
   * @param {*} data
   * @param {object} pagination - { page, limit, total, totalPages }
   */
  static paginated(res, message = 'Success', data = [], pagination = {}) {
    return res.status(200).json({
      success: true,
      message,
      data,
      pagination,
    });
  }
}

module.exports = ApiResponse;
