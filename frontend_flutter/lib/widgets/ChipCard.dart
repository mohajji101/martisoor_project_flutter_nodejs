import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;

  const CategoryChip(this.text, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.orangeGradient : null,
        color: selected ? null : (isDark ? AppColors.darkBlue : AppColors.veryLightBlue),
        borderRadius: BorderRadius.circular(AppRadius.round),
        boxShadow: selected ? [AppShadows.sm] : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: selected ? AppColors.white : (isDark ? Colors.white70 : AppColors.primaryBlue),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
