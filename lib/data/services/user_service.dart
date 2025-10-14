import 'package:dio/dio.dart';
import 'package:elixir_gym/core/network/api_client.dart';
import 'package:elixir_gym/data/models/user_model.dart';

class UserService {
  final Dio _dio = ApiClient().dio;

  Future<Usuario> fetchUsuario(int id) async {
    final res = await _dio.get('/usuario/$id');
    return Usuario.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Usuario> updateUsuario({
    required int id,
    required String nombre,
    required String apellido,
    required String correo,
    String? contrasenia,
    required telefono,
    required String fechaNacimiento,
    required double peso,
    required double altura,
    String estado = "Activo",
  }) async {
    final payload = {
      "nombre": nombre,
      "apellido": apellido,
      "correo": correo,
      if (contrasenia != null && contrasenia.isNotEmpty)
        "contrasenia": contrasenia,
      "telefono": telefono,
      "fechaNacimiento": fechaNacimiento,
      "peso": peso,
      "altura": altura,
      "estado": estado,
    };

    final res = await _dio.put('/usuario/actualizar/$id', data: payload);
    return Usuario.fromJson(res.data as Map<String, dynamic>);
  }
}
