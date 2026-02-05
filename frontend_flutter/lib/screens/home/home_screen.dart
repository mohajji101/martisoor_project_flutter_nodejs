import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../home/admin_home.dart';
import '../../widgets/ChipCard.dart';
import '../../widgets/product_card.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomeBody(),
      CartScreen(onBrowseMenu: () => setState(() => index = 0)),
      const ProfileScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,

        // 🔻 BOTTOM NAVIGATION
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [AppShadows.lg],
          ),
          child: BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: AppColors.primaryOrange,
            unselectedItemColor: AppColors.grey,
            backgroundColor: isDark ? AppColors.darkBlue : AppColors.white,
            type: BottomNavigationBarType.fixed,
            onTap: (value) {
              setState(() {
                index = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/logo/Marti Logo.png",
                  width: 24,
                  height: 24,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                label: "Cart",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        ),

        body: pages[index],
      );
    });
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late Future<List<dynamic>> productsFuture;
  late Future<List<dynamic>> categoriesFuture;
  String selectedCategory = 'All';
  String searchQuery = '';
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn && auth.isAdmin) {
        Get.offAll(() => AdminHome());
      }
    });
  }

  void _loadData() {
    productsFuture = ApiService.getProducts();
    categoriesFuture = ApiService.getCategories();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primaryOrange,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔝 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back!",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
                        ),
                        Obx(() => Text(
                          auth.isLoggedIn ? auth.name! : "Marti Soor",
                          style: AppTextStyles.h2,
                        )),
                      ],
                    ),
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        "assets/logo/Marti Logo.png",
                        width: 70, // Adjusted size for header
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const ProfileScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryOrange, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: isDark ? AppColors.darkBlue : AppColors.veryLightBlue,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: isDark ? AppColors.primaryOrange : AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // 🔍 SEARCH BAR
                BrandTextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  hintText: "Search your favorite food",
                  prefixIcon: Icons.search,
                ),

                const SizedBox(height: AppSpacing.lg),

                // 🏷️ CATEGORIES
                const Text("Categories", style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 40,
                  child: FutureBuilder<List<dynamic>>(
                    future: categoriesFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }

                      final cats = snap.data?.cast<String>() ?? [];
                      final all = ['All', ...cats];

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: all.length,
                        itemBuilder: (context, i) {
                          final c = all[i];
                          final isSel = c == selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = c;
                              });
                            },
                            child: CategoryChip(c, isSel),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 🍔 PRODUCTS
                const Text("Recommended for you", style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryOrange),
                        );
                      }

                      if (snapshot.hasError) {
                        return EmptyState(
                          icon: Icons.error_outline,
                          title: "Something went wrong",
                          message: "Failed to load products. Please check your connection.",
                          actionText: "Try Again",
                          onAction: _handleRefresh,
                        );
                      }

                      final products = snapshot.data ?? [];
                      final filtered = products.where((p) {
                        final title = (p['title'] ?? '').toString().toLowerCase();
                        final category = (p['category'] ?? '').toString();
                        
                        final matchesSearch = title.contains(searchQuery);
                        final matchesCategory = selectedCategory == 'All' || category == selectedCategory;
                        
                        return matchesSearch && matchesCategory;
                      }).toList();

                      if (filtered.isEmpty) {
                        return EmptyState(
                          icon: Icons.search_off,
                          title: "No results found",
                          message: "Try searching for something else or browse another category.",
                          actionText: "Show All",
                          onAction: () => setState(() => selectedCategory = 'All'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];

                          return GestureDetector(
                            onTap: () {
                              Get.find<CartController>().addItem(
                                CartItemModel(
                                  id: product['_id'],
                                  title: product['title'],
                                  image: product['image'],
                                  price: product['price'].toDouble(),
                                ),
                              );

                              BrandSnackBar.showSuccess(context, "${product['title']} added to cart");
                            },
                            child: ProductCardSimple(
                              id: product['_id'],
                              title: product['title'],
                              price: "\$${product['price'].toString()}",
                              image: product['image'],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      );
    });
  }
}
