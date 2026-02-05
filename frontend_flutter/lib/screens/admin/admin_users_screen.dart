import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool loading = true;
  bool isProcessing = false;
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    try {
      final list = await ApiService.getAdminUsers(token);
      if (mounted) {
        setState(() {
          users = list;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _deleteUser(String id) async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isProcessing = true);
    try {
      await ApiService.deleteUser(token, id);
      if (mounted) {
        BrandSnackBar.showSuccess(context, 'User deleted successfully');
        _load();
      }
    } catch (e) {
      if (mounted) {
        BrandSnackBar.showError(context, 'Error deleting user: $e');
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'] ?? 'customer';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit User Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandTextField(
                  controller: nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                BrandTextField(
                  controller: emailController,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: AppInputDecoration.standard(
                    labelText: 'System Role',
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primaryBlue),
                  ),
                  items: ['customer', 'admin'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            BrandButton(
              text: 'Save Changes',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    setState(() => isProcessing = true);
    try {
      await ApiService.updateUser(
        token,
        user['_id'],
        name: nameController.text,
        email: emailController.text,
        role: selectedRole,
      );
      if (mounted) {
        BrandSnackBar.showSuccess(context, 'User updated successfully');
        _load();
      }
    } catch (e) {
      if (mounted) {
        BrandSnackBar.showError(context, 'Error updating user: $e');
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _addUser() async {
    final token = Get.find<AuthController>().token;
    if (token == null) return;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'customer';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandTextField(
                  controller: nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter user full name',
                ),
                const SizedBox(height: AppSpacing.md),
                BrandTextField(
                  controller: emailController,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Enter user email',
                ),
                const SizedBox(height: AppSpacing.md),
                BrandTextField(
                  controller: passwordController,
                  labelText: 'Initial Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  hintText: 'Set a temporary password',
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: AppInputDecoration.standard(
                    labelText: 'System Role',
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primaryBlue),
                  ),
                  items: ['customer', 'admin'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            BrandButton(
              text: 'Create User',
              onPressed: () {
                if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                  BrandSnackBar.showError(context, 'Please fill all fields');
                  return;
                }
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    setState(() => isProcessing = true);
    try {
      final response = await ApiService.createUser(
        token,
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
      );
      
      if (mounted) {
        if (response.containsKey('_id') || response.containsKey('status') && response['status'] == 'success') {
          BrandSnackBar.showSuccess(context, 'User created successfully');
          _load();
        } else {
          BrandSnackBar.showError(context, response['message'] ?? 'Failed to create user');
        }
      }
    } catch (e) {
      if (mounted) {
        BrandSnackBar.showError(context, 'Error creating user: $e');
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode;

      return LoadingOverlay(
        isLoading: isProcessing,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: BrandAppBar(
          title: 'User Management',
          subtitle: 'Manage roles and access permissions',
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: _addUser,
              tooltip: 'Add New User',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                  : users.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          title: "No users found",
                          message: "There are no users registered in the system.",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: users.length,
                          itemBuilder: (context, i) {
                            final u = users[i];
                            final role = u['role'] ?? 'customer';
                            final isItemAdmin = role == 'admin';
                            
                            return BrandCard(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: isItemAdmin 
                                      ? AppColors.primaryOrange.withValues(alpha: 0.2) 
                                      : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBlue : AppColors.veryLightBlue),
                                  child: Icon(
                                    isItemAdmin ? Icons.admin_panel_settings : Icons.person,
                                    color: isItemAdmin ? AppColors.primaryOrange : (Theme.of(context).brightness == Brightness.dark ? AppColors.lightOrange : AppColors.primaryBlue),
                                  ),
                                ),
                                title: Text(u['name'] ?? 'Unknown User', style: AppTextStyles.h4),
                                subtitle: Text(u['email'] ?? 'No email provided', style: AppTextStyles.caption),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StatusBadge(
                                      text: role.toUpperCase(),
                                      color: isItemAdmin ? AppColors.primaryOrange : AppColors.primaryBlue,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
                                      onPressed: () => _editUser(u),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () => _deleteUser(u['_id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Advice Card
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AdviceCard(
                title: "Security Tip",
                message: "Grant administrative privileges only to trusted personnel. Regular audits of user roles are recommended for optimal security.",
                icon: Icons.security_outlined,
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ),
      );
    });
  }
}
