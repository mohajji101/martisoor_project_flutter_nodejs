import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../admin/admin_products_screen.dart';
import '../admin/admin_orders_screen.dart';
import '../admin/admin_users_screen.dart';
import '../admin/admin_settings_screen.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool loading = true;
  Map<String, dynamic> stats = {};
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadStats(),
    );
  }

  Future<void> _loadStats() async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    try {
      final res = await ApiService.getAdminStats(token);
      if (mounted) {
        setState(() {
          stats = res;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          stats = {};
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: BrandAppBar(
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Image.asset("assets/logo/Marti Logo.png"),
        ),
        title: 'Admin Dashboard',
        subtitle: 'Management Terminal',
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().logout();
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Overview',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Real-time statistics of your restaurant',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    children: [
                      _DashboardCard(
                        title: 'Products',
                        value: '${stats['products'] ?? 0}',
                        icon: Icons.fastfood_outlined,
                        color: AppColors.primaryOrange,
                        onTap: () async {
                           final changed = await Get.to<bool?>(() => AdminProductsScreen());
                           if (changed == true) _loadStats();
                        },
                      ),
                      _DashboardCard(
                        title: 'Orders',
                        value: '${stats['orders'] ?? 0}',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.primaryBlue,
                        onTap: () {
                           Get.to(() => AdminOrdersScreen());
                        },
                      ),
                      _DashboardCard(
                        title: 'Users',
                        value: '${stats['users'] ?? 0}',
                        icon: Icons.people_outline,
                        color: AppColors.success,
                        onTap: () {
                           Get.to(() => AdminUsersScreen());
                        },
                      ),
                      _DashboardCard(
                        title: 'Revenue',
                        value: '\$${(double.tryParse((stats['revenue'] ?? 0).toString()) ?? 0).toStringAsFixed(2)}',
                        icon: Icons.monetization_on_outlined,
                        color: AppColors.primaryBlue,
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Management Actions
                  Text('Core Management', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  BrandCard(
                    onTap: () {
                       Get.to(() => AdminSettingsScreen());
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBlue : AppColors.veryLightBlue,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(Icons.settings_outlined, color: isDark ? AppColors.lightOrange : AppColors.primaryBlue),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Global Settings', style: AppTextStyles.h4),
                              Text('Control delivery fees, discounts, and app behavior', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.lightGrey),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Advice Card
                  const AdviceCard(
                    title: "Admin Insight",
                    message: "Monitor your revenue trends daily and adjust product availability during peak hours to maintain delivery speeds.",
                    icon: Icons.analytics_outlined,
                    color: AppColors.info,
                  ),
                ],
              ),
            ),
      );
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      onTap: onTap,
      elevated: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.h2,
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
