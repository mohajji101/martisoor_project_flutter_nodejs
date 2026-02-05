const router = require("express").Router();
const { getStats, createCategory, renameCategory, deleteCategory, listOrders, listUsers, getSettings, updateSettings, updateOrderStatus, deleteUser, updateUser, createUser } = require("../controllers/admin.controller");
const { authMiddleware, adminOnly } = require("../middleware/auth_middleware");

router.get("/stats", authMiddleware, adminOnly, getStats);
router.post('/categories', authMiddleware, adminOnly, createCategory);
router.post('/categories/rename', authMiddleware, adminOnly, renameCategory);
router.post('/categories/delete', authMiddleware, adminOnly, deleteCategory);
router.get('/orders', authMiddleware, adminOnly, listOrders);
router.put('/orders/status', authMiddleware, adminOnly, updateOrderStatus);
router.get('/users', authMiddleware, adminOnly, listUsers);
router.get('/settings', getSettings); // Public read? Or authenticated? Let's make it public for cart calculation or user-auth specific. Let's start with NO-AUTH for simplicity in cart or authMiddleware if we want only logged-in users to checkout. But cart might be viewed by guests. Let's make GET public or at least separate route product. But for now, putting it in admin routes means /api/admin/settings. Let's assume we need authMiddleware.
// Actually, Cart needs it. And Cart might be accessible by guest? Or does this app require login? 
// App requires login to checkout. Cart screen might be visible.
// For simplicity, let's keep it under admin routes but maybe relax auth for GET if needed, BUT ideally guests shouldn't see "admin" API. 
// However, sticking to plan: admin routes.
// Making it public accessible on /api/admin/settings for simplicty, or rename to /api/settings. 
// Wait, middleware is applied to specific routes? 
// In admin.routes.js lines are `router.get("/stats", authMiddleware, adminOnly, ...)`
// So I can define one without middleware.
router.put('/settings', authMiddleware, adminOnly, updateSettings);
router.delete('/users/:id', authMiddleware, adminOnly, deleteUser);
router.put('/users/:id', authMiddleware, adminOnly, updateUser);
router.post('/users', authMiddleware, adminOnly, createUser);

module.exports = router;
