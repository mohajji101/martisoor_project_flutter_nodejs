import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _name;
  String? _email;
  String? _role;

  String? get token => _token;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;

  bool get isAdmin => _role == 'admin';

  bool get isLoggedIn => _token != null;

  void setUser({
    required String token,
    required String name,
    required String email,
    String? role,
  }) {
    _token = token;
    _name = name;
    _email = email;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _name = null;
    _email = null;
    notifyListeners();
  }
}
