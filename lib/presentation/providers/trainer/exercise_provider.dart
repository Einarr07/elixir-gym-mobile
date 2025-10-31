// lib/presentation/providers/trainer/exercise_provider.dart
import 'package:elixir_gym/data/models/equipment.dart';
import 'package:elixir_gym/data/models/exercise.dart';
import 'package:elixir_gym/data/models/muscle_group.dart';
import 'package:elixir_gym/data/services/equipment_service.dart';
import 'package:elixir_gym/data/services/exercise_service.dart';
import 'package:elixir_gym/data/services/muscle_group_service.dart';
import 'package:flutter/material.dart';

class TrainerExerciseProvider with ChangeNotifier {
  final ExerciseService _exerciseService;
  final MuscleGroupService _muscleGroupService;
  final EquipmentService _equipmentService;

  TrainerExerciseProvider(
    this._exerciseService,
    this._muscleGroupService,
    this._equipmentService,
  );

  bool _isLoading = false;
  String _query = '';
  int? _selectedMuscleGroupId;
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = <Exercise>[];
  List<MuscleGroup> _allMuscleGroups = [];
  List<Equipment> _allEquipments = [];

  bool get isLoading => _isLoading;

  List<Exercise> get exercises => _filteredExercises;

  String get query => _query;

  int? get selectedMuscleGroupId => _selectedMuscleGroupId;

  List<MuscleGroup> get muscleGroupsForForm => _allMuscleGroups;

  List<Equipment> get equipmentsForForm => _allEquipments;

  Map<int, String> get gruposMusculares {
    return {
      for (var group in _allMuscleGroups) group.idGrupoMuscular!: group.nombre!,
    };
  }

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _exerciseService.fetchAll(),
        _muscleGroupService.fetchAll(),
      ]);
      _allExercises = results[0] as List<Exercise>;
      _allMuscleGroups = results[1] as List<MuscleGroup>;
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga los datos necesarios para la pantalla de creación (equipos).
  /// Los grupos musculares ya se cargan en `loadExercises`.
  Future<void> loadFormData() async {
    // Si ya tenemos los equipos, no los volvemos a cargar
    if (_allEquipments.isNotEmpty) return;

    try {
      _allEquipments = await _equipmentService.fetchAll();
      notifyListeners();
    } catch (e) {
      // Si la UI necesita saber del error, lo relanzamos
      debugPrint('Error cargando datos de equipos: $e');
      rethrow;
    }
  }

  Future<void> createExercise(Exercise newExercise) async {
    try {
      // 1. Convierte el objeto Exercise en el Map que la API necesita.
      final Map<String, dynamic> dataParaLaApi = newExercise.toJson();

      // 2. Envía ESE ÚNICO MAP a tu servicio.
      await _exerciseService.create(
        nombre: newExercise.nombre,
        idGrupoMuscular: newExercise.idGrupoMuscular!,
        idsEquipos: newExercise.equiposIds ?? [],
        descripcion: newExercise.descripcion,
        video: newExercise.video,
        imagen: newExercise.imagen,
        equipoNecesario: newExercise.equipoNecesario,
      );

      // Recarga la lista de ejercicios para incluir el nuevo.
      await loadExercises();
    } catch (e) {
      debugPrint('Error al crear el ejercicio: $e');
      rethrow;
    }
  }

  Future<void> updateExercise({
    required int idEjercicio,
    required String nombre,
    required String equipoNecesario, // ← requerido
    String? descripcion,
    String? video,
    String? imagen,
    required int idGrupoMuscular,
    List<int> idsEquipos = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _exerciseService.update(
        idEjercicio: idEjercicio,
        nombre: nombre,
        descripcion: descripcion,
        video: video,
        imagen: imagen,
        equipoNecesario: equipoNecesario,
        // ← enviar siempre
        idGrupoMuscular: idGrupoMuscular,
        idsEquipos: idsEquipos,
      );

      // refrescar el item
      final fresh = await _exerciseService.fetchById(idEjercicio);
      final idx = _allExercises.indexWhere((e) => e.idEjercicio == idEjercicio);
      if (idx != -1) _allExercises[idx] = fresh;
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExercise(int id) async {
    final i = _allExercises.indexWhere((e) => e.idEjercicio == id);
    Exercise? backup;
    if (i != -1) {
      backup = _allExercises.removeAt(i);
      _applyFilters();
      notifyListeners();
    }
    try {
      await _exerciseService.delete(id);
    } catch (e) {
      if (backup != null) {
        _allExercises.insert(i, backup);
        _applyFilters();
        notifyListeners();
      }
      rethrow;
    }
  }

  void setQuery(String value) {
    _query = value;
    _applyFilters(notify: true);
  }

  void selectMuscleGroup(int? id) {
    _selectedMuscleGroupId = id;
    _applyFilters(notify: true);
  }

  void _applyFilters({bool notify = false}) {
    Iterable<Exercise> data = _allExercises;

    // Filtro por grupo muscular (null-safe)
    final sel = _selectedMuscleGroupId;
    if (sel != null) {
      data = data.where((e) => e.grupoMuscular?.idGrupoMuscular == sel);
    }

    // Filtro por texto (null-safe)
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      data = data.where((e) {
        final name = (e.nombre ?? '').toLowerCase();
        final desc = (e.descripcion ?? '').toLowerCase();
        return name.contains(q) || desc.contains(q);
      });
    }

    _filteredExercises = List<Exercise>.unmodifiable(
      data.toList(growable: false),
    );
    if (notify) notifyListeners();
  }
}
