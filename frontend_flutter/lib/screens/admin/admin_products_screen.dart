import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  bool loading = true;
  bool isProcessing = false;
  List<dynamic> products = [];
  List<String> categories = [];
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final list = await ApiService.getProducts();
      final cats = await ApiService.getCategories();
      if (mounted) {
        setState(() {
          products = list;
          categories = cats.cast<String>();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _manageCategories() async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final addCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Manage Categories'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('No categories yet.'),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        final c = categories[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(c, style: AppTextStyles.h4),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
                                onPressed: () async {
                                  final newName = await showDialog<String>(
                                    context: context,
                                    builder: (_) {
                                      final ctrl = TextEditingController(text: c);
                                      return AlertDialog(
                                        title: const Text('Rename Category'),
                                        content: BrandTextField(
                                          controller: ctrl,
                                          labelText: 'Category Name',
                                          prefixIcon: Icons.category_outlined,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          BrandButton(
                                            text: 'Rename',
                                            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (newName != null && newName.isNotEmpty && newName != c) {
                                    await ApiService.renameCategory(token, c, newName);
                                    _changed = true;
                                    await _load();
                                    setDialogState(() {}); // Refresh local list
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete Category'),
                                      content: Text('Delete category "$c"? Products will remain but lose this category.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: AppColors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await ApiService.deleteCategory(token, c);
                                    _changed = true;
                                    await _load();
                                    setDialogState(() {}); // Refresh local list
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: BrandTextField(
                          controller: addCtrl,
                          labelText: 'New Category',
                          prefixIcon: Icons.add,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: () async {
                          final name = addCtrl.text.trim();
                          if (name.isNotEmpty) {
                            await ApiService.createCategory(token, name);
                            addCtrl.clear();
                            _changed = true;
                            await _load();
                            setDialogState(() {});
                          }
                        },
                        icon: const Icon(Icons.check_circle, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog([Map<String, dynamic>? product]) async {
    final titleCtrl = TextEditingController(text: product?['title'] ?? '');
    final priceCtrl = TextEditingController(text: product != null ? product['price'].toString() : '');
    final imageCtrl = TextEditingController(text: product?['image'] ?? '');
    String category = product?['category'] ?? '';

    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(product == null ? 'Add New Product' : 'Edit Product'),
            content: SizedBox(
              width: 400, // Stabilize layout on Web/Desktop
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandTextField(
                      controller: titleCtrl,
                      labelText: 'Product Title',
                      prefixIcon: Icons.fastfood_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BrandTextField(
                      controller: priceCtrl,
                      labelText: 'Price',
                      prefixText: '\$ ',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BrandTextField(
                      controller: imageCtrl,
                      labelText: 'Image URL',
                      prefixIcon: Icons.image_outlined,
                    ),
                    if (imageCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                          imageCtrl.text,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100,
                            color: AppColors.veryLightBlue,
                            child: const Icon(Icons.broken_image, color: AppColors.primaryBlue),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      // Ensure the initial value exists in the categories list to prevent a Flutter assertion crash
                      value: categories.contains(category) 
                          ? category 
                          : (categories.isNotEmpty ? categories.first : null),
                      decoration: AppInputDecoration.standard(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primaryBlue),
                      ),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => category = v);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              BrandButton(
                text: product == null ? 'Create' : 'Save',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );
        },
      ),
    );

    if (res == true) {
      if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
        if (mounted) BrandSnackBar.showError(context, "Title and Price are required");
        return;
      }
      
      setState(() => isProcessing = true);
      try {
        if (product == null) {
          await ApiService.createProduct(token, title: titleCtrl.text, price: double.parse(priceCtrl.text), image: imageCtrl.text, category: category);
          if (mounted) BrandSnackBar.showSuccess(context, "Product created successfully");
        } else {
          await ApiService.updateProduct(token, product['_id'], title: titleCtrl.text, price: double.parse(priceCtrl.text), image: imageCtrl.text, category: category);
          if (mounted) BrandSnackBar.showSuccess(context, "Product updated successfully");
        }
        _changed = true;
        _load();
      } catch (e) {
        if (mounted) BrandSnackBar.showError(context, "Operation failed: $e");
      } finally {
        if (mounted) setState(() => isProcessing = false);
      }
    }
  }

  Future<void> _deleteProduct(String id, String title) async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$title"? This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => isProcessing = true);
      try {
        await ApiService.deleteProduct(token, id);
        _changed = true;
        if (mounted) BrandSnackBar.showSuccess(context, "Product removed from menu");
        _load();
      } catch (e) {
        if (mounted) BrandSnackBar.showError(context, "Deletion failed: $e");
      } finally {
        if (mounted) setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Get.back(result: _changed);
        },
        child: LoadingOverlay(
          isLoading: isProcessing,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
            appBar: BrandAppBar(
            title: 'Menu Management',
            subtitle: 'Catalog of your restaurant items',
            actions: [
              IconButton(
                tooltip: 'Manage Categories',
                icon: const Icon(Icons.category_outlined), 
                onPressed: _manageCategories
              ),
              IconButton(
                tooltip: 'Add New Item',
                icon: const Icon(Icons.add_circle_outline), 
                onPressed: () => _showEditDialog()
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                    : products.isEmpty
                        ? EmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: "Your menu is empty",
                            message: "Start adding delicious meals to your menu to begin serving customers.",
                            actionText: "Add First Product",
                            onAction: () => _showEditDialog(),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.primaryOrange,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                final p = products[i];
                                return BrandCard(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                        child: Image.network(
                                          p['image'] ?? '',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: AppColors.veryLightBlue,
                                            child: const Icon(Icons.fastfood, color: AppColors.primaryBlue, size: 30),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p['title'] ?? 'Untitled', style: AppTextStyles.h4),
                                            const SizedBox(height: AppSpacing.xs),
                                            Text('\$${p['price']?.toString() ?? '0.00'}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                                            if (p['category'] != null && p['category'].toString().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: AppSpacing.xs),
                                                child: StatusBadge(text: p['category'], color: AppColors.primaryBlue),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20), 
                                            onPressed: () => _showEditDialog(p)
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), 
                                            onPressed: () => _deleteProduct(p['_id'], p['title'])
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AdviceCard(
                  title: "Manager Insight",
                  message: "High-quality photos and accurate pricing increase conversion by up to 35%. Categorize items properly to help customers find what they want faster.",
                  icon: Icons.lightbulb_outline,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          floatingActionButton: products.isNotEmpty 
            ? FloatingActionButton(
                onPressed: () => _showEditDialog(),
                backgroundColor: AppColors.primaryOrange,
                child: const Icon(Icons.add, color: AppColors.white),
              )
            : null,
        ),
      ),
    );
    });
  }
}
