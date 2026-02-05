const router = require('express').Router();
const {
  getProducts,
  getProductById,
  getCategories,
  createProduct,
  updateProduct,
  deleteProduct,
} = require('../controllers/product.controller');

const { authMiddleware, adminOnly } = require('../middleware/auth_middleware');

router.get('/', getProducts);
router.get('/categories', getCategories);
router.get('/:id', getProductById);

// Admin protected routes
router.post('/', authMiddleware, adminOnly, createProduct);
router.put('/:id', authMiddleware, adminOnly, updateProduct);
router.delete('/:id', authMiddleware, adminOnly, deleteProduct);

module.exports = router;
