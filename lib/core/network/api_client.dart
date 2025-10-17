// lib/core/network/api_client.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:elixir_gym/core/storage/auth_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient._() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      throw Exception('API_BASE_URL no definido en .env');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl, // ej: http://192.168.0.6:8080/api
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1) Interceptor de Auth (colócalo antes del logger)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // a) Si guardaste el header, úsalo
          final savedHeader = await AuthStorage.instance.getAuthHeader();
          if (savedHeader != null && savedHeader.isNotEmpty) {
            options.headers['Authorization'] = savedHeader;
            return handler.next(options);
          }

          // b) Fallback: construye Basic a partir de user/pass
          final creds = await AuthStorage.instance.readCredentials();
          final user = creds.user;
          final pass = creds.pass;
          if (user != null &&
              user.isNotEmpty &&
              pass != null &&
              pass.isNotEmpty) {
            final basic = base64Encode(utf8.encode('$user:$pass'));
            options.headers['Authorization'] = 'Basic $basic';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          // 2) Si expira o falla auth, limpia credenciales
          if (e.response?.statusCode == 401) {
            await AuthStorage.instance.clearAll();
          }
          return handler.next(e);
        },
      ),
    );

    // 3) Logger (sin headers)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: false,
        // no loguear headers
        responseHeader: false,
        // no loguear headers
        responseBody: true,
      ),
    );
  }

  static final ApiClient _i = ApiClient._();

  factory ApiClient() => _i;

  late final Dio dio;

  /// (Opcional) Si quieres guardar el header calculado una sola vez.
  Future<void> setBasicHeaderFrom(String user, String pass) async {
    final basic = base64Encode(utf8.encode('$user:$pass'));
    await AuthStorage.instance.saveAuthHeader('Basic $basic');
  }
}
