import 'package:flutter/cupertino.dart';

import '../../../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  void setUsuario(Usuario user) {
    _usuario = user;
    notifyListeners();
  }
}
