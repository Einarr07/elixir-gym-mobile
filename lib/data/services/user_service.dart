import 'dart:convert';

import 'package:elixir_gym/data/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  Future<Usuario> fetchUsuario(int id) async {
    final url = Uri.parse('$baseUrl/usuario/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar usuario: ${response.statusCode}');
    }
  }
}
