import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/product/product_detail_screen.dart';
import '../utils/theme.dart';
import 'custom_widgets.dart';

class ProductCardSimple extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  final String id;

  const ProductCardSimple({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(productId: id));
      },
      child: BrandCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: AppColors.veryLightBlue,
                    child: const Icon(Icons.fastfood, color: AppColors.primaryBlue),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    price,
                    style: AppTextStyles.price,
                  ),
                ],
              ),
            ),
            // Cart Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_shopping_cart,
                color: AppColors.primaryOrange,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
