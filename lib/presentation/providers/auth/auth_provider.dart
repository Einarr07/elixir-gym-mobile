// lib/presentation/providers/auth/auth_provider.dart
import 'package:elixir_gym/data/models/user_model.dart';
import 'package:elixir_gym/data/services/auth_service.dart';
import 'package:elixir_gym/utils/role_utils.dart';
import 'package:flutter/material.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;

  AuthProvider(this._auth);

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  Usuario? _usuario;
  UserRole _role = UserRole.desconocido;

  // Getters públicos
  AuthStatus get status => _status;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Usuario? get usuario => _usuario;

  UserRole get role => _role;

  // ----- Boot inicial: intenta leer sesión existente (/auth/me) -----
  Future<void> bootstrap() async {
    _setLoading(true);
    try {
      final me = await _auth
          .fetchCurrentUser(); // usa header/creds del interceptor
      _setSession(me);
    } catch (_) {
      _clearSession();
    } finally {
      _setLoading(false);
    }
  }

  // ----- Login Basic Auth -----
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final me = await _auth.loginWithBasic(email: email, password: password);
      _setSession(me);
      return me;
    } finally {
      _setLoading(false);
    }
  }

  // ----- Logout -----
  Future<void> logout() async {
    await _auth.logout(); // limpia secure storage
    _clearSession();
  }

  // ----- Refrescar datos del usuario (/auth/me) -----
  Future<void> refreshMe() async {
    if (!isAuthenticated) return;
    try {
      final me = await _auth.fetchCurrentUser();
      _setSession(me, notify: true);
    } catch (_) {
      // Si algo falla (401), AuthService ya limpió storage.
      _clearSession();
    }
  }

  // ===== helpers internos =====
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setSession(Usuario me, {bool notify = true}) {
    _usuario = me;
    _role = pickEffectiveRole(me); // PRIORIDAD: ADMIN > ENTRENADOR > CLIENTE
    _status = AuthStatus.authenticated;
    if (notify) notifyListeners();
  }

  void _clearSession() {
    _usuario = null;
    _role = UserRole.desconocido;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
