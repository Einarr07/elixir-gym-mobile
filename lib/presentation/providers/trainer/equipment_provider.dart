import 'package:elixir_gym/data/models/equipment.dart';
import 'package:elixir_gym/data/services/equipment_service.dart';
import 'package:flutter/material.dart';

class TrainerEquipmentProvider with ChangeNotifier {
  final EquipmentService _service;

  TrainerEquipmentProvider(this._service);

  bool _isLoading = false;
  String? _error;
  List<Equipment> _all = const [];

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<Equipment> get items => _all;

  Future<void> loadAll({bool force = false}) async {
    if (_all.isNotEmpty && !force) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _service.fetchAll();
    } catch (e) {
      _error = '$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadAll(force: true);

  Future<void> updateEquipment({
    required int idEquipo,
    required String nombre,
    required String tipo,
    required String estado,
  }) async {
    await _service.update(
      idEquipo: idEquipo,
      nombre: nombre,
      tipo: tipo,
      estado: estado,
    );
    // Trae el equipo actualizado y refléjalo en memoria
    final fresh = await _service.fetchById(idEquipo);
    final i = _all.indexWhere((e) => e.idEquipo == idEquipo);
    if (i >= 0) {
      _all = List<Equipment>.from(_all)..[i] = fresh;
      notifyListeners();
    } else {
      // por si no estaba
      _all = List<Equipment>.from(_all)..add(fresh);
      notifyListeners();
    }
  }
}
