/**
 * Validation Middleware helper
 */
const validate = (schema) => (req, res, next) => {
    // Simple custom validation logic or Joi implementation
    // For this project, we can do a simple check or just provide a structure
    // that can be expanded.

    // Example: if schema is an array of required fields
    if (Array.isArray(schema)) {
        for (const field of schema) {
            if (!req.body[field]) {
                return res.status(400).json({
                    success: false,
                    message: `Field '${field}' is required`,
                });
            }
        }
    }
    next();
};

module.exports = validate;
