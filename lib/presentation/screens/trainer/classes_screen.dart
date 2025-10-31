import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/presentation/providers/trainer/class_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TrainerClaseProvider>(
        context,
        listen: false,
      ).loadClases(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainerClaseProvider>(context);

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
            Provider.of<TrainerClaseProvider>(
              context,
              listen: false,
            ).loadClases();
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBody(TrainerClaseProvider provider) {
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

    if (provider.clases.isEmpty) {
      return const Center(
        child: Text(
          'No hay clases registradas aún.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.clases.length,
      itemBuilder: (context, index) {
        final clase = provider.clases[index];
        return _ClaseCard(clase: clase);
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
            Provider.of<TrainerClaseProvider>(
              context,
              listen: false,
            ).loadClases();
          }
        },
      ),
    );
  }
}
