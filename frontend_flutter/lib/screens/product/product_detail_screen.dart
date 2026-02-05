import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>> productFuture;

  int portion = 1;

  @override
  void initState() {
    super.initState();
    productFuture = ApiService.getProductById(widget.productId);
  }
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.primaryBlue,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                icon: Icons.error_outline,
                title: "Error",
                message: "Failed to load product details.",
                actionText: "Go Back",
                onAction: () => Get.back(),
              );
            }

            final product = snapshot.data!;
            final double price = (product['price'] ?? 0).toDouble();
            final double totalPrice = price * portion;

            return Column(
              children: [
                // 🔝 TOP BAR
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: AppColors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                // 🍔 IMAGE
                Expanded(
                  flex: 2,
                  child: Hero(
                    tag: 'product_${widget.productId}',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [AppShadows.lg],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          product['image'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: AppColors.veryLightBlue,
                            child: const Icon(Icons.restaurant, size: 80, color: AppColors.primaryBlue),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ⚪ CONTENT
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl * 2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['title'] ?? 'Untitled',
                                            style: AppTextStyles.h2,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          const StatusBadge(
                                            text: "Popular Choice",
                                            color: AppColors.primaryOrange,
                                            icon: Icons.star,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "\$${price.toStringAsFixed(2)}",
                                      style: AppTextStyles.price.copyWith(fontSize: 24),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // DESCRIPTION
                                Text(
                                  product['description'] ?? "Enjoy our freshly prepared delicious meal made with high quality ingredients and traditional recipes.",
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // ADJUSTMENTS
                                Row(
                                  children: [
                                    // Portion
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Portion", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: AppSpacing.xs),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.veryLightBlue,
                                            borderRadius: BorderRadius.circular(AppRadius.md),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, size: 20, color: AppColors.primaryBlue),
                                                onPressed: () {
                                                  if (portion > 1) setState(() => portion--);
                                                },
                                              ),
                                              Text(
                                                portion.toString(),
                                                style: AppTextStyles.h4,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, size: 20, color: AppColors.primaryBlue),
                                                onPressed: () => setState(() => portion++),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSpacing.lg),
                                
                                // Advice Card
                                const AdviceCard(
                                  title: "Make it a Meal!",
                                  message: "Add a side of fries and a drink for just \$3.99 more.",
                                  icon: Icons.fastfood_outlined,
                                  color: AppColors.primaryOrange,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // 💰 ADD TO CART
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("Total Price", style: AppTextStyles.caption),
                                  Text(
                                    "\$${totalPrice.toStringAsFixed(2)}",
                                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryOrange),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 2,
                              child: BrandButton(
                                text: "Add to Cart",
                                onPressed: () {
                                  final String? id = product['_id'] ?? product['id'];
                                  final String title = product['title'] ?? 'Untitled';
                                  final String image = product['image'] ?? '';

                                  if (id == null) {
                                    BrandSnackBar.showError(context, "Product ID missing");
                                    return;
                                  }

                                  Get.find<CartController>().addItem(
                                    CartItemModel(
                                      id: id,
                                      title: title,
                                      image: image,
                                      price: price,
                                      quantity: portion,
                                    ),
                                  );
                                  BrandSnackBar.showSuccess(context, "Added to cart");
                                  Get.back();
                                },
                                isFullWidth: true,
                                icon: Icons.shopping_basket_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      );
    });
  }
}