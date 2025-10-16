import 'package:elixir_gym/data/models/user_model.dart';
import 'package:elixir_gym/data/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../client/user_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  bool isLoading = false;
  bool isAuthenticated = false;

  AuthProvider(this._auth);

  /// Llamar en main() al iniciar la app
  Future<void> bootstrap(UserProvider userProvider) async {
    isLoading = true;
    notifyListeners();
    try {
      final me = await _auth.fetchCurrentUser(); // usa header guardado (si hay)
      userProvider.setUsuario(me);
      isAuthenticated = true;
    } catch (_) {
      isAuthenticated = false;
      userProvider.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Usuario> login({
    required String email,
    required String password,
    required UserProvider userProvider,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final me = await _auth.loginWithBasic(email: email, password: password);
      userProvider.setUsuario(me);
      isAuthenticated = true;
      return me;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(UserProvider userProvider) async {
    await _auth.logout(); // limpia secure storage
    userProvider.clear(); // limpia usuario en memoria
    isAuthenticated = false;
    notifyListeners();
  }
}
