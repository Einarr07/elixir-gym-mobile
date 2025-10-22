// lib/presentation/shells/role_based_home.dart
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../utils/role_utils.dart';
import '../providers/auth/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import 'admin_shell.dart';
import 'client_shell.dart';
import 'trainer_shell.dart';

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const SizedBox.shrink(); // Splash opcional
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        switch (auth.role) {
          case UserRole.admin:
            return const AdminShell();
          case UserRole.entrenador:
            return const TrainerShell();
          case UserRole.cliente:
          case UserRole.desconocido:
          default:
            return const ClientShell();
        }
    }
  }
}
