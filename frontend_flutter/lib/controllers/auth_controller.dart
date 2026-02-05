import 'package:get/get.dart';

class AuthController extends GetxController {
  final _token = RxnString();
  final _name = RxnString();
  final _email = RxnString();
  final _role = RxnString();

  String? get token => _token.value;
  String? get name => _name.value;
  String? get email => _email.value;
  String? get role => _role.value;

  bool get isAdmin => _role.value == 'admin';
  bool get isLoggedIn => _token.value != null;

  void setUser({
    required String token,
    required String name,
    required String email,
    String? role,
  }) {
    _token.value = token;
    _name.value = name;
    _email.value = email;
    _role.value = role;
  }

  void logout() {
    _token.value = null;
    _name.value = null;
    _email.value = null;
    _role.value = null;
  }
}
