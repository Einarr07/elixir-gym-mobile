import 'package:flutter/cupertino.dart';

import '../../../data/models/schedule.dart';
import '../../../data/services/schedule_service.dart';

class HorariosProvider extends ChangeNotifier {
  final _service = ScheduleService();

  bool isLoading = false;
  List<Schedule> horarios = [];
  Schedule? _horarioSeleccionado;
  String? errorMessage;

  Schedule? get horarioSeleccionado => _horarioSeleccionado;

  Future<void> fetchHorarios() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      horarios = await _service.fetchAll();
    } catch (e) {
      errorMessage = 'Error al cargar horarios: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  void seleccionarHorario(Schedule Schedule) {
    _horarioSeleccionado = Schedule;
    notifyListeners();
  }
}
