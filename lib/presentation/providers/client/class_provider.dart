import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:flutter/material.dart';

class ClaseProvider extends ChangeNotifier {
  final _service = ClaseService();

  // cache: idClase -> Clase
  final Map<int, Clase> _cache = {};

  // loading por id (simple)
  final Set<int> _loading = {};

  // errores por id (opcional)
  final Map<int, String> _errors = {};

  Clase? getClase(int id) => _cache[id];

  bool isLoading(int id) => _loading.contains(id);

  String? error(int id) => _errors[id];

  /// Obtiene la clase; si no está en caché, la trae del API y la guarda.
  Future<void> fetchClase(int id) async {
    if (_cache.containsKey(id) || _loading.contains(id))
      return; // evita duplicar
    _loading.add(id);
    _errors.remove(id);
    notifyListeners();

    try {
      final clase = await _service.fetchClaseById(id);
      _cache[id] = clase;
    } catch (e) {
      _errors[id] = 'Error al cargar clase ($id): $e';
    } finally {
      _loading.remove(id);
      notifyListeners();
    }
  }

  /// Forzar recarga por si necesitas refrescar.
  Future<void> refreshClase(int id) async {
    _loading.add(id);
    _errors.remove(id);
    notifyListeners();

    try {
      final clase = await _service.fetchClaseById(id);
      _cache[id] = clase;
    } catch (e) {
      _errors[id] = 'Error al cargar clase ($id): $e';
    } finally {
      _loading.remove(id);
      notifyListeners();
    }
  }
}
