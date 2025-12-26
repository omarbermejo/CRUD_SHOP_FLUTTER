import 'package:teslo_shop/features/auth/domain/entitis/auth_response.dart';
import 'package:teslo_shop/features/auth/domain/entitis/users.dart';

abstract class AuthDataSource {
  Future<AuthResponse> login(String email, String password);

  Future<AuthResponse> register(String email, String password, String fullName);

  Future<Users> checkAuthStatus(String token);

  Future<void> logout();
}
