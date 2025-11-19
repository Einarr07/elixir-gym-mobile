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

  // Getter público para que la UI acceda a las clases
  List<Clase> get clases => _clases;

  bool isLoading = false;
  String? error;

  // 3. GETTER INTERNO PARA COMBINAR LAS LISTAS
  List<Schedule> get _combinedHorarios {
    // Creamos un "mapa" para buscar Clases por ID rápidamente
    final Map<int, Clase> claseMap = {for (var c in _clases) c.idClase!: c};

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

  // +++ MÉTODO REQUERIDO POR ScheduleCreationScreen +++
  // Carga solo la lista de clases para el Dropdown
  Future<void> loadClases() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Solo cargamos las clases
      _clases = await _claseService.fetchAllClasses();
    } catch (e) {
      error = 'Error al cargar las clases: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  // +++ MÉTODO IMPLEMENTADO USANDO TU SERVICE +++
  Future<void> crearHorario({
    required int claseId,
    required int instructorId, // La pantalla envía un int (usuario.id)
    required DateTime fecha,
    required DateTime horaInicio, // La pantalla envía DateTime
    required DateTime horaFin, // La pantalla envía DateTime
  }) async {
    error = null;
    // 'isLoading' se maneja en la propia pantalla (_isCreating)
    // por lo que no lo activamos aquí para no afectar la lista de horarios.

    try {
      // Convertimos las horas de DateTime a String "HH:mm"
      // que es lo que espera tu ScheduleService
      final String horaInicioStr = DateFormat('HH:mm').format(horaInicio);
      final String horaFinStr = DateFormat('HH:mm').format(horaFin);

      // Llamamos al servicio con los tipos de datos correctos
      await _horarioService.create(
        fecha: fecha,
        // El servicio se encarga de formatear la fecha
        horaInicio: horaInicioStr,
        horaFin: horaFinStr,
        idClase: claseId,
        idUsuarioEntrenador: instructorId,
      );

      // Opcional: Si quieres que la lista de horarios se actualice
      // inmediatamente después de crear, descomenta la siguiente línea:
      // await loadHorarios();
    } catch (e) {
      error = 'Error al crear horario: $e';
    }
    // Notificamos solo en caso de error, ya que la pantalla
    // maneja el éxito (con Navigator.pop(true))
    if (error != null) {
      notifyListeners();
    }
  }

  // +++ MÉTODO REQUERIDO POR ScheduleEditScreen +++
  Future<void> actualizarHorario({
    required int idHorario, // <-- ID del horario
    required int claseId,
    required int instructorId,
    required DateTime fecha,
    required DateTime horaInicio,
    required DateTime horaFin,
  }) async {
    error = null;
    // La UI maneja su propio estado de 'isUpdating'

    try {
      // Convertimos las horas de DateTime a String "HH:mm"
      final String horaInicioStr = DateFormat('HH:mm').format(horaInicio);
      final String horaFinStr = DateFormat('HH:mm').format(horaFin);

      // Llamamos al servicio (que ya tienes)
      await _horarioService.update(
        idHorario: idHorario,
        // <-- Pasa el ID
        fecha: fecha,
        horaInicio: horaInicioStr,
        horaFin: horaFinStr,
        idClase: claseId,
        idUsuarioEntrenador: instructorId,
      );

      // Opcional: Si quieres que la lista de horarios se actualice
      // inmediatamente después de crear, descomenta la siguiente línea:
      // await loadHorarios();
    } catch (e) {
      error = 'Error al actualizar horario: $e';
    }
    // Notificamos solo en caso de error
    if (error != null) {
      notifyListeners();
    }
  }

  Future<void> eliminarHorario(int idHorario) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Asumiendo que tienes un repositorio o servicio
      await _horarioService.delete(idHorario);

      // Actualizar la lista localmente para reflejar el cambio
      _horarios.removeWhere((h) => h.idHorario == idHorario);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
