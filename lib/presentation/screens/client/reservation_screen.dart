// lib/presentation/screens/client/reservation_screen.dart
import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/reservation_class.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:elixir_gym/presentation/providers/client/reservation_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservationScreen> {
  int? _userId;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    // Cargar después del primer frame para leer providers con context
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  void _ensureLoaded() {
    final auth = context.read<AuthProvider>();
    final u = auth.usuario;
    if (u == null) return;

    if (_userId != u.idUsuario || !_loadedOnce) {
      _userId = u.idUsuario;
      _loadedOnce = true;
      context.read<ReservationProvider>().load(_userId!);
    }
  }

  Future<void> _refresh() async {
    if (_userId != null) {
      await context.read<ReservationProvider>().load(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si el usuario aparece luego del bootstrap, intenta cargar
    final auth = context.watch<AuthProvider>();
    if (auth.usuario != null && auth.usuario!.idUsuario != _userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
    }

    final vm = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mis Reservas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
      ),
      body: vm.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : vm.items.isEmpty
          ? const Center(
              child: Text(
                'No tienes reservas registradas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                itemCount: vm.items.length,
                itemBuilder: (context, i) {
                  final ReservationClass r = vm.items[i];

                  // nombre clase / entrenador (según tu modelo)
                  final String claseNombre =
                      (r.nombreClase ?? '').trim().isEmpty
                      ? 'Clase'
                      : r.nombreClase!.trim();

                  final String entrenadorNombre =
                      (r.entrenador ?? '').trim().isEmpty
                      ? 'Sin entrenador'
                      : r.entrenador!.trim();

                  // fecha: preferimos r.fecha; si es null usamos reservacion (yyyy-MM-dd)
                  final DateTime? fecha =
                      r.fecha ??
                      (r.reservacion.isNotEmpty
                          ? DateTime.tryParse(r.reservacion)
                          : null);
                  final String fechaTxt = _formatFecha(fecha);

                  // horas
                  final String horaInicio = (r.horaInicio ?? '').isEmpty
                      ? '--:--'
                      : r.horaInicio!;
                  final String horaFin = (r.horaFin ?? '').isEmpty
                      ? '--:--'
                      : r.horaFin!;

                  return _ReservaCard(
                    idReserva: r.idReserva,
                    claseNombre: claseNombre,
                    entrenadorNombre: entrenadorNombre,
                    fechaTexto: (horaInicio != '--:--' && horaFin != '--:--')
                        ? '$fechaTxt\n$horaInicio - $horaFin'
                        : fechaTxt,
                    estado: r.estado.toLowerCase(),
                    onEditEstado: () => _editarEstado(context, r),
                    onTap: () {},
                  );
                },
              ),
            ),
    );
  }

  Future<void> _editarEstado(BuildContext context, ReservationClass r) async {
    const estados = <String>{
      'pendiente',
      'confirmada',
      'cancelada',
      'completa',
      'no asistio',
    };
    String sel = r.estado;

    final elegido = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3528),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cambiar estado',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ...estados.map(
                    (e) => RadioListTile<String>(
                      value: e,
                      groupValue: sel,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => sel = v!),
                      title: Text(
                        _displayEstado(e),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: Color(0xFF3A3528)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context, sel),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (elegido != null && elegido != r.estado) {
      final ok = await context.read<ReservationProvider>().actualizarEstado(
        reservationClass: r,
        estado: elegido,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? 'Estado actualizado a "${_displayEstado(elegido)}"'
                  : 'No se pudo actualizar el estado',
            ),
          ),
        );
        // Refresca lista si se actualizó bien
        if (ok && _userId != null) {
          context.read<ReservationProvider>().load(_userId!);
        }
      }
    }
  }

  String _formatFecha(DateTime? dt) {
    if (dt == null) return '--';
    final txt = DateFormat('EEEE d MMMM', 'es_ES').format(dt);
    return txt.isEmpty ? '--' : '${txt[0].toUpperCase()}${txt.substring(1)}';
  }

  String _displayEstado(String e) {
    switch (e) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      case 'completa':
        return 'Completada';
      case 'no asistio':
        return 'No asistió';
      case 'expirada':
        return 'Expirada';
      default:
        return e;
    }
  }
}

// ======================= Card UI =======================

class _ReservaCard extends StatelessWidget {
  final int idReserva;
  final String claseNombre;
  final String entrenadorNombre;
  final String fechaTexto;
  final String estado;
  final VoidCallback onEditEstado;
  final VoidCallback onTap;

  const _ReservaCard({
    required this.idReserva,
    required this.claseNombre,
    required this.entrenadorNombre,
    required this.fechaTexto,
    required this.estado,
    required this.onEditEstado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColors = _chipColors(estado);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              claseNombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Con $entrenadorNombre',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fechaTexto,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipColors.$1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: chipColors.$2, width: 1),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: chipColors.$2,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onEditEstado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    minimumSize: const Size(0, 0),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _chipColors(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return (const Color(0xFF0D2D14), const Color(0xFF6EE7B7));
      case 'pendiente':
        return (const Color(0xFF2D2A00), const Color(0xFFFFD400));
      case 'cancelada':
        return (const Color(0xFF2D0D0D), const Color(0xFFFCA5A5));
      case 'completa':
        return (const Color(0xFF0D1F2D), const Color(0xFF93C5FD));
      case 'expirada':
        return (const Color(0xFF1F1F1F), const Color(0xFFBEBEBE));
      default:
        return (const Color(0xFF1F1F1F), const Color(0xFFBEBEBE));
    }
  }
}
