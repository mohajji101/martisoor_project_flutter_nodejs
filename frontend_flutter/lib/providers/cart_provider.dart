import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ===============================
// CART ITEM MODEL
// ===============================
class CartItemModel {
  final String id;
  final String title;
  final String image;
  final double price;
  int quantity;

  CartItemModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

// ===============================
// CART PROVIDER
// ===============================
class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  // GET ITEMS
  List<CartItemModel> get items => _items;

  // SUBTOTAL
  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  // SETTINGS (from Backend)
  double _deliveryFee = 10.0;
  double _discountPercent = 0.0;
  double _minOrderForDiscount = 100.0;

  CartProvider() {
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final res = await ApiService.getSettings();
      _deliveryFee = (res['deliveryFee'] ?? 10).toDouble();
      _discountPercent = (res['discountPercent'] ?? 0).toDouble();
      _minOrderForDiscount = (res['minOrderForDiscount'] ?? 100).toDouble();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching settings: $e");
    }
  }
  
  // Use getters
  double get deliveryFee => _deliveryFee;
  double get discountPercent => _discountPercent;
  double get minOrderForDiscount => _minOrderForDiscount;

  // STORAGE
  void updateSettings(double delivery, double discount, double minOrder) {
    _deliveryFee = delivery;
    _discountPercent = discount;
    _minOrderForDiscount = minOrder;
    notifyListeners();
  }

  // TOTAL
  double get total {
    double sub = subtotal;
    if (sub == 0) return 0.0; // Return 0 if cart is empty

    // Apply discount only if subtotal >= minOrderForDiscount
    if (_discountPercent > 0 && sub >= _minOrderForDiscount) {
      sub = sub * ((100 - _discountPercent) / 100);
    }
    return sub + _deliveryFee;
  } 

  // ADD ITEM TO CART
  void addItem(CartItemModel item) {
    final index = _items.indexWhere((e) => e.id == item.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  // INCREASE QUANTITY
  void increase(String id) {
    _items.firstWhere((e) => e.id == id).quantity++;
    notifyListeners();
  }

  // DECREASE QUANTITY
  void decrease(String id) {
    final item = _items.firstWhere((e) => e.id == id);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  // PREPARE DATA FOR ORDER (BACKEND)
  List<Map<String, dynamic>> toOrderItems() {
    return _items.map((item) {
      return {
        "productId": item.id,
        "title": item.title,
        "price": item.price,
        "quantity": item.quantity,
        "image": item.image,
        "lineTotal": item.total,
      };
    }).toList();
  }

  // CLEAR CART AFTER SUCCESS ORDER
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
