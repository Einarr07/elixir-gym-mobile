import 'package:elixir_gym/core/theme/app_theme.dart';
import 'package:elixir_gym/data/services/auth_service.dart';
import 'package:elixir_gym/presentation/providers/auth/auth_provider.dart';
import 'package:elixir_gym/presentation/providers/client/class_provider.dart';
import 'package:elixir_gym/presentation/providers/client/schedule_provider.dart';
import 'package:elixir_gym/presentation/providers/client/user_provider.dart';
import 'package:elixir_gym/presentation/screens/auth/login_screen.dart';
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HorariosProvider()),
        ChangeNotifierProvider(create: (_) => ClaseProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
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

/// Gate que:
/// 1) Ejecuta bootstrap una vez al inicio
/// 2) Muestra spinner mientras carga
/// 3) Redirige a Home o Login según autenticación
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    // Ejecuta bootstrap una sola vez
    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      final userProv = context.read<UserProvider>();
      if (!_bootstrapped) {
        _bootstrapped = true;
        await auth.bootstrap(userProv);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
