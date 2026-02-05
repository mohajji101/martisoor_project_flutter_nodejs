import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/theme.dart';
import '../controllers/theme_controller.dart';

/// Brand Button - Primary, Secondary, Outline variants
class BrandButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const BrandButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (variant == ButtonVariant.outline) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: AppButtonStyles.outline,
        child: _buildChild(),
      );
    } else if (variant == ButtonVariant.text) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: AppButtonStyles.text,
        child: _buildChild(),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: variant == ButtonVariant.primary
            ? AppButtonStyles.primary
            : AppButtonStyles.secondary,
        child: _buildChild(),
      );
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

enum ButtonVariant { primary, secondary, outline, text }

/// Brand Card - Consistent card styling
class BrandCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool elevated;
  final bool useGradient;

  const BrandCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = false,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final decoration = useGradient
        ? AppCardStyles.gradient
        : (elevated 
            ? AppCardStyles.elevated.copyWith(color: isDark ? AppColors.cardDark : AppColors.white) 
            : AppCardStyles.standard.copyWith(color: isDark ? AppColors.cardDark : AppColors.white));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: decoration,
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );
  }
}

/// Brand TextField - Styled input fields
class BrandTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final String? prefixText;

  const BrandTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: AppInputDecoration.standard(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryBlue) : null,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
      ),
    );
  }
}

/// Brand AppBar - Gradient app bar
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool useGradient;
  final Widget? leading;

  const BrandAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.useGradient = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Container(
      decoration: useGradient
          ? const BoxDecoration(gradient: AppColors.primaryGradient)
          : BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBlue : AppColors.primaryBlue),
      child: AppBar(
        title: subtitle != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
                  ),
                ],
              )
            : Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          ...?actions,
          Obx(() => IconButton(
            icon: Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: AppColors.white),
            onPressed: () => themeController.toggleTheme(),
            tooltip: "Toggle Theme",
          )),
        ],
        leading: leading,
        iconTheme: const IconThemeData(color: AppColors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Loading Overlay - Branded loading indicator
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: BrandCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(message!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty State - Consistent empty states
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: AppColors.lightGrey),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.grey)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                BrandButton(
                  text: actionText!,
                  onPressed: onAction!,
                  variant: ButtonVariant.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                const Icon(Icons.fastfood_outlined, color: AppColors.primaryOrange, size: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Advice Card - Tips and guidance display
class AdviceCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;

  const AdviceCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lightbulb_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.info;

    return BrandCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cardColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(color: cardColor),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Status Badge - Colored status indicators
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient Container - For backgrounds
class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;

  const GradientContainer({
    super.key,
    required this.child,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

/// Success/Error Snackbar helpers
class BrandSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: AppColors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: AppColors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }
}
