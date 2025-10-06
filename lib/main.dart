import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:elixir_gym/presentation/screens/usuario_screen.dart';
import 'package:elixir_gym/routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga del archivo .env
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElixirGym',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: Routes.usuario,
      routes: {
        Routes.usuario: (context) => UsuarioScreen(usuarioId: 2),
      },
    );
  }
}
