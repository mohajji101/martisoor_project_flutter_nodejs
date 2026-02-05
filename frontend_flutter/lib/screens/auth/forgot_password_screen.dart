import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final res = await ApiService.forgotPassword(emailCtrl.text.trim());
      if (mounted) {
        if (res.containsKey('message') && res['message'].toString().contains('Reset token sent')) {
          Get.off(() => ResetPasswordScreen(email: emailCtrl.text.trim()));
          BrandSnackBar.showSuccess(context, 'Reset code sent! Check your email or backend console.');
        } else {
          BrandSnackBar.showError(context, res['message'] ?? 'Failed to send reset code');
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
      appBar: const BrandAppBar(title: "Forgot Password"),
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
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: AppColors.white,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Title
              Text(
                "Reset Your Password",
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Description
              Text(
                "Enter your email address and we'll send you a code to reset your password.",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Email Field
              BrandTextField(
                controller: emailCtrl,
                labelText: "Email",
                hintText: "Enter your email address",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Send Code Button
              BrandButton(
                text: "Send Reset Code",
                onPressed: _submit,
                isLoading: loading,
                isFullWidth: true,
                icon: Icons.send,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Back to Login",
                    style: AppTextStyles.link.copyWith(decoration: TextDecoration.none),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Advice Card
              const AdviceCard(
                title: "Password Recovery Tips",
                message: "• Check your spam folder if you don't see the email\n• The reset code expires in 1 hour\n• Contact support if you don't receive the code",
                icon: Icons.info_outline,
                color: AppColors.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
