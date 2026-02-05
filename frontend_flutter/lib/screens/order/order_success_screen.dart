import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_screen.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎉 ICON
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppColors.orangeGradient,
                    shape: BoxShape.circle,
                    boxShadow: [AppShadows.md],
                  ),
                  child: const Icon(Icons.check, size: 60, color: AppColors.white),
                ),

                const SizedBox(height: AppSpacing.xl),

                // TEXT
                Text(
                  "Order Successful!",
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  "Thank you for your order!\nWe've received your request and our kitchen is already preparing your delicious meal.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Advice Card
                const AdviceCard(
                  title: "Tracking Information",
                  message: "You can track your order status in real-time under the 'My Orders' section in your profile.",
                  icon: Icons.info_outline,
                  color: AppColors.info,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // BUTTONS
                BrandButton(
                  text: "TRACK ORDER",
                  onPressed: () {
                    // Navigate to My Orders logic can go here
                  },
                  isFullWidth: true,
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                BrandButton(
                  text: "Continue Shopping",
                  onPressed: () {
                    Get.offAll(() => HomeScreen());
                  },
                  variant: ButtonVariant.outline,
                  isFullWidth: true,
                  icon: Icons.restaurant_menu,
                ),
              ],
            ),
          ),
        ),
      ),
      );
    });
  }
}
