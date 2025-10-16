import 'dart:convert';

import 'package:elixir_gym/core/storage/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Usuario usuario;

  const EditProfileScreen({super.key, required this.usuario});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _correo;
  late final TextEditingController _contrasenia; // opcional
  late final TextEditingController _telefono;
  late final TextEditingController _peso;
  late final TextEditingController _altura;
  late DateTime _fechaNac;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombre = TextEditingController(text: u.nombre);
    _apellido = TextEditingController(text: u.apellido);
    _correo = TextEditingController(text: u.correo);
    _contrasenia = TextEditingController();
    _telefono = TextEditingController(text: u.telefono);
    _peso = TextEditingController(text: u.peso.toStringAsFixed(1));
    _altura = TextEditingController(text: u.altura.toStringAsFixed(2));
    _fechaNac = DateTime.tryParse(u.fechaNacimiento) ?? DateTime(1990, 1, 1);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _correo.dispose();
    _contrasenia.dispose();
    _telefono.dispose();
    _peso.dispose();
    _altura.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fechaNac,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fechaNac = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final oldEmail = widget.usuario.correo;
    final newEmail = _correo.text.trim();
    final newPass = _contrasenia.text.trim();

    try {
      final updated = await UserService().updateUsuario(
        id: widget.usuario.idUsuario,
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        correo: _correo.text.trim(),
        contrasenia: _contrasenia.text.trim().isEmpty
            ? null
            : _contrasenia.text.trim(),
        telefono: _telefono.text.trim(),
        fechaNacimiento: DateFormat('yyyy-MM-dd').format(_fechaNac),
        peso: double.parse(_peso.text.replaceAll(',', '.')),
        altura: double.parse(_altura.text.replaceAll(',', '.')),
        estado: widget.usuario.estado,
      );
      final emailChanged = newEmail != oldEmail;
      final passChanged = newPass.isNotEmpty;

      if (emailChanged || passChanged) {
        String effectivePass = newPass;

        // Si solo cambió el correo y no se ingresó nueva contraseña, pedir la actual
        if (emailChanged && !passChanged) {
          final typed = await _askForPassword(context);
          if (typed == null || typed.isEmpty) {
            // sin contraseña no podemos reconstruir el header → opción: forzar logout o solo avisar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Se cambió el correo. Inicia sesión nuevamente para continuar.',
                ),
              ),
            );
            // Si prefieres forzar logout aquí, puedes:
            // await AuthStorage.instance.clear();
            // if (mounted) Navigator.pop(context, updated);
            // return;
          } else {
            effectivePass = typed;
          }
        }

        if (effectivePass.isNotEmpty) {
          final newBasic =
              'Basic ${base64Encode(utf8.encode('$newEmail:$effectivePass'))}';
          await AuthStorage.instance.saveAuthHeader(newBasic);
        }
      }
      if (!mounted) return;
      Navigator.pop(context, updated); // devolvemos el usuario actualizado
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombre,
                decoration: _dec('Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellido,
                decoration: _dec('Apellido'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correo,
                decoration: _dec('Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v != null && v.contains('@')) ? null : 'Correo inválido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contrasenia,
                decoration: _dec('Contraseña (opcional)'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                decoration: _dec('Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _dec('Fecha de nacimiento'),
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_fechaNac),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _peso,
                decoration: _dec('Peso (kg)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    (double.tryParse(v!.replaceAll(',', '.')) == null)
                    ? 'Número inválido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _altura,
                decoration: _dec('Altura (m)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    (double.tryParse(v!.replaceAll(',', '.')) == null)
                    ? 'Número inválido'
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _askForPassword(BuildContext context) async {
    final ctrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar contraseña'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña actual',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return result; // puede ser null si canceló
  }
}
