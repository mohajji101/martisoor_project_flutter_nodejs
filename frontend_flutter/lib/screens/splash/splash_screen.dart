import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../home/admin_home.dart';
import '../../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate after delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        final auth = Get.find<AuthController>();
        Widget nextScreen;
        
        if (auth.isLoggedIn) {
          nextScreen = auth.isAdmin ? const AdminHome() : const HomeScreen();
        } else {
          nextScreen = const LoginScreen();
        }

        Get.offAll(() => nextScreen);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.blueOrangeGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        "assets/logo/Marti Logo.png",
                        width: 200,
                        // Removed color filter to show full brand colors
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image doesn't exist
                          return const Icon(
                            Icons.restaurant_menu,
                            size: 120,
                            color: AppColors.white,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // App Name
                      const Text(
                        'Marti Soor Restaurant',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Tagline
                      Text(
                        'Order your favorite meals',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
