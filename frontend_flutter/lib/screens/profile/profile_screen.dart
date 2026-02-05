import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_screen.dart';
import '../order/my_orders_screen.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
  
    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: const BrandAppBar(
          title: "Profile",
          subtitle: "Manage your account settings",
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // 👤 USER INFO
              BrandCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryOrange, width: 3),
                        boxShadow: [AppShadows.md],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: isDark ? AppColors.darkBlue : AppColors.veryLightBlue,
                        child: Icon(Icons.person, size: 60, color: isDark ? AppColors.primaryOrange : AppColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      auth.name ?? "Guest User",
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      auth.email ?? "Sign in to access more features",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    auth.isLoggedIn
                        ? const StatusBadge(
                            text: "Verified Member",
                            color: AppColors.success,
                            icon: Icons.verified_user,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Advice Card
              const AdviceCard(
                title: "Profile Tips",
                message: "Keep your email address updated to receive order confirmations and exclusive dining offers.",
                icon: Icons.tips_and_updates_outlined,
                color: AppColors.info,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Theme Tips Advice Card
              const AdviceCard(
                title: "Theme Tips",
                message: "Customize your app's appearance in settings to match your style!",
                icon: Icons.palette_outlined,
                color: AppColors.primaryBlue,
              ),

              const SizedBox(height: AppSpacing.xl),

              BrandButton(
                text: "VIEW MY ORDERS",
                onPressed: () {
                  Get.to(() => MyOrdersScreen());
                },
                isFullWidth: true,
                icon: Icons.receipt_long_outlined,
              ),

              const SizedBox(height: AppSpacing.md),

              Column(
                children: [
                  if (auth.isAdmin) ...[
                    BrandButton(
                      text: "EDIT PROFILE",
                      onPressed: () {},
                      variant: ButtonVariant.secondary,
                      isFullWidth: true,
                      icon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  if (auth.isLoggedIn)
                    BrandButton(
                      text: "LOG OUT",
                      onPressed: () {
                        auth.logout();
                        Get.offAll(() => const LoginScreen());
                      },
                      variant: ButtonVariant.outline,
                      isFullWidth: true,
                      icon: Icons.logout,
                    )
                  else
                    BrandButton(
                      text: "LOG IN",
                      onPressed: () {
                        Get.offAll(() => const LoginScreen());
                      },
                      isFullWidth: true,
                      icon: Icons.login,
                    ),
                ],
              ),
                
              const SizedBox(height: AppSpacing.xxl),
              
              Text(
                "App Version 1.0.0",
                style: AppTextStyles.caption.copyWith(color: AppColors.lightGrey),
              ),
            ],
          ),
        ),
      );
    });
  }
}
