const Product = require('../models/Product');
const Category = require('../models/Category');

/**
 * @desc    Get all products
 * @route   GET /api/products
 * @access  Public
 */
exports.getProducts = async (req, res, next) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Get single product
 * @route   GET /api/products/:id
 * @access  Public
 */
exports.getProductById = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Create a product
 * @route   POST /api/products
 * @access  Private/Admin
 */
exports.createProduct = async (req, res, next) => {
  try {
    const { title, price, image, category } = req.body;
    if (!title || price == null) {
      return res.status(400).json({ message: 'Title and price are required' });
    }

    const product = await Product.create({ title, price, image, category });
    res.status(201).json(product);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Update a product
 * @route   PUT /api/products/:id
 * @access  Private/Admin
 */
exports.updateProduct = async (req, res, next) => {
  try {
    const updates = req.body;
    const product = await Product.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product);
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Delete a product
 * @route   DELETE /api/products/:id
 * @access  Private/Admin
 */
exports.deleteProduct = async (req, res, next) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json({ message: 'Deleted' });
  } catch (err) {
    next(err);
  }
};

/**
 * @desc    Get distinct product categories from Category model (with auto-migration)
 * @route   GET /api/products/categories
 * @access  Public
 */
exports.getCategories = async (req, res, next) => {
  try {
    // 1. Get unique categories currently used in products
    const productCats = await Product.distinct('category', { category: { $ne: '' } });

    // 2. Ensure all these exist in the Category collection
    for (const name of productCats) {
      if (name) {
        await Category.findOneAndUpdate(
          { name },
          { name },
          { upsert: true, new: true }
        );
      }
    }

    // 3. Return all categories from the Category collection
    const cats = await Category.find().sort({ name: 1 });
    res.json(cats.map(c => c.name));
  } catch (err) {
    next(err);
  }
};
