import 'package:get/get.dart';
import '../services/api_service.dart';

class CartItemModel {
  final String id;
  final String title;
  final String image;
  final double price;
  final RxInt quantity;

  CartItemModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    int quantity = 1,
  }) : quantity = quantity.obs;

  double get total => price * quantity.value;
}

class CartController extends GetxController {
  final items = <CartItemModel>[].obs;

  final RxDouble _deliveryFee = 10.0.obs;
  final RxDouble _discountPercent = 0.0.obs;
  final RxDouble _minOrderForDiscount = 100.0.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final res = await ApiService.getSettings();
      _deliveryFee.value = (res['deliveryFee'] ?? 10).toDouble();
      _discountPercent.value = (res['discountPercent'] ?? 0).toDouble();
      _minOrderForDiscount.value = (res['minOrderForDiscount'] ?? 100).toDouble();
    } catch (e) {
      print("Error fetching settings: $e");
    }
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  double get deliveryFee => _deliveryFee.value;
  double get discountPercent => _discountPercent.value;
  double get minOrderForDiscount => _minOrderForDiscount.value;

  double get total {
    double sub = subtotal;
    if (sub == 0) return 0.0;

    if (_discountPercent.value > 0 && sub >= _minOrderForDiscount.value) {
      sub = sub * ((100 - _discountPercent.value) / 100);
    }
    return sub + _deliveryFee.value;
  }

  void addItem(CartItemModel item) {
    final index = items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      items[index].quantity.value += item.quantity.value;
    } else {
      items.add(item);
    }
  }

  void increase(String id) {
    items.firstWhere((e) => e.id == id).quantity.value++;
  }

  void decrease(String id) {
    final item = items.firstWhere((e) => e.id == id);
    if (item.quantity.value > 1) {
      item.quantity.value--;
    } else {
      items.remove(item);
    }
  }

  List<Map<String, dynamic>> toOrderItems() {
    return items.map((item) {
      return {
        "productId": item.id,
        "title": item.title,
        "price": item.price,
        "quantity": item.quantity.value,
        "image": item.image,
        "lineTotal": item.total,
      };
    }).toList();
  }

  void clear() {
    items.clear();
  }

  void updateSettings(double delivery, double discount, double minOrder) {
    _deliveryFee.value = delivery;
    _discountPercent.value = discount;
    _minOrderForDiscount.value = minOrder;
  }
}