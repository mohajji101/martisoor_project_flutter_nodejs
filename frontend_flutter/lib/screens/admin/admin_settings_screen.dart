import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final deliveryCtrl = TextEditingController();
  final discountCtrl = TextEditingController();
  final minOrderCtrl = TextEditingController();
  bool loading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.getSettings();
      deliveryCtrl.text = (data['deliveryFee'] ?? 0).toString();
      discountCtrl.text = (data['discountPercent'] ?? 0).toString();
      minOrderCtrl.text = (data['minOrderForDiscount'] ?? 100).toString();
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => isSaving = true);
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final delivery = double.tryParse(deliveryCtrl.text) ?? 0;
    final discount = double.tryParse(discountCtrl.text) ?? 0;
    final minOrder = double.tryParse(minOrderCtrl.text) ?? 0;

    try {
      await ApiService.updateSettings(
        token,
        deliveryFee: delivery,
        discountPercent: discount,
        minOrderForDiscount: minOrder,
      );
      if (context.mounted) {
        BrandSnackBar.showSuccess(context, 'Global settings updated successfully');
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        BrandSnackBar.showError(context, 'Failed to update settings');
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return LoadingOverlay(
        isLoading: isSaving,
        message: "Saving settings...",
        child: Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: const BrandAppBar(
          title: 'Global Settings',
          subtitle: 'Configure app-wide parameters',
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Financial Configuration", style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Text("Adjust fees and discount rules for all customers.", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey)),
                    const SizedBox(height: AppSpacing.xl),
                    
                    BrandCard(
                      child: Column(
                        children: [
                          BrandTextField(
                            controller: deliveryCtrl,
                            labelText: 'Delivery Fee',
                            prefixText: '\$ ',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.delivery_dining_outlined,
                            helperText: "Flat fee charged per order",
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BrandTextField(
                            controller: discountCtrl,
                            labelText: 'Discount Percentage',
                            prefixText: '% ',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.discount_outlined,
                            helperText: "Percentage discount to apply",
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BrandTextField(
                            controller: minOrderCtrl,
                            labelText: 'Min Order for Discount',
                            prefixText: '\$ ',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.shopping_bag_outlined,
                            helperText: "Minimum subtotal to trigger discount",
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Advice Card
                    const AdviceCard(
                      title: "Business Strategy",
                      message: "Setting a minimum order for discounts encourages higher average order values. High delivery fees might reduce order frequency.",
                      icon: Icons.lightbulb_outline,
                      color: AppColors.primaryOrange,
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    BrandButton(
                      text: "SAVE CONFIGURATION",
                      onPressed: _save,
                      isFullWidth: true,
                      icon: Icons.save_outlined,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    BrandButton(
                      text: "Reset to Defaults",
                      onPressed: () {
                        deliveryCtrl.text = "2.0";
                        discountCtrl.text = "0.0";
                        minOrderCtrl.text = "100.0";
                      },
                      variant: ButtonVariant.text,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
      ),
      );
    });
  }
}
