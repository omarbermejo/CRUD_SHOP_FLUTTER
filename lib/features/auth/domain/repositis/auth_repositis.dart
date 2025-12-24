

import 'package:teslo_shop/features/auth/domain/entitis/users.dart';

abstract class AuthRepositis {
  // Métodos relacionados con la autenticación
  // Ejemplo de métodos que podrían estar aquí:
  Future<Users> login(String email, String password);

  Future<Users> register(String email, String password, String fullName);   
  Future<Users> checkAuthStatus(String token);
  Future<Users> logout();
  }
