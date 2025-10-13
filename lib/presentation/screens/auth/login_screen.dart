import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../client/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _passwrod = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _passwrod.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await context.read<AuthProvider>().login(
      _email.text.trim(),
      _passwrod.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      final msg = context.read<AuthProvider>().error ?? 'Error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Iniciar sesión'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Correo electrónico',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(v);
                    return ok ? null : 'Correo inválido';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwrod,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                ),
                const SizedBox(height: 12),
                //Align(
                //  alignment: Alignment.centerRight,
                //  child: TextButton(onPressed: (),
                //   child: const Text('¿Olvidaste tu contraseña?',
                //     style: TextStyle(color: AppColors.primary)),
                // ),
                // ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? CircularProgressIndicator()
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
