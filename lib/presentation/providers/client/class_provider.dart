import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:flutter/material.dart';

class ClaseProvider extends ChangeNotifier {
  final _service = ClaseService();
  List<Clase> clases = [];
  bool isLoading = false;
  String? error;

  Future<void> cargarClases() async {
    try {
      isLoading = true;
      notifyListeners();

      clases = await _service.fetchClases();
      error = null;
    } catch (e) {
      error = 'Error al cargar clases';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
