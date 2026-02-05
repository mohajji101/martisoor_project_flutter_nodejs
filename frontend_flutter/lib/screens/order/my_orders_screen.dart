import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/api_service.dart';
import '../order/order_detail_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      if (auth.token == null) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          appBar: const BrandAppBar(title: "My Orders"),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: "Login Required",
          message: "Please login to view your order history and track deliveries.",
          actionText: "Login Now",
          onAction: () {
            Get.offAll(() => LoginScreen());
          },
        ),
      );
    }

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: const BrandAppBar(
        title: "My Orders",
        subtitle: "Track and manage your orders",
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.getMyOrders(auth.token!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryOrange),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: "No orders yet",
                    message: "You haven't placed any orders yet. Browse our menu to start ordering!",
                    actionText: "Browse Menu",
                    onAction: () => Get.back(),
                  );
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final items = (order['items'] as List?) ?? [];
                    final firstItem = items.isNotEmpty ? items[0]['title'] : 'Unknown';
                    final otherCount = items.length - 1;
                    final summary = otherCount > 0 ? "$firstItem + $otherCount more" : firstItem;
                    final dateStr = order['createdAt']?.toString().substring(0, 10) ?? 'N/A';
                    final status = order['status'] ?? 'Processing';

                    Color statusColor;
                    IconData statusIcon;
                    switch (status) {
                      case 'Payment Completed':
                        statusColor = AppColors.primaryBlue;
                        statusIcon = Icons.paid_outlined;
                        break;
                      case 'Processing':
                        statusColor = AppColors.info;
                        statusIcon = Icons.sync_outlined;
                        break;
                      case 'On the way':
                        statusColor = AppColors.info;
                        statusIcon = Icons.local_shipping_outlined;
                        break;
                      case 'Delivered':
                        statusColor = AppColors.success;
                        statusIcon = Icons.check_circle_outline;
                        break;
                      case 'Cancelled':
                        statusColor = AppColors.error;
                        statusIcon = Icons.cancel_outlined;
                        break;
                      case 'Pending':
                      default:
                        statusColor = AppColors.warning;
                        statusIcon = Icons.hourglass_empty_outlined;
                    }

                    return BrandCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order #${order['_id'].toString().substring(order['_id'].toString().length - 6).toUpperCase()}",
                                    style: AppTextStyles.h4,
                                  ),
                                  Text(
                                    dateStr,
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                              StatusBadge(
                                text: status,
                                color: statusColor,
                                icon: statusIcon,
                              ),
                            ],
                          ),
                          const Divider(height: AppSpacing.lg),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(Icons.restaurant, color: AppColors.primaryBlue),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  summary,
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                "\$${order['total']}",
                                style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          BrandButton(
                            text: "Order Details",
                            onPressed: () {
                              Get.to(() => OrderDetailScreen(order: order));
                            },
                            variant: ButtonVariant.text,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Advice Card at bottom
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AdviceCard(
              title: "Order Status Legend",
              message: "Processing: We're preparing your food • On the way: Driver is coming • Delivered: Enjoy your meal!",
              icon: Icons.help_outline,
              color: AppColors.info,
            ),
          ),
        ],
      ),
      );
    });
  }
}
