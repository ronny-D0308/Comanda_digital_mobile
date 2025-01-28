import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _role = '';  // Armazena o papel do usuário (admin, garcom, etc.)
  bool _isAuthenticated = false;  // Flag que indica se o usuário está autenticado

  // Getter para verificar se o usuário está autenticado
  bool get isAuthenticated => _isAuthenticated;

  // Getter para verificar se o usuário é admin
  bool get isAdmin => _role == 'admin';

  // Getter para verificar se o usuário é garçom
  bool get isGarcom => _role == 'garcom';

  // Método para realizar o login
  void login(String role) {
    _role = role;
    _isAuthenticated = true;  // Após o login, o usuário é autenticado
    notifyListeners();  // Notifica os ouvintes para atualizar a UI
  }

  // Método para realizar o logout
  void logout() {
    _role = '';
    _isAuthenticated = false;
    notifyListeners();  // Notifica os ouvintes para atualizar a UI
  }
}
