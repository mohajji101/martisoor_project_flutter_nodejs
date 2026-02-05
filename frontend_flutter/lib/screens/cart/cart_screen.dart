import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/api_service.dart';
import '../order/order_success_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBrowseMenu;
  const CartScreen({super.key, this.onBrowseMenu});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return LoadingOverlay(
        isLoading: isProcessing,
        message: "Processing your order...",
        child: Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: const BrandAppBar(
          title: "My Cart",
          subtitle: "Confirm your order details",
        ),
        body: Column(
          children: [
            // 🧾 CART ITEMS
            Expanded(
              child: Obx(() => cart.items.isEmpty
                  ? EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: "Your cart is empty",
                      message: "Add some delicious meals to your cart and they will show up here!",
                      actionText: "Browse Menu",
                      onAction: widget.onBrowseMenu ?? () {
                        // Default behavior if no callback provided
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return CartItem(item: item);
                      },
                    )),
            ),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBlue : AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                boxShadow: [AppShadows.lg],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Advice Card
                  const AdviceCard(
                    title: "Free Delivery",
                    message: "Free delivery on orders over \$50. Add more items to qualify!",
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  Obx(() => summaryRow("Subtotal", "\$${cart.subtotal.toStringAsFixed(2)}")),
                  Obx(() => summaryRow("Delivery Fee", "\$${cart.deliveryFee.toStringAsFixed(2)}")),
                  const Divider(height: 30),
                  Obx(() => summaryRow(
                    "Grand Total",
                    "\$${cart.total.toStringAsFixed(2)}",
                    bold: true,
                  )),
                  const SizedBox(height: AppSpacing.lg),

                  // ORDER BUTTON
                  Obx(() => BrandButton(
                    text: "PLACE ORDER",
                    onPressed: cart.items.isEmpty
                        ? () {}
                        : () async {
                            final auth = Get.find<AuthController>();
                            final token = auth.token;
                            
                            setState(() => isProcessing = true);

                            try {
                              await ApiService.createOrder(
                                token: token,
                                items: cart.toOrderItems(),
                                subtotal: cart.subtotal,
                                deliveryFee: cart.deliveryFee,
                                total: cart.total,
                              );

                              cart.clear();
                              Get.to(() => OrderSuccessScreen());
                            } catch (e) {
                              BrandSnackBar.showError(context, "Order failed: $e");
                            } finally {
                              if (mounted) setState(() => isProcessing = false);
                            }
                          },
                    isFullWidth: true,
                    icon: Icons.check_circle_outline,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    });
  }
}

// 🧾 CART ITEM WIDGET
class CartItem extends StatelessWidget {
  final CartItemModel item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return BrandCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 70,
              height: 70,
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: AppColors.veryLightBlue,
                  child: const Icon(Icons.fastfood, color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppSpacing.xs),
                Obx(() => Text(
                  "\$${item.total.toStringAsFixed(2)}",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBlue : AppColors.veryLightBlue,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18, color: AppColors.primaryBlue),
                  onPressed: () => cart.decrease(item.id),
                ),
                Obx(() => Text(
                  item.quantity.value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                IconButton(
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primaryBlue),
                  onPressed: () => cart.increase(item.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 💵 SUMMARY ROW
Widget summaryRow(String title, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: bold ? AppTextStyles.h3 : AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
        ),
        Text(
          value,
          style: bold ? AppTextStyles.h3.copyWith(color: AppColors.primaryOrange) : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
