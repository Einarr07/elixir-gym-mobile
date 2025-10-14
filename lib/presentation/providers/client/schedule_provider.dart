import 'package:flutter/cupertino.dart';

import '../../../data/models/schedule.dart';
import '../../../data/services/schedule_service.dart';

class HorariosProvider extends ChangeNotifier {
  final _service = HorarioService();

  bool isLoading = false;
  List<Horario> horarios = [];
  Horario? _horarioSeleccionado;
  String? errorMessage;

  Horario? get horarioSeleccionado => _horarioSeleccionado;

  Future<void> fetchHorarios() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      horarios = await _service.fetchHorarios();
    } catch (e) {
      errorMessage = 'Error al cargar horarios: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  void seleccionarHorario(Horario horario) {
    _horarioSeleccionado = horario;
    notifyListeners();
  }
}
