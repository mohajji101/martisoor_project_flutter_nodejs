const Order = require('../models/Order');
const jwt = require("jsonwebtoken");
const User = require("../models/User");

/**
 * @desc    Create a new order
 * @route   POST /api/orders
 * @access  Public (Optional Auth)
 */
exports.createOrder = async (req, res, next) => {
    try {
        const { items, subtotal, deliveryFee, total } = req.body;

        if (!items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ message: "Cart is empty" });
        }

        let userId = null;
        let userName = null;
        let userEmail = null;

        const token = req.headers.authorization?.split(" ")[1];
        if (token) {
            try {
                const decoded = jwt.verify(token, process.env.JWT_SECRET);
                const user = await User.findById(decoded.id);
                if (user) {
                    userId = user._id;
                    userName = user.name;
                    userEmail = user.email;
                }
            } catch (e) {
                console.log("Order creation: Invalid token or user not found", e.message);
            }
        }

        const order = await Order.create({
            items,
            subtotal,
            deliveryFee,
            total,
            user: userId,
            userName,
            userEmail,
        });

        return res.status(201).json(order);
    } catch (err) {
        next(err);
    }
};

/**
 * @desc    Get logged in user orders
 * @route   GET /api/orders
 * @access  Private
 */
exports.getMyOrders = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(" ")[1];
        if (!token) return res.status(401).json({ message: "Unauthorized" });

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        if (!decoded || !decoded.id) return res.status(401).json({ message: "Invalid token" });

        const orders = await Order.find({ user: decoded.id }).sort({ createdAt: -1 });

        return res.json(orders);
    } catch (err) {
        next(err);
    }
};
