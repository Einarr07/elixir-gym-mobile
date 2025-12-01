import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/models/schedule.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:elixir_gym/data/services/reservation_service.dart';
import 'package:elixir_gym/presentation/providers/client/class_provider.dart';
import 'package:elixir_gym/presentation/providers/client/reservation_provider.dart';
import 'package:elixir_gym/presentation/providers/client/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassDetailScreen extends StatefulWidget {
  final Schedule horario;

  const ClassDetailScreen({super.key, required this.horario});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final _claseService = ClaseService();
  final _reservaService = ReservaService();

  Clase? _claseFull;
  bool _loadingClase = false;
  bool _booking = false; // <- estado del botón

  @override
  void initState() {
    super.initState();
    final idClase = widget.horario.clase.idClase;
    Future.microtask(() => context.read<ClaseProvider>().fetchClase(idClase));
    _loadClase();
  }

  Future<void> _loadClase() async {
    setState(() => _loadingClase = true);
    try {
      final c = await _claseService.fetchClaseById(
        widget.horario.clase.idClase,
      );
      if (mounted) setState(() => _claseFull = c);
    } catch (_) {
      // podrías mostrar un SnackBar si quieres
    } finally {
      if (mounted) setState(() => _loadingClase = false);
    }
  }

  Future<void> _onReservarCupo() async {
    final user = context.read<UserProvider>().usuario;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para reservar')),
      );
      return;
    }

    setState(() => _booking = true);
    try {
      // 1. Crear la reserva para este usuario y este horario
      await _reservaService.crearReserva(
        idUsuario: user.idUsuario,
        horario: widget.horario,
      );

      // 2. Refrescar "Mis Reservas" para que se vea automáticamente
      if (mounted) {
        await context.read<ReservationProvider>().load(user.idUsuario);
      }

      // 3. Feedback al usuario
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('¡Reserva creada con éxito!'),
        ),
      );

      // 4. (Opcional) volver a la lista de clases
      // Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('No se pudo reservar: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final claseBase = widget.horario.clase;
    final clase = _claseFull ?? claseBase;

    final dificultad = clase.dificultad ?? 'No especificada';
    final capacidad = clase.capacidadMax?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detalle de la Clase',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              clase.nombre,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              clase.descripcion,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            _row(icon: Icons.flag, label: 'Dificultad', value: dificultad),
            _row(
              icon: Icons.timer,
              label: 'Duración',
              value: '${clase.duracion} minutos',
            ),
            _row(
              icon: Icons.groups,
              label: 'Capacidad Máxima',
              value: '$capacidad personas',
            ),

            if (_loadingClase)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(),
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _booking ? null : _onReservarCupo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _booking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Reservar Cupo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
