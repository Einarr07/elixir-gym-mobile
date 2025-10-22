import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacena credenciales y/o header de Basic Auth de forma segura.
/// NOTA: Evitamos SharedPreferences para no guardar contraseñas en texto plano.
class AuthStorage {
  // --- Singleton ---
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  // --- Secure storage ---
  // (en iOS/Android ya cifra en Keychain/Keystore)
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  // --- Keys ---
  static const _kUser = 'auth_user';
  static const _kPass = 'auth_pass';
  static const _kAuthHeader =
      'auth_header'; // opcional, si deseas persistir "Basic xxx"

  // ---------- Credenciales ----------
  Future<void> saveCredentials(String user, String pass) async {
    await _secure.write(key: _kUser, value: user);
    await _secure.write(key: _kPass, value: pass);
  }

  Future<({String? user, String? pass})> readCredentials() async {
    final user = await _secure.read(key: _kUser);
    final pass = await _secure.read(key: _kPass);
    return (user: user, pass: pass);
  }

  Future<bool> hasCredentials() async {
    final creds = await readCredentials();
    return (creds.user != null &&
        creds.user!.isNotEmpty &&
        creds.pass != null &&
        creds.pass!.isNotEmpty);
  }

  // ---------- Auth Header (opcional) ----------
  // Si prefieres no recalcular en cada request, puedes persistirlo:
  Future<void> saveAuthHeader(String value) =>
      _secure.write(key: _kAuthHeader, value: value);

  Future<String?> getAuthHeader() => _secure.read(key: _kAuthHeader);

  Future<void> clearAuthHeader() => _secure.delete(key: _kAuthHeader);

  // ---------- Borrado total ----------
  Future<void> clearAll() async {
    await _secure.delete(key: _kUser);
    await _secure.delete(key: _kPass);
    await _secure.delete(key: _kAuthHeader);
  }
}
