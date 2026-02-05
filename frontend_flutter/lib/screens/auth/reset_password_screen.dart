import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final tokenCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool hidePassword = true;

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final res = await ApiService.resetPassword(
        widget.email,
        tokenCtrl.text.trim(),
        passCtrl.text.trim(),
      );
      if (mounted) {
        if (res.containsKey('message') && res['message'].toString().contains('successful')) {
          BrandSnackBar.showSuccess(context, 'Password reset successful! Please login.');
          Get.offAll(() => LoginScreen());
        } else {
          BrandSnackBar.showError(context, res['message'] ?? 'Failed to reset password');
        }
      }
    } catch (e) {
      if (mounted) {
        BrandSnackBar.showError(context, 'Network error. Please try again.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(title: "Reset Password"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vpn_key,
                  size: 60,
                  color: AppColors.white,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Title
              Text(
                "Create New Password",
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Email Display
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.veryLightBlue,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      widget.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Reset Code Field
              BrandTextField(
                controller: tokenCtrl,
                labelText: "Reset Code",
                hintText: "Enter the code from your email",
                prefixIcon: Icons.pin,
                helperText: "Check your email or backend console",
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // New Password Field
              BrandTextField(
                controller: passCtrl,
                labelText: "New Password",
                hintText: "Create a strong password",
                prefixIcon: Icons.lock_outline,
                obscureText: hidePassword,
                helperText: "Must include uppercase, lowercase, number, and special character",
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Reset Button
              BrandButton(
                text: "Reset Password",
                onPressed: _submit,
                isLoading: loading,
                isFullWidth: true,
                icon: Icons.check_circle,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.offAll(() => LoginScreen());
                  },
                  child: Text(
                    "Back to Login",
                    style: AppTextStyles.link.copyWith(decoration: TextDecoration.none),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Advice Card
              const AdviceCard(
                title: "Security Reminder",
                message: "• Use a unique password you haven't used before\n• Don't share your password with anyone\n• Consider using a password manager",
                icon: Icons.security,
                color: AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
