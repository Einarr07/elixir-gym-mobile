// lib/data/services/auth_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/core/storage/auth_storage.dart';
import 'package:elixir_gym/data/models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  static const String _mePath = '/auth/me';

  /// Login con Basic Auth:
  /// - Construye "Basic base64(email:password)"
  /// - Llama a un endpoint protegido que retorna el usuario autenticado
  Future<Usuario> loginWithBasic({
    required String email,
    required String password,
  }) async {
    final basic = 'Basic ${base64Encode(utf8.encode('$email:$password'))}';

    final res = await _dio.get(
      _mePath,
      options: Options(headers: {'Authorization': basic}),
    );

    // Si llegó aquí, credenciales OK: persistimos el header para siguientes requests
    await AuthStorage.instance.saveAuthHeader(basic);

    final data = res.data as Map<String, dynamic>;
    return Usuario.fromJson(data);
  }

  /// Obtiene el usuario actual usando el header guardado por el interceptor
  Future<Usuario> fetchCurrentUser() async {
    final res = await _dio.get(_mePath);
    return Usuario.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() => AuthStorage.instance.clear();
}
