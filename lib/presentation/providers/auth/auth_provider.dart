import 'package:elixir_gym/core/storage/auth_storage.dart';
import 'package:elixir_gym/data/models/user_model.dart';
import 'package:elixir_gym/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  Usuario? _usuario;
  bool _loading = false;
  String? _error;

  Usuario? get user => _usuario;

  bool get isLoading => _loading;

  String? get error => _error;

  bool get isAuthenticated => _usuario != null;

  // App start: If exist save header, get the user.
  Future<void> bootstrap() async {
    final header = await AuthStorage.instance.getAuthHeader();
    if (header == null) {
      _usuario = null;
      notifyListeners();
      return;
    }
    try {
      _loading = true;
      notifyListeners();
      _usuario = await _authService.fetchCurrentUser();
    } catch (_) {
      await _authService.logout();
      _usuario = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      _usuario = await _authService.loginWithBasic(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _error = 'Credenciales invalidas o error de red';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _usuario = null;
    notifyListeners();
  }
}
