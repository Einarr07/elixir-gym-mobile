import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();
  final _secure = const FlutterSecureStorage();

  static const _kAuthHeader = 'auth_header';

  Future<void> saveAuthHeader(String value) =>
      _secure.write(key: _kAuthHeader, value: value);

  Future<String?> getAuthHeader() => _secure.read(key: _kAuthHeader);

  Future<void> clear() => _secure.delete(key: _kAuthHeader);
}
