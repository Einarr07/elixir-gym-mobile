// lib/presentation/screens/auth/login_screen.dart
import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:elixir_gym/presentation/providers/client/user_provider.dart';
import 'package:elixir_gym/presentation/shells/role_based_home.dart'; // <--- usa home neutral
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // UX: cierra el teclado
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final userProv = context.read<UserProvider>();

    try {
      // 1. Login con AuthProvider (esto ya setea auth.usuario y auth.role)
      await auth.login(email: _email.text.trim(), password: _password.text);

      if (!mounted) return;

      // 2. Obtener el usuario logueado desde AuthProvider
      final usuarioLogueado = auth.usuario;

      // 3. Guardarlo en UserProvider para que pantallas de cliente lo lean
      if (usuarioLogueado != null) {
        userProv.setUsuario(usuarioLogueado);
      }

      // 4. Navegar al shell que decide por rol (admin/entrenador/cliente)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RoleBasedHome()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('Credenciales inválidas')
          ? 'Credenciales inválidas'
          : 'No se pudo iniciar sesión. Revisa tu conexión o intenta de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'tu@correo.com',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(v);
                    return ok ? null : 'Correo inválido';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
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
