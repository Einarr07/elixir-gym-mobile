import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/models/clase.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/trainer/schedule_provider.dart';

class ScheduleCreationScreen extends StatefulWidget {
  const ScheduleCreationScreen({super.key});

  @override
  State<ScheduleCreationScreen> createState() => _ScheduleCreationScreenState();
}

class _ScheduleCreationScreenState extends State<ScheduleCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Datos del formulario
  Clase? _selectedClase;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Estado de carga
  bool _isClassesLoading = true;
  String? _classesError;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Cargamos las clases disponibles para el dropdown
    Future.microtask(_loadClases);
  }

  Future<void> _loadClases() async {
    // Asumimos que TrainerClassProvider existe según tu estructura de archivos
    final provider = Provider.of<TrainerScheduleProvider>(
      context,
      listen: false,
    );
    setState(() {
      _isClassesLoading = true;
      _classesError = null;
    });
    try {
      // FIX: Llamamos al método correcto (que añadiremos al provider)
      await provider.loadClases();
      if (provider.error != null) {
        throw Exception(provider.error);
      }
    } catch (e) {
      setState(() {
        _classesError = "Error al cargar clases: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isClassesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // --- Selectores de Fecha y Hora ---

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        // Estilo del DatePicker para que coincida con la app
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.card,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStartTime ? _startTime : _endTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        // Estilo del TimePicker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.card,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _endTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  // --- Lógica de Envío ---

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación de hora
    if (_startTime == null || _endTime == null) return;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora de fin debe ser posterior a la hora de inicio.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scheduleProvider = Provider.of<TrainerScheduleProvider>(
        context,
        listen: false,
      );

      final instructorId =
          authProvider.usuario?.idUsuario; // FIX: De 'user' a 'usuario'
      if (instructorId == null) {
        throw Exception('No se pudo identificar al instructor.');
      }

      // Combinar fecha y horas
      final fecha = _selectedDate!;
      final horaInicio = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final horaFin = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Llamamos al provider para crear el horario
      // (La firma de `crearHorario` puede necesitar ajuste)
      await scheduleProvider.crearHorario(
        claseId: _selectedClase!.idClase!,
        instructorId: instructorId,
        fecha: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );

      if (scheduleProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario creado con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
        // Regresamos a la pantalla anterior con 'true'
        Navigator.pop(context, true);
      } else {
        throw Exception(scheduleProvider.error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el horario: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  // --- Construcción de UI ---

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para el AuthProvider y 'Consumer' para TrainerClassProvider
    final authProvider = context.watch<AuthProvider>();
    final instructorName =
        authProvider.usuario?.nombre ??
        'Entrenador'; // FIX: De 'user' a 'usuario'

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nuevo Horario',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.card, // Fondo de la AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child:
              // Contenedor que simula el diálogo de la imagen
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ), // Ancho máximo
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLabel('Clase'),
                      _buildClaseDropdown(),
                      const SizedBox(height: 16),
                      _buildLabel('Fecha'),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Hora Inicio'),
                                _buildTimePicker(isStartTime: true),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Hora Fin'),
                                _buildTimePicker(isStartTime: false),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Instructor asignado'),
                      _buildReadOnlyField('$instructorName (Usuario actual)'),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildClaseDropdown() {
    return Consumer<TrainerScheduleProvider>(
      builder: (context, provider, child) {
        if (_isClassesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_classesError != null || provider.clases.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: _inputBoxDecoration(),
            child: Text(
              _classesError ?? 'No hay clases disponibles.',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        return DropdownButtonFormField<Clase>(
          value: _selectedClase,
          hint: const Text(
            'Selecciona una clase',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          dropdownColor: AppColors.card,
          // Color del menú desplegable
          decoration: _inputDecoration(hintText: ''),
          style: const TextStyle(color: AppColors.textPrimary),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
          items: provider.clases.map((Clase clase) {
            return DropdownMenuItem<Clase>(
              value: clase,
              child: Text(clase.nombre),
            );
          }).toList(),
          onChanged: (Clase? newValue) {
            setState(() {
              _selectedClase = newValue;
            });
          },
          validator: (value) => value == null ? 'Selecciona una clase' : null,
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: _inputDecoration(
        hintText: 'dd/mm/aaaa',
        icon: Icons.calendar_today,
        onIconPressed: _selectDate,
      ),
      onTap: _selectDate,
      validator: (value) =>
          value == null || value.isEmpty ? 'Selecciona una fecha' : null,
    );
  }

  Widget _buildTimePicker({required bool isStartTime}) {
    return TextFormField(
      controller: isStartTime ? _startTimeController : _endTimeController,
      readOnly: true,
      decoration: _inputDecoration(
        hintText: '--:--',
        icon: Icons.access_time,
        onIconPressed: () => _selectTime(isStartTime),
      ),
      onTap: () => _selectTime(isStartTime),
      validator: (value) =>
          value == null || value.isEmpty ? 'Selecciona una hora' : null,
    );
  }

  Widget _buildReadOnlyField(String text) {
    return TextFormField(
      initialValue: text,
      readOnly: true,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: _inputDecoration(hintText: '').copyWith(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 0,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: _isCreating
            ? const SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                'Crear Horario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // --- Decoraciones reutilizables ---

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: AppColors.background, // Un poco más oscuro
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? icon,
    VoidCallback? onIconPressed,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      // Color de fondo de los inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
      suffixIcon: icon != null
          ? IconButton(
              icon: Icon(icon, color: AppColors.textSecondary),
              onPressed: onIconPressed,
            )
          : null,
    );
  }
}
