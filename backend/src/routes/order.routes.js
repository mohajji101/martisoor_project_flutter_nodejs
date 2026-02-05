const router = require('express').Router();
const orderController = require('../controllers/order.controller');
const { authMiddleware } = require('../middleware/auth_middleware');

router.post('/', orderController.createOrder); // Auth is optional in the controller logic
router.get('/', authMiddleware, orderController.getMyOrders);

module.exports = router;
