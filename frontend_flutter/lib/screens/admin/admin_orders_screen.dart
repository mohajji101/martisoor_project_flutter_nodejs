import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool loading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    try {
      final list = await ApiService.getAdminOrders(token);
      if (mounted) {
        setState(() {
          orders = list;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: const BrandAppBar(
        title: 'Manage Orders',
        subtitle: 'Update order status and track sales',
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                : orders.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: "No orders yet",
                        message: "There are no customer orders in the system yet.",
                        actionText: "Check Dashboard",
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.primaryOrange,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: orders.length,
                          itemBuilder: (context, i) {
                            final o = orders[i];
                            final total = (o['total'] ?? 0).toDouble();
                            final status = o['status'] ?? 'Payment Completed';
                            final dateStr = o['createdAt'] ?? '';
                            final user = o['user'];
                            final userName = user != null ? user['name'] : (o['userName'] ?? 'Guest');
                            final userEmail = user != null ? user['email'] : (o['userEmail'] ?? '-');

                            DateTime? date;
                            if (dateStr != null) {
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
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                collapsedIconColor: AppColors.primaryBlue,
                                iconColor: AppColors.primaryOrange,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order # ${o['_id'].toString().substring(o['_id'].toString().length - 6).toUpperCase()}', style: AppTextStyles.h4),
                                          Text(userName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue)),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(text: status, color: statusColor, icon: statusIcon),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    '${date != null ? DateFormat('MMM dd, HH:mm').format(date.toLocal()) : ''} • \$${total.toStringAsFixed(2)}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                                  ),
                                ),
                                children: [
                                  const Divider(),
                                  if (userEmail != '-')
                                    ListTile(
                                      leading: const Icon(Icons.email_outlined, size: 18),
                                      title: Text(userEmail, style: AppTextStyles.bodySmall),
                                      dense: true,
                                    ),
                                  const Divider(),
                                  ...(o['items'] as List<dynamic>? ?? []).map((item) {
                                    return ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                        child: item['image'] != null
                                            ? Image.network(item['image'], width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.fastfood))
                                            : const Icon(Icons.fastfood),
                                      ),
                                      title: Text('${item['title']}', style: AppTextStyles.bodyMedium),
                                      subtitle: Text('Quantity: ${item['quantity']}', style: AppTextStyles.caption),
                                      trailing: Text('\$${(item['lineTotal'] ?? 0).toString()}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                    );
                                  }),
                                  const Divider(),
                                  summaryRow("Subtotal", "\$${(o['subtotal'] ?? 0).toString()}"),
                                  summaryRow("Delivery", "\$${(o['deliveryFee'] ?? 0).toString()}"),
                                  summaryRow("Total Amount", "\$${total.toStringAsFixed(2)}", bold: true),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                          decoration: BoxDecoration(
                                            color: AppColors.veryLightBlue,
                                            borderRadius: BorderRadius.circular(AppRadius.md),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: ['Pending', 'Payment Completed', 'Processing', 'Delivered', 'Cancelled'].contains(status) ? status : 'Pending',
                                              onChanged: (newStatus) async {
                                                if (newStatus == null) return;
                                                setState(() => o['status'] = newStatus);
                                                
                                                final auth = Get.find<AuthController>();
                                                try {
                                                  await ApiService.updateOrderStatus(auth.token!, o['_id'], newStatus);
                                                  if (context.mounted) {
                                                    BrandSnackBar.showSuccess(context, "Order status updated to $newStatus");
                                                  }
                                                } catch (e) {
                                                  setState(() => o['status'] = status);
                                                  if (context.mounted) {
                                                    BrandSnackBar.showError(context, "Failed to update status");
                                                  }
                                                }
                                              },
                                              items: ['Pending', 'Payment Completed', 'Processing', 'Delivered', 'Cancelled']
                                                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
          // Advice Card at bottom
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AdviceCard(
              title: "Operational Tip",
              message: "Fulfilling orders quickly and updating the status accurately helps maintain high customer satisfaction ratings.",
              icon: Icons.lightbulb_outline,
              color: AppColors.primaryOrange,
            ),
          ),
        ],
      ),
      );
    });
  }
}

// Reusing summaryRow logic
Widget summaryRow(String title, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: bold ? AppTextStyles.h4 : AppTextStyles.bodySmall),
        Text(value, style: bold ? AppTextStyles.h4.copyWith(color: AppColors.primaryOrange) : AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
