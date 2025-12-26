import 'package:teslo_shop/features/auth/domain/entitis/users.dart';

class AuthResponse {
  final Users user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromMap(Map<String, dynamic> json) {
    return AuthResponse(
      user: Users.fromMap(json['user']),
      token: json['token'],
    );
  }
}

