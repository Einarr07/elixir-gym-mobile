import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/schedule.dart';
import '../../providers/trainer/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TrainerScheduleProvider>(
        context,
        listen: false,
      ).loadHorarios(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainerScheduleProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Clases',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final creada = await Navigator.pushNamed(context, '/crear-clase');
          if (creada == true && context.mounted) {
            Provider.of<TrainerScheduleProvider>(
              context,
              listen: false,
            ).loadHorarios();
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBody(TrainerScheduleProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    // 1. Obtenemos el MAPA AGRUPADO del provider
    final groupedData = provider.groupedHorarios;

    if (groupedData.isEmpty) {
      return const Center(
        child: Text(
          'No hay clases registradas aún.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // 2. Obtenemos las "llaves" (las fechas, ej: "Domingo 20 septiembre")
    final dateKeys = groupedData.keys.toList();

    // 3. Construimos la lista de secciones
    return ListView.builder(
      // Padding horizontal para todas las tarjetas
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        // Obtenemos el header de la fecha y la lista de clases para esa fecha
        final String dateHeader = dateKeys[index];
        final List<Schedule> classesForThisDate = groupedData[dateHeader]!;

        // 4. Retornamos una Columna para cada sección de fecha
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5. El TÍTULO DE LA FECHA (Header)
            Padding(
              padding: EdgeInsets.only(
                top: (index == 0) ? 16.0 : 32.0, // Espacio antes del header
                bottom: 12.0,
              ),
              child: Text(
                dateHeader,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 6. Mapeamos la lista de horarios a nuestra _ClaseCard
            //    Usamos un Column porque ListView anidado es problemático
            ...classesForThisDate.map((horario) {
              return _ClaseCard(clase: horario.clase);
            }).toList(),
          ],
        );
      },
    );
  }
}

class _ClaseCard extends StatelessWidget {
  final Clase clase;

  const _ClaseCard({required this.clase});

  Color _getDificultadColor(String? dificultad) {
    if (dificultad == null) return AppColors.primary;

    switch (dificultad.toUpperCase()) {
      case 'PRINCIPIANTE':
      case 'BÁSICO':
        return Colors.green;
      case 'INTERMEDIO':
        return Colors.orange;
      case 'AVANZADO':
        return Colors.redAccent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDificultadColor(clase.dificultad);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.9),
          radius: 22,
          child: const Icon(Icons.fitness_center, color: Colors.black),
        ),
        title: Text(
          clase.nombre,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Duración: ${clase.duracion} min'
          '${clase.dificultad != null ? ' • ${clase.dificultad}' : ''}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 18,
        ),
        onTap: () async {
          final actualizado = await Navigator.pushNamed(
            context,
            '/editar-clase',
            arguments: clase.idClase,
          );
          if (actualizado == true && context.mounted) {
            Provider.of<TrainerScheduleProvider>(
              context,
              listen: false,
            ).loadHorarios();
          }
        },
      ),
    );
  }
}
