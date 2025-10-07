class Rol {
  final int idRol;
  final String rol;

  Rol({required this.idRol, required this.rol});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['idRol'],
      rol: json['rol'],
    );
  }
}

class Usuario {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String fechaNacimiento;
  final double peso;
  final double altura;
  final String fechaRegistro;
  final String estado;
  final List<Rol> roles;

  Usuario({ required this.idUsuario, required this.nombre, required this.apellido,
  required this.correo, required this.telefono, required this.fechaNacimiento, required this.peso,
  required this.altura, required this.fechaRegistro, required this.estado, required this.roles});

  factory Usuario.fromJson(Map<String, dynamic> json){
    var rolesList = json['roles'] as List;
    List<Rol> roles = rolesList.map((i) => Rol.fromJson(i)).toList();

    return Usuario(
        idUsuario: json['idUsuario'],
        nombre: json['nombre'],
        apellido: json['apellido'],
        correo: json['correo'],
        telefono: json['telefono'],
        fechaNacimiento: json['fechaNacimiento'],
        peso: json['peso'].toDouble(),
        altura: json['altura'].toDouble(),
        fechaRegistro: json['fechaRegistro'],
        estado: json['estado'],
        roles: roles
    );
  }
}