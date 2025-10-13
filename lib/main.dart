import 'package:elixir_gym/core/theme/app_theme.dart'; // 👈 usa tu theme central
import 'package:elixir_gym/data/services/auth_service.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:elixir_gym/presentation/providers/client/class_provider.dart';
import 'package:elixir_gym/presentation/providers/client/schedule_provider.dart';
import 'package:elixir_gym/presentation/providers/client/user_provider.dart';
import 'package:elixir_gym/presentation/screens/auth/login_screen.dart'; // 👈 pantalla de login
import 'package:elixir_gym/presentation/screens/client/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(AuthService())..bootstrap(), // 👈 carga sesión
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HorariosProvider()),
        ChangeNotifierProvider(create: (_) => ClaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ElixirGym',
      theme: appTheme(),
      home: const _AuthGate(),
    );
  }
}

/// Decide qué pantalla mostrar según el estado del AuthProvider.
/// - loading (bootstrap): spinner
/// - autenticado: HomeScreen
/// - no autenticado: LoginScreen
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
