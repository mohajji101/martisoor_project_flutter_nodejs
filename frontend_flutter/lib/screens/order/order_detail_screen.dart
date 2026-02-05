import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = (order['items'] as List?) ?? [];
    final dateStr = order['createdAt']?.toString() ?? '';
    final status = order['status'] ?? 'Processing';
    final total = (order['total'] ?? 0).toDouble();
    final subtotal = (order['subtotal'] ?? 0).toDouble();
    final deliveryFee = (order['deliveryFee'] ?? 0).toDouble();

    DateTime? date;
    if (dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr);
    }

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

    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: BrandAppBar(
        title: "Order Details",
        subtitle: "Order #${order['_id'].toString().substring(order['_id'].toString().length - 6).toUpperCase()}",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ STATUS CARD
            BrandCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 30),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Status", style: AppTextStyles.bodySmall),
                        Text(status, style: AppTextStyles.h3.copyWith(color: statusColor)),
                      ],
                    ),
                  ),
                  if (date != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Order Date", style: AppTextStyles.bodySmall),
                        Text(DateFormat('MMM dd').format(date.toLocal()), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 📦 ITEMS LIST
            Text("Order Items", style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            ...items.map((item) => BrandCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                          item['image'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 50,
                            height: 50,
                            color: AppColors.veryLightBlue,
                            child: const Icon(Icons.restaurant, color: AppColors.primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] ?? 'Unknown Item', style: AppTextStyles.h4),
                            Text("Quantity: ${item['quantity']}", style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Text(
                        "\$${(item['lineTotal'] ?? item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}",
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: AppSpacing.lg),

            // 💵 SUMMARY
            Text("Price Summary", style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            BrandCard(
              child: Column(
                children: [
                  _summaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
                  _summaryRow("Delivery Fee", "\$${deliveryFee.toStringAsFixed(2)}"),
                  const Divider(height: 20),
                  _summaryRow("Grand Total", "\$${total.toStringAsFixed(2)}", bold: true),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Help Advice
            const AdviceCard(
              title: "Need help?",
              message: "If you have any issues with your order, please contact our support team at support@martisoor.com",
              icon: Icons.help_outline,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
    });
  }

  Widget _summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: bold ? AppTextStyles.h4 : AppTextStyles.bodyMedium.copyWith(color: AppColors.grey)),
          Text(value, style: bold ? AppTextStyles.h3.copyWith(color: AppColors.primaryOrange) : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
