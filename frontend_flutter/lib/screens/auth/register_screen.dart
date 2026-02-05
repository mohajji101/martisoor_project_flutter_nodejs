import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;
  String errorMessage = "";
  String passwordStrength = "";
  Color strengthColor = AppColors.grey;

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        passwordStrength = "";
        strengthColor = AppColors.grey;
      });
      return;
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;

    setState(() {
      if (strength <= 2) {
        passwordStrength = "Weak";
        strengthColor = AppColors.error;
      } else if (strength <= 3) {
        passwordStrength = "Medium";
        strengthColor = AppColors.warning;
      } else {
        passwordStrength = "Strong";
        strengthColor = AppColors.success;
      }
    });
  }

  Future<void> registerUser() async {
    if (passwordController.text != confirmController.text) {
      setState(() {
        errorMessage = "Passwords do not match";
      });
      return;
    }

    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
    if (!passwordRegex.hasMatch(passwordController.text)) {
      setState(() {
        errorMessage = "Password must be at least 8 characters with uppercase, lowercase, number, and special character.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await ApiService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.containsKey("_id")) {
        Get.find<AuthController>().setUser(
          token: response["_id"],
          name: response["name"],
          email: response["email"],
        );

        Get.offAll(() => HomeScreen());
      } else {
        setState(() {
          errorMessage = response["message"] ?? "Registration failed";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Server error. Please try again.";
      });
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Gradient
              GradientContainer(
                gradient: AppColors.primaryGradient,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 1.5),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/logo/Marti Logo.png",
                          width: 80,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Join us today!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // Login/Register Toggle
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.offAll(() => LoginScreen());
                              },
                              child: Center(
                                child: Text(
                                  "Log In",
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.orangeGradient,
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Name Field
                    BrandTextField(
                      controller: nameController,
                      labelText: "Full Name",
                      hintText: "Enter your full name",
                      prefixIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Email Field
                    BrandTextField(
                      controller: emailController,
                      labelText: "Email",
                      hintText: "Enter your email",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Password Field
                    BrandTextField(
                      controller: passwordController,
                      labelText: "Password",
                      hintText: "Create a strong password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: hidePassword,
                      onChanged: checkPasswordStrength,
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

                    // Password Strength Indicator
                    if (passwordStrength.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            "Password Strength: ",
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            passwordStrength,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: strengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    // Confirm Password Field
                    BrandTextField(
                      controller: confirmController,
                      labelText: "Confirm Password",
                      hintText: "Re-enter your password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: hideConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            hideConfirm = !hideConfirm;
                          });
                        },
                      ),
                    ),

                    // Error Message
                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // Register Button
                    BrandButton(
                      text: "Sign Up",
                      onPressed: registerUser,
                      isLoading: isLoading,
                      isFullWidth: true,
                      icon: Icons.person_add,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Password Requirements Advice
                    const AdviceCard(
                      title: "Password Requirements",
                      message: "• At least 8 characters\n• One uppercase letter\n• One lowercase letter\n• One number\n• One special character (!@#\$&*~)",
                      icon: Icons.info_outline,
                      color: AppColors.info,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      );
    });
  }
}
