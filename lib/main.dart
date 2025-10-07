import 'package:elixir_gym/core/theme/app_colors.dart';
import 'package:elixir_gym/presentation/providers/client/class_provider.dart';
import 'package:elixir_gym/presentation/providers/client/schedule_provider.dart';
import 'package:elixir_gym/presentation/providers/client/user_provider.dart';
import 'package:elixir_gym/presentation/screens/client/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Carga el archivo .env
  await dotenv.load(fileName: '.env');

  // 2️⃣ Inicializa la localización para fechas en español
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES'; // (opcional, pero recomendado)

  runApp(
    MultiProvider(
      providers: [
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
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(primary: AppColors.primary),
      ),
      home: const HomeScreen(),
    );
  }
}
