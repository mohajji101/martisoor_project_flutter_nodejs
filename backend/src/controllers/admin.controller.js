const Product = require("../models/Product");
const Order = require("../models/Order");
const User = require("../models/User");
const Settings = require('../models/Settings');
const Category = require("../models/Category");
const bcrypt = require("bcryptjs");

/**
 * @desc    Create a new user
 * @route   POST /api/admin/users
 * @access  Private/Admin
 */
exports.createUser = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role: role || 'customer'
    });

    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(201).json(userResponse);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Get dashboard statistics
 * @route   GET /api/admin/stats
 * @access  Private/Admin
 */
exports.getStats = async (req, res, next) => {
  try {
    const products = await Product.countDocuments();
    const orders = await Order.countDocuments();
    const users = await User.countDocuments();

    const revenueAgg = await Order.aggregate([
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);

    let revenue = revenueAgg[0]?.total || 0;

    // Fallback if aggregation fails
    if (!revenue || typeof revenue !== 'number') {
      const allOrders = await Order.find().select('total');
      revenue = allOrders.reduce((acc, o) => acc + (Number(o.total) || 0), 0);
    }

    res.json({ products, orders, users, revenue });
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    List all orders
 * @route   GET /api/admin/orders
 * @access  Private/Admin
 */
exports.listOrders = async (req, res, next) => {
  try {
    const orders = await Order.find()
      .populate('user', 'name email')
      .sort({ createdAt: -1 })
      .limit(100);
    res.json(orders);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Rename a category across all products and in Category model
 * @route   POST /api/admin/categories/rename
 * @access  Private/Admin
 */
exports.renameCategory = async (req, res, next) => {
  try {
    const { oldName, newName } = req.body;
    if (!oldName || !newName) return res.status(400).json({ message: 'oldName and newName required' });

    // Update Category model
    await Category.findOneAndUpdate({ name: oldName }, { name: newName });

    // Update all products
    const result = await Product.updateMany({ category: oldName }, { $set: { category: newName } });
    res.json({ modifiedCount: result.modifiedCount || result.nModified || 0 });
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Delete a category (unassign from products and remove from Category model)
 * @route   POST /api/admin/categories/delete
 * @access  Private/Admin
 */
exports.deleteCategory = async (req, res, next) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: 'name required' });

    // Delete from Category model
    await Category.findOneAndDelete({ name });

    // Unassign from products
    const result = await Product.updateMany({ category: name }, { $set: { category: '' } });
    res.json({ modifiedCount: result.modifiedCount || result.nModified || 0 });
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Create a new category
 * @route   POST /api/admin/categories
 * @access  Private/Admin
 */
exports.createCategory = async (req, res, next) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: 'name required' });

    const exists = await Category.findOne({ name });
    if (exists) return res.status(400).json({ message: 'Category already exists' });

    const category = await Category.create({ name });
    res.status(201).json(category);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    List all users
 * @route   GET /api/admin/users
 * @access  Private/Admin
 */
exports.listUsers = async (req, res, next) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Get app settings
 * @route   GET /api/admin/settings
 * @access  Public
 */
exports.getSettings = async (req, res, next) => {
  try {
    let settings = await Settings.findOne();
    if (!settings) {
      settings = await Settings.create({ deliveryFee: 10, discountPercent: 0, minOrderForDiscount: 100 });
    }
    res.json(settings);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Update app settings
 * @route   PUT /api/admin/settings
 * @access  Private/Admin
 */
exports.updateSettings = async (req, res, next) => {
  try {
    const { deliveryFee, discountPercent, minOrderForDiscount } = req.body;
    let settings = await Settings.findOne();
    if (!settings) {
      settings = await Settings.create({ deliveryFee: 10, discountPercent: 0, minOrderForDiscount: 100 });
    }

    if (deliveryFee !== undefined) settings.deliveryFee = deliveryFee;
    if (discountPercent !== undefined) settings.discountPercent = discountPercent;
    if (minOrderForDiscount !== undefined) settings.minOrderForDiscount = minOrderForDiscount;

    await settings.save();
    res.json(settings);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Update order status
 * @route   PUT /api/admin/orders/status
 * @access  Private/Admin
 */
exports.updateOrderStatus = async (req, res, next) => {
  try {
    const { orderId, status } = req.body;
    const validStatuses = ['Pending', 'Payment Completed', 'Processing', 'Delivered', 'Cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const order = await Order.findByIdAndUpdate(orderId, { status }, { new: true });
    if (!order) return res.status(404).json({ message: 'Order not found' });

    res.json(order);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Delete a user
 * @route   DELETE /api/admin/users/:id
 * @access  Private/Admin
 */
exports.deleteUser = async (req, res, next) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Update a user
 * @route   PUT /api/admin/users/:id
 * @access  Private/Admin
 */
exports.updateUser = async (req, res, next) => {
  try {
    const { name, email, role } = req.body;
    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (email !== undefined) updateData.email = email;
    if (role !== undefined) updateData.role = role;

    const user = await User.findByIdAndUpdate(req.params.id, updateData, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (err) {
    next(err);
  }
};
