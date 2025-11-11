import 'package:elixir_gym/data/models/clase.dart'; // <-- Importa Clase
import 'package:elixir_gym/data/services/clase_service.dart'; // <-- IMPORTANTE: Importa ClaseService
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/schedule.dart';
import '../../../data/services/schedule_service.dart';

class TrainerScheduleProvider extends ChangeNotifier {
  // 1. NECESITAMOS AMBOS SERVICIOS
  final ScheduleService _horarioService = ScheduleService();
  final ClaseService _claseService = ClaseService(); // <-- NUEVO

  // 2. NECESITAMOS AMBAS LISTAS "CRUDAS"
  List<Schedule> _horarios = []; // Lista de horarios (con clase parcial)
  List<Clase> _clases = []; // Lista de clases (con dificultad)

  bool isLoading = false;
  String? error;

  // 3. GETTER INTERNO PARA COMBINAR LAS LISTAS
  List<Schedule> get _combinedHorarios {
    // Creamos un "mapa" para buscar Clases por ID rápidamente
    final Map<int, Clase> claseMap = {for (var c in _clases) c.idClase: c};

    List<Schedule> combinedList = [];
    for (var hor in _horarios) {
      // Buscamos la clase completa usando el ID de la clase parcial
      final Clase? fullClase = claseMap[hor.clase.idClase];

      if (fullClase != null) {
        // Si la encontramos, creamos un NUEVO Schedule
        // pero reemplazamos la clase parcial por la clase completa
        combinedList.add(
          Schedule(
            idHorario: hor.idHorario,
            fecha: hor.fecha,
            horaInicio: hor.horaInicio,
            horaFin: hor.horaFin,
            clase: fullClase,
            // <-- ¡LA MAGIA ESTÁ AQUÍ!
            entrenador: hor.entrenador,
            // Asegúrate de que el constructor de Schedule coincida
          ),
        );
      } else {
        // Si no se encuentra (raro), solo añadimos el original
        combinedList.add(hor);
      }
    }
    return combinedList;
  }

  // 4. GETTER DE ORDENAMIENTO (Ahora usa la lista combinada)
  List<Schedule> get sortedHorarios {
    // Usamos la lista combinada que ya tiene la dificultad correcta
    List<Schedule> sortedList = List.from(_combinedHorarios);

    int getLevelPriority(String? dificultad) {
      if (dificultad == null) return 4;
      switch (dificultad.toLowerCase()) {
        case 'principiante':
          return 1;
        case 'intermedio':
          return 2;
        case 'avanzado':
          return 3;
        default:
          return 4;
      }
    }

    sortedList.sort((a, b) {
      int dateComparison = a.fecha.compareTo(b.fecha); // Ascendente
      if (dateComparison != 0) return dateComparison;

      // ¡Ahora 'a.clase.dificultad' tiene el valor correcto!
      int levelA = getLevelPriority(a.clase.dificultad);
      int levelB = getLevelPriority(b.clase.dificultad);
      return levelA.compareTo(levelB);
    });

    return sortedList;
  }

  // 5. GETTER DE AGRUPACIÓN (No cambia, pero ahora recibe datos correctos)
  Map<String, List<Schedule>> get groupedHorarios {
    Map<String, List<Schedule>> grouped = {};
    final formatter = DateFormat('EEEE d MMMM', 'es_ES');

    // 'sortedHorarios' ahora tiene las clases completas
    for (var Schedule in sortedHorarios) {
      String dateHeader = formatter.format(Schedule.fecha);
      dateHeader = "${dateHeader[0].toUpperCase()}${dateHeader.substring(1)}";
      if (!grouped.containsKey(dateHeader)) {
        grouped[dateHeader] = [];
      }
      grouped[dateHeader]!.add(Schedule);
    }
    return grouped;
  }

  // 6. FUNCIÓN DE CARGA ACTUALIZADA
  Future<void> loadHorarios() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Cargamos AMBAS listas al mismo tiempo
      final futureHorarios = _horarioService.fetchAll();
      final futureClases = _claseService.fetchAllClasses(); // <-- NUEVO

      // Esperamos a que las dos terminen
      final results = await Future.wait([futureHorarios, futureClases]);

      // Asignamos los resultados
      _horarios = results[0] as List<Schedule>;
      _clases = results[1] as List<Clase>;
    } catch (e) {
      error = 'Error al cargar los datos: $e';
    }
    isLoading = false;
    notifyListeners();
  }
}
