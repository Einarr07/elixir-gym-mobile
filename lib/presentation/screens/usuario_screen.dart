import 'package:elixir_gym/data/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

class UsuarioScreen extends StatefulWidget {
  final int usuarioId;

  const UsuarioScreen({Key? key, required this.usuarioId}): super(key: key);
  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen>{
  late Future<Usuario> futureUsuario;

  @override
  void initState(){
    super.initState();
    futureUsuario = ApiService().fetchUsuario(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Perfil de usuario')),
      body: FutureBuilder<Usuario>(
        future: futureUsuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final usuario = snapshot.data!;
            return Padding(padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${usuario.nombre} ${usuario.apellido}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Correo: ${usuario.correo}'),
              Text('Telefono: ${usuario.telefono}'),
              Text('Peso: ${usuario.peso} kg'),
              Text('Altura: ${usuario.altura} m'),
              Text('Fecha Nacimiento: ${usuario.fechaNacimiento}'),
              Text('Estado: ${usuario.estado}'),
              SizedBox(height: 10),
              Text('Roles ${usuario.roles.map((r) => r.rol).join(', ')}')
            ],
            ),
            );
          } else {
            return Center(child: Text('Usuario no encontrado'));
          }
        }
      )
    );
  }

}