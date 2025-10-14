import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/reservation_service.dart';
import '../../providers/client/user_provider.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  bool isLoading = true;
  List<dynamic> reservas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => cargarReservas());
  }

  Future<void> cargarReservas() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.usuario;

    if (usuario == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await _reservaService.obtenerReservas(usuario.idUsuario);
      setState(() {
        reservas = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar reservas: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : reservas.isEmpty
          ? const Center(
              child: Text(
                'No tienes reservas registradas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : RefreshIndicator(
              onRefresh: cargarReservas,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                itemCount: reservas.length,
                itemBuilder: (context, i) {
                  final reserva = reservas[i];
                  final horario = reserva["horario"];
                  final clase = horario?["clase"];
                  final entrenador = horario?["entrenador"];

                  final nombreClase = clase?["nombre"] ?? "Clase";
                  final nombreEntrenador =
                      entrenador?["nombre"] ?? "Entrenador";
                  final fecha = DateFormat(
                    "EEEE d MMMM",
                    "es_ES",
                  ).format(DateTime.parse(horario["fecha"]));
                  final horaInicio = horario["hora_inicio"];
                  final horaFin = horario["hora_fin"];
                  final estado = reserva["estado"];

                  return _ReservaCard(
                    nombreClase: nombreClase,
                    nombreEntrenador: nombreEntrenador,
                    fecha: fecha,
                    horaInicio: horaInicio,
                    horaFin: horaFin,
                    estado: estado,
                  );
                },
              ),
            ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final String nombreClase;
  final String nombreEntrenador;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;

  const _ReservaCard({
    required this.nombreClase,
    required this.nombreEntrenador,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case "confirmada":
        return Colors.greenAccent.shade400;
      case "pendiente":
        return Colors.orangeAccent.shade200;
      case "cancelada":
        return Colors.redAccent.shade200;
      case "completa":
        return Colors.blueAccent.shade200;
      case "expirada":
        return Colors.grey.shade500;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          nombreClase,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Con $nombreEntrenador',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$fecha\n$horaInicio - $horaFin',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _estadoColor(estado).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _estadoColor(estado), width: 1),
          ),
          child: Text(
            estado.toUpperCase(),
            style: TextStyle(
              color: _estadoColor(estado),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
