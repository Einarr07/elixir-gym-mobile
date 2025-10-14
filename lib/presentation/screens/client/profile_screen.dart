import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/data/services/user_service.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:elixir_gym/presentation/providers/client/user_provider.dart';
import 'package:elixir_gym/presentation/screens/auth/login_screen.dart';
import 'package:elixir_gym/presentation/screens/client/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final int usuarioId;

  const ProfileScreen({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<ProfileScreen> {
  late Future<Usuario> futureUsuario;

  @override
  void initState() {
    super.initState();
    futureUsuario = UserService().fetchUsuario(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Perfil de usuario',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            onPressed: () async {
              final userProv = context.read<UserProvider>();
              final current = userProv.usuario;
              if (current == null) return;
              final updated = await Navigator.push<Usuario?>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(usuario: current),
                ),
              );

              if (updated != null && context.mounted) {
                userProv.setUsuario(updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Seguro que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await context.read<AuthProvider>().logout();
                context.read<UserProvider>().clear();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: userProvider.usuario == null
          ? FutureBuilder<Usuario>(
              future: futureUsuario,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final usuario = snapshot.data!;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    userProvider.setUsuario(usuario);
                  });

                  return _buildProfileContent(usuario);
                } else {
                  return const Center(child: Text('Usuario no encontrado'));
                }
              },
            )
          : _buildProfileContent(userProvider.usuario!),
    );
  }
}

Widget _buildProfileContent(Usuario usuario) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${usuario.nombre} ${usuario.apellido}',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Correo: ${usuario.correo}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Telefono: ${usuario.telefono}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),

        // Information Section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Información personal',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),

        _infoTile('Peso', '${usuario.peso} kg'),
        _infoTile('Altura', '${usuario.altura} m'),
        _infoTile('Fecha Nacimiento', '${usuario.fechaNacimiento}'),
        _infoTile('Estado', '${usuario.estado}'),
        _infoTile('Roles', '${usuario.roles.map((r) => r.rol).join(', ')}'),
      ],
    ),
  );
}

Widget _infoTile(String title, String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    ),
  );
}
