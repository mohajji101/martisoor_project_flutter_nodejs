import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';
import '../home/home_screen.dart';
import '../home/admin_home.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;
  String errorMessage = "";

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.containsKey("token")) {
        Get.find<AuthController>().setUser(
          token: response["token"],
          name: response["user"]["name"],
          email: response["user"]["email"],
          role: response["user"]["role"],
        );

        final role = response["user"]["role"] ?? "customer";

        if (role == 'admin') {
          Get.offAll(() => AdminHome());
        } else {
          Get.offAll(() => HomeScreen());
        }
      } else {
        setState(() {
          errorMessage = response["message"] ?? "Login failed";
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
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 2),
                  child: Column(
                    children: [
                      // Logo/Icon
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
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sign in to continue',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Section
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
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.orangeGradient,
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
                              child: const Center(
                                child: Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => RegisterScreen());
                              },
                              child: Center(
                                child: Text(
                                  "Sign Up",
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

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
                      hintText: "Enter your password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: hidePassword,
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

                    const SizedBox(height: AppSpacing.sm),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Get.to(() => ForgotPasswordScreen());
                          },
                        child: Text(
                          "Forgot Password?",
                          style: AppTextStyles.link.copyWith(
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),

                    // Error Message
                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
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

                    // Login Button
                    BrandButton(
                      text: "Log In",
                      onPressed: loginUser,
                      isLoading: isLoading,
                      isFullWidth: true,
                      icon: Icons.login,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Advice Card
                    const AdviceCard(
                      title: "Security Tip",
                      message: "Never share your password with anyone. We'll never ask for it via email or phone.",
                      icon: Icons.security,
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
