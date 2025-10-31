// assign_exercise_screen.dart

import 'package:elixir_gym/data/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trainer/exercise_provider.dart';
import '../../providers/trainer/training_provider.dart';

class AssignExerciseScreen extends StatefulWidget {
  final int trainingId;

  const AssignExerciseScreen({super.key, required this.trainingId});

  @override
  State<AssignExerciseScreen> createState() => _AssignExerciseScreenState();
}

class _AssignExerciseScreenState extends State<AssignExerciseScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los ejercicios cuando la pantalla se inicie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainerExerciseProvider>(
        context,
        listen: false,
      ).loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Ejercicio')),
      body: Consumer<TrainerExerciseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.exercises.isEmpty) {
            return const Center(child: Text('No hay ejercicios para mostrar.'));
          }

          return ListView.builder(
            itemCount: provider.exercises.length,
            itemBuilder: (context, index) {
              final ejercicio = provider.exercises[index];
              return ListTile(
                title: Text(ejercicio.nombre),
                onTap: () {
                  // Al tocar, mostramos el diálogo para pedir los detalles
                  _showAssignDetailsDialog(context, ejercicio);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Método para mostrar el diálogo
  void _showAssignDetailsDialog(BuildContext context, Exercise exercise) {
    // Controladores para los campos de texto
    final seriesController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final restController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Añadir "${exercise.nombre}"'),
          content: SingleChildScrollView(
            // Para evitar overflow si el teclado aparece
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: seriesController,
                  decoration: const InputDecoration(labelText: 'Series'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso Sugerido (kg)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: restController,
                  decoration: const InputDecoration(
                    labelText: 'Descanso (segundos)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Validar y parsear los datos de los controladores
                final series = int.tryParse(seriesController.text) ?? 0;
                final repeticiones = int.tryParse(repsController.text) ?? 0;
                final pesoSugerido =
                    double.tryParse(weightController.text) ?? 0.0;
                final descansoSegundos = int.tryParse(restController.text) ?? 0;

                // 2. Usar el provider para llamar al servicio y crear la relación
                try {
                  final trainingProvider = Provider.of<TrainerTrainingProvider>(
                    context,
                    listen: false,
                  );
                  await trainingProvider.addExerciseToTraining(
                    idEntrenamiento: widget.trainingId,
                    idEjercicio: exercise.idEjercicio!,
                    series: series,
                    repeticiones: repeticiones,
                    pesoSugerido: pesoSugerido,
                    descansoSegundos: descansoSegundos,
                  );

                  // 3. Cerrar el diálogo y la pantalla de asignación, retornando 'true' para indicar éxito
                  if (mounted) {
                    Navigator.pop(dialogContext); // Cierra el dialogo
                    Navigator.pop(
                      context,
                      true,
                    ); // Cierra la pantalla de asignación
                  }
                } catch (e) {
                  // Mostrar un error si algo falla
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
