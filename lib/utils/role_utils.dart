import 'package:elixir_gym/data/models/user_model.dart';

enum UserRole { cliente, entrenador, admin, desconocido }

UserRole mapRawRole(String raw) {
  switch (raw.toUpperCase()) {
    case 'ADMIN':
      return UserRole.admin;
    case 'ENTRENADOR':
      return UserRole.entrenador;
    case 'CLIENTE':
      return UserRole.cliente;
    default:
      return UserRole.desconocido;
  }
}

UserRole pickEffectiveRole(Usuario u) {
  final roles = u.roles.map((r) => mapRawRole(r.rol)).toSet();
  if (roles.contains(UserRole.admin)) return UserRole.admin;
  if (roles.contains(UserRole.entrenador)) return UserRole.entrenador;
  if (roles.contains(UserRole.cliente)) return UserRole.cliente;
  return UserRole.desconocido;
}
