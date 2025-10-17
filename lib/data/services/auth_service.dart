// lib/data/services/auth_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/core/storage/auth_storage.dart';
import 'package:elixir_gym/data/models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  static const String _mePath = '/auth/me';

  /// Login con Basic Auth contra un endpoint protegido que retorna el Usuario.
  /// - Construye Authorization: Basic ...
  /// - Si OK: persiste credenciales y header para futuros requests.
  Future<Usuario> loginWithBasic({
    required String email,
    required String password,
  }) async {
    final basicHeader =
        'Basic ${base64Encode(utf8.encode('$email:$password'))}';

    try {
      final res = await _dio.get(
        _mePath,
        options: Options(headers: {'Authorization': basicHeader}),
      );

      // Persistimos TODO: credenciales + header (por si luego quieres leerlo directo)
      await AuthStorage.instance.saveCredentials(email, password);
      await AuthStorage.instance.saveAuthHeader(basicHeader);

      final data = res.data as Map<String, dynamic>;
      return Usuario.fromJson(data);
    } on DioException catch (e) {
      // Limpia por si acaso hubo intento fallido
      await AuthStorage.instance.clearAll();

      // Mensaje más claro hacia arriba (puedes mapear por statusCode)
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales inválidas.');
      }
      rethrow;
    }
  }

  /// Obtiene el usuario actual usando el interceptor (Authorization ya puesto).
  Future<Usuario> fetchCurrentUser() async {
    try {
      final res = await _dio.get(_mePath);
      return Usuario.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthStorage.instance.clearAll();
      }
      rethrow;
    }
  }

  Future<void> logout() => AuthStorage.instance.clearAll();
}
