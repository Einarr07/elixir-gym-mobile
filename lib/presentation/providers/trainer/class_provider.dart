import 'package:dio/dio.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:flutter/material.dart';

class TrainerClaseProvider extends ChangeNotifier {
  final ClaseService _service = ClaseService();
  List<Clase> clases = [];
  bool isLoading = false;
  String? error;

  Future<void> loadClases() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      clases = await _service.fetchAllClasses();
    } catch (e) {
      error = 'Error al cargar las clases: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> eliminarClase(int idClase) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.deleteClase(idClase);
      clases.removeWhere((c) => c.idClase == idClase);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        error =
            'No se puede eliminar esta clase porque tiene horarios asignados. Elimina los horarios primero.';
      } else {
        error = 'Error de conexion: ${e.error}';
      }
    } catch (e) {
      error = 'Ocurrio un error inesperado: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
