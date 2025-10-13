// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:elixir_gym/core/storage/auth_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient._() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      // Opcional: lanza para detectarlo temprano
      throw Exception('API_BASE_URL no definido en .env');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // LOGS de depuración (sin exponer Authorization):
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        // evita imprimir Authorization
        responseHeader: false,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final header = await AuthStorage.instance.getAuthHeader();
          if (header != null && header.isNotEmpty) {
            options.headers['Authorization'] = header;
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient _i = ApiClient._();

  factory ApiClient() => _i;

  late final Dio dio;
}
