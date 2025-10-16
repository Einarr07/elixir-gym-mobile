// lib/presentation/providers/client/reservation_provider.dart
import 'package:elixir_gym/data/models/reservation.dart';
import 'package:elixir_gym/data/models/schedule.dart';
import 'package:elixir_gym/data/services/reservation_service.dart';
import 'package:elixir_gym/data/services/schedule_service.dart';
import 'package:flutter/material.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservaService _service;

  // Enriquecimiento desde horarios (con caché)
  final HorarioService _horarioService = HorarioService();
  final Map<int, Horario> _horarioCache = {};

  ReservationProvider({required ReservaService service}) : _service = service;

  bool _loading = false;
  String? _error;
  List<Reserva> _items = [];

  bool get loading => _loading;

  String? get error => _error;

  List<Reserva> get items => List.unmodifiable(_items);

  Future<void> load(int idUsuario) async {
    _setLoading(true);
    try {
      final reservas = await _service.obtenerReservas(idUsuario);

      // 1) pinta inmediatamente lo que devuelve el endpoint de reservas
      _items = reservas;
      _error = null;
      notifyListeners();

      // 2) completa datos faltantes sin bloquear la UI
      // ignore: unawaited_futures
      _enrichFromHorarios();
    } catch (e) {
      _error = e.toString();
      _items = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Reserva? getById(int idReserva) {
    final i = _items.indexWhere((r) => r.idReserva == idReserva);
    return i == -1 ? null : _items[i];
  }

  /// Actualiza estado enviando los campos obligatorios del propio objeto 'reserva'
  /// y luego fusiona con datos de Horario si todavía faltaran.
  Future<bool> actualizarEstado({
    required Reserva reserva,
    required String estado,
  }) async {
    try {
      final updated = await _service.actualizarEstadoReserva(
        reserva: reserva,
        estado: estado,
      );

      // Completa (si hace falta) con datos del horario
      final merged = await _mergeWithHorario(updated);

      final i = _items.indexWhere((r) => r.idReserva == reserva.idReserva);
      if (i != -1) {
        _items[i] = merged;
      } else {
        _items.insert(0, merged);
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void removeLocal(int idReserva) {
    _items.removeWhere((r) => r.idReserva == idReserva);
    notifyListeners();
  }

  // ----------------- internos -----------------

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  /// Enriquecer reservas con Horario: entrenador, nombreClase, fecha y horas
  Future<void> _enrichFromHorarios() async {
    try {
      final idsPendientes = _items
          .where(
            (r) =>
                r.idHorario != 0 &&
                (r.entrenador == null ||
                    r.nombreClase == null ||
                    r.fecha == null ||
                    r.horaInicio == null ||
                    r.horaFin == null),
          )
          .map((r) => r.idHorario)
          .where((id) => !_horarioCache.containsKey(id))
          .toSet()
          .toList();

      if (idsPendientes.isNotEmpty) {
        final fetched = await Future.wait(
          idsPendientes.map(_horarioService.obtenerHorarioPorId),
        );
        for (final h in fetched) {
          _horarioCache[h.idHorario] = h;
        }
      }

      _items = _items
          .map((r) => _mergeLocal(r, _horarioCache[r.idHorario]))
          .toList();
      notifyListeners();
    } catch (e) {
      // Si falla, la lista ya está visible; no rompemos nada.
      debugPrint('Enrich reservas error: $e');

      // Fallback: intenta bajar todos y reintentar fusión
      try {
        final todos = await _horarioService.fetchHorarios();
        for (final h in todos) {
          _horarioCache[h.idHorario] = h;
        }
        _items = _items
            .map((r) => _mergeLocal(r, _horarioCache[r.idHorario]))
            .toList();
        notifyListeners();
      } catch (ee) {
        debugPrint('Fallback fetchHorarios error: $ee');
      }
    }
  }

  /// Obtiene (y cachea) un horario por id; si falla, intenta fetchHorarios()
  Future<Horario?> _getHorarioFor(int idHorario) async {
    if (idHorario == 0) return null;

    final cached = _horarioCache[idHorario];
    if (cached != null) return cached;

    try {
      final h = await _horarioService.obtenerHorarioPorId(idHorario);
      _horarioCache[h.idHorario] = h;
      return h;
    } catch (e) {
      debugPrint('obtenerHorarioPorId($idHorario) falló: $e');
      try {
        final todos = await _horarioService.fetchHorarios();
        for (final h in todos) {
          _horarioCache[h.idHorario] = h;
        }
        return _horarioCache[idHorario];
      } catch (ee) {
        debugPrint('fetchHorarios fallback falló: $ee');
        return null;
      }
    }
  }

  /// Fusiona Reserva + Horario (solo rellena campos nulos)
  Reserva _mergeLocal(Reserva r, Horario? h) {
    if (h == null) return r;
    final entrenadorNombre = '${h.entrenador.nombre} ${h.entrenador.apellido}'
        .trim();
    return Reserva(
      idReserva: r.idReserva,
      idUsuario: r.idUsuario,
      idHorario: r.idHorario,
      reservacion: r.reservacion,
      estado: r.estado,
      nombreClase: r.nombreClase ?? h.clase.nombre,
      entrenador:
          r.entrenador ?? (entrenadorNombre.isEmpty ? null : entrenadorNombre),
      fecha: r.fecha ?? h.fecha,
      horaInicio: r.horaInicio ?? h.horaInicio,
      horaFin: r.horaFin ?? h.horaFin,
    );
  }

  /// Igual que arriba pero pudiendo esperar al fetch si es necesario
  Future<Reserva> _mergeWithHorario(Reserva r) async {
    final h = await _getHorarioFor(r.idHorario);
    return _mergeLocal(r, h);
  }
}
