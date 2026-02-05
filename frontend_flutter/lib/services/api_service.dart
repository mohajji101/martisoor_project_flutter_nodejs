import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiService {
  // =====================
  // BACKEND BASE URL higiuui
  // =====================

  // Mobile dhab ah:
  // static const String baseUrl = "http://10.0.2.2:5000/api";

  // BASE URL: use emulator host on Android emulators (10.0.2.2), localhost otherwise
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:5000/api";
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:5000/api";
    }
    return "http://localhost:5000/api";
  }

  // =====================
  // AUTH
  // =====================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "token": token,
        "newPassword": newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String token,
    String orderId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/orders/status"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "orderId": orderId,
        "status": status,
      }),
    );
    return jsonDecode(response.body);
  }

  // =====================
  // PRODUCTS
  // =====================

  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse("$baseUrl/products"));

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/products/categories"));
    return jsonDecode(response.body);
  }

  // =====================
  // ADMIN
  // =====================
  static Future<Map<String, dynamic>> getAdminStats(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/stats"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAdminOrders(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/orders"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAdminUsers(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/users"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteUser(String token, String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/users/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateUser(
    String token,
    String id, {
    String? name,
    String? email,
    String? role,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/users/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        if (name != null) "name": name,
        if (email != null) "email": email,
        if (role != null) "role": role,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createUser(
    String token, {
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    return jsonDecode(response.body);
  }

  // =====================
  // SETTINGS
  // =====================
  static Future<Map<String, dynamic>> getSettings() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/settings"));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateSettings(
    String token, {
    double? deliveryFee,
    double? discountPercent,
    double? minOrderForDiscount,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/admin/settings"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        if (deliveryFee != null) "deliveryFee": deliveryFee,
        if (discountPercent != null) "discountPercent": discountPercent,
        if (minOrderForDiscount != null) "minOrderForDiscount": minOrderForDiscount,
      }),
    );

    return jsonDecode(response.body);
  }

  // =====================
  // PRODUCT (ADMIN CRUD)
  // =====================
  static Future<Map<String, dynamic>> createProduct(
    String token, {
    required String title,
    required double price,
    String? image,
    String? category,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/products"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": title,
        "price": price,
        "image": image,
        "category": category,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProduct(
    String token,
    String id, {
    String? title,
    double? price,
    String? image,
    String? category,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/products/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        if (title != null) "title": title,
        if (price != null) "price": price,
        if (image != null) "image": image,
        if (category != null) "category": category,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteProduct(
    String token,
    String id,
  ) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/products/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  // =====================
  // ADMIN CATEGORIES
  // =====================
  static Future<Map<String, dynamic>> renameCategory(
    String token,
    String oldName,
    String newName,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/categories/rename"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"oldName": oldName, "newName": newName}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCategory(
    String token,
    String name,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/categories"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteCategory(
    String token,
    String name,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/categories/delete"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name}),
    );

    return jsonDecode(response.body);
  }

  // =====================
  // ORDERS (ORDER NOW)
  // =====================

  /// Create order (Cart → Backend → DB)
  static Future<Map<String, dynamic>> createOrder({
    String? token, // optional (haddii auth jirto)
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
  }) async {
    final headers = {"Content-Type": "application/json"};

    // haddii token jiro
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    final response = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: headers,
      body: jsonEncode({
        "items": items,
        "subtotal": subtotal,
        "deliveryFee": deliveryFee,
        "total": total,
      }),
    );

    return jsonDecode(response.body);
  }

  // =====================
  // SINGLE PRODUCT
  // =====================
  static Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/products/$id"));

    return jsonDecode(response.body);
  }

  // =====================
  // GET MY ORDERS
  // =====================

  static Future<List<dynamic>> getMyOrders(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/orders"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }
}
