const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  items: [
    {
      productId: String,
      title: String,
      price: Number,
      quantity: Number,
      image: String,
      lineTotal: Number,
    },
  ],
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  userName: String,
  userEmail: String,
  subtotal: Number,
  deliveryFee: Number,
  total: Number,
  status: { type: String, default: "Pending" },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Order', orderSchema);
