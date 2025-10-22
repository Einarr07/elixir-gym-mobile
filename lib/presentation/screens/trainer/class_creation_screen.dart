import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:flutter/material.dart';

class ClassCreationScreen extends StatefulWidget {
  const ClassCreationScreen({super.key});

  @override
  State<ClassCreationScreen> createState() => _ClassCreationScreenState();
}

class _ClassCreationScreenState extends State<ClassCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  final _capacidadController = TextEditingController();

  String? _dificultadSeleccionada;
  bool _isLoading = false;

  final ClaseService _service = ClaseService();

  Future<void> _crearClase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _service.createClase(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        dificultad: _dificultadSeleccionada ?? 'PRINCIPIANTE',
        duracion: int.parse(_duracionController.text.trim()),
        capacidadMax: int.parse(_capacidadController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clase creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la clase: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nueva Clase',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // 👇 Aquí el cuerpo principal scrollable
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre de la clase',
                  validatorMsg: 'El nombre es obligatorio',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  maxLines: 3,
                  validatorMsg: 'La descripción es obligatoria',
                ),
                const SizedBox(height: 16),
                _buildDificultadSelector(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _duracionController,
                  label: 'Duración (minutos)',
                  keyboardType: TextInputType.number,
                  validatorMsg: 'Ingresa una duración válida',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _capacidadController,
                  label: 'Capacidad máxima',
                  keyboardType: TextInputType.number,
                  validatorMsg: 'Ingresa una capacidad válida',
                ),
                const SizedBox(height: 100), // espacio para no tapar campos
              ],
            ),
          ),
        ),
      ),

      // 👇 Aquí el botón fijo abajo
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : _crearClase,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
                    'Crear Clase',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMsg,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        if (keyboardType == TextInputType.number &&
            int.tryParse(value.trim()) == null) {
          return 'Debe ser un número válido';
        }
        return null;
      },
    );
  }

  Widget _buildDificultadSelector() {
    final dificultades = ['PRINCIPIANTE', 'INTERMEDIO', 'AVANZADO'];
    final colores = [Colors.green, Colors.orange, Colors.redAccent];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nivel de dificultad',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dificultades.length, (i) {
            final dif = dificultades[i];
            final color = colores[i];
            final isSelected = _dificultadSeleccionada == dif;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _dificultadSeleccionada = dif);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.8)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dif,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.black
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        if (_dificultadSeleccionada == null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Selecciona un nivel de dificultad',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
