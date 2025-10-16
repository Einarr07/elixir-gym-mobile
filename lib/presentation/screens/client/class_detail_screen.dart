import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/data/models/schedule.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:elixir_gym/presentation/providers/client/class_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/services/reservation_service.dart';
import '../../providers/client/user_provider.dart';

class ClassDetailScreen extends StatefulWidget {
  final Horario horario;

  const ClassDetailScreen({super.key, required this.horario});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final _claseService = ClaseService();
  Clase? _claseFull;
  bool _loadingClase = false;

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
      // puedes mostrar un SnackBar si lo prefieres
    } finally {
      if (mounted) setState(() => _loadingClase = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final claseBase = widget.horario.clase;
    final clase = _claseFull ?? claseBase;

    final dificultad = clase.dificultad ?? 'No especificada';
    final capacidad = clase.capacidadMax?.toString() ?? 'N/A';

    bool _booking = false;
    final _reservaService = ReservaService();

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
                onPressed: _booking
                    ? null
                    : () async {
                        final user = context.read<UserProvider>().usuario;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesión para reservar'),
                            ),
                          );
                          return;
                        }

                        setState(() => _booking = true);
                        try {
                          final reserva = await _reservaService.crearReserva(
                            idUsuario: user.idUsuario,
                            horario: widget.horario,
                          );

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Reserva creada con éxito!'),
                            ),
                          );

                          // opcional: navega a pantalla de "Mis Reservas" o vuelve atrás
                          // Navigator.pop(context, reserva);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No se pudo reservar: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _booking = false);
                        }
                      },
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
