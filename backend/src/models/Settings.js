const mongoose = require('mongoose');

const settingsSchema = new mongoose.Schema({
    deliveryFee: { type: Number, default: 0.0 }, // default $0
    discountPercent: { type: Number, default: 0 }, // default 0%
    minOrderForDiscount: { type: Number, default: 100.0 }, // Threshold for discount
});

module.exports = mongoose.model('Settings', settingsSchema);
