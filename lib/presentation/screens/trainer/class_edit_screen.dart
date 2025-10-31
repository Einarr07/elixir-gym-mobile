import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/services/clase_service.dart';
import 'package:flutter/material.dart';

class ClassEditScreen extends StatefulWidget {
  final int idClase;

  const ClassEditScreen({super.key, required this.idClase});

  @override
  State<ClassEditScreen> createState() => _ClassEditScreenState();
}

class _ClassEditScreenState extends State<ClassEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClaseService();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  final _capacidadController = TextEditingController();
  String? _dificultadSeleccionada;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadClase();
  }

  Future<void> _loadClase() async {
    try {
      final clase = await _service.fetchClaseById(widget.idClase);
      _nombreController.text = clase.nombre;
      _descripcionController.text = clase.descripcion;
      _duracionController.text = clase.duracion.toString();
      _capacidadController.text = clase.capacidadMax?.toString() ?? '';
      _dificultadSeleccionada = clase.dificultad?.toUpperCase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar clase: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarClase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _service.updateClase(
        idClase: widget.idClase,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        dificultad: _dificultadSeleccionada ?? 'PRINCIPIANTE',
        duracion: int.parse(_duracionController.text.trim()),
        capacidadMax: int.parse(_capacidadController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clase actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la clase: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Eliminar clase',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta clase? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      _eliminarClase();
    }
  }

  Future<void> _eliminarClase() async {
    setState(() => _isSaving = true);

    try {
      await _service.deleteClase(widget.idClase);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clase eliminada correctamente'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true); // Volver al listado
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la clase: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Editar Clase',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            onPressed: _confirmarEliminacion,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
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
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
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
            onPressed: _isSaving ? null : _actualizarClase,
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text(
                    'Guardar Cambios',
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
          children: List.generate(dificultades.length, (i) {
            final dif = dificultades[i];
            final color = colores[i];
            final isSelected = _dificultadSeleccionada == dif;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _dificultadSeleccionada = dif),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    left: i == 0 ? 0 : 6,
                    right: i == dificultades.length - 1 ? 0 : 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.85)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
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
      ],
    );
  }
}
