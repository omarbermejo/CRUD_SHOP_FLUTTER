/*
  En esta clase / archivo se manejan los estados de autenticacion de la aplicacion.
  esta es para hacer una compronacion rapida del estado de autenticacion del usuario.
  Se definen los estados posibles: checking, notAuthenticated, authenticated.
  Ademas, se crea una clase AuthProviderExtensions para manejar informacion adicional
  relacionada con el estado de autenticacion, como el usuario autenticado y posibles errores.
  Esta clase tiene un metodo copyWith para facilitar la creacion de nuevas instancias
  con modificaciones especificas.
 */


import 'package:flutter_riverpod/legacy.dart';
import 'package:teslo_shop/features/auth/domain/entitis/users.dart';

 final authProvider = StateNotifierProvider<AuthNotifier, AuthProviderExtensions>(
  (ref) => AuthNotifier(),
);


class AuthNotifier extends StateNotifier<AuthProviderExtensions> {
  AuthNotifier() : super(AuthProviderExtensions(authStatus: AuthProvider.checking));
  // Metodo para establecer el estado de autenticacion como "authenticated"
  void login(Users user) {
    state = state.copyWith(
      authStatus: AuthProvider.authenticated,
      user: user,
      error: null,
    );
  }
  // Metodo para establecer el estado de autenticacion como "notAuthenticated"
  void logout([Error? error]) {
    state = state.copyWith(
      authStatus: AuthProvider.notAuthenticated,
      user: null,
      error: error,
    );
  }
  // Metodo para establecer el estado de autenticacion como "checking"
  void checkAuthStatus() {
    state = state.copyWith(
      authStatus: AuthProvider.checking,
      user: null,
      error: null,
    );
  }
}


enum AuthProvider {
  checking,
  notAuthenticated,
  authenticated,
}

class AuthProviderExtensions {
    final AuthProvider authStatus;
    final Users? user;
    final Error? error;

  AuthProviderExtensions({
    required this.authStatus,
    this.user,
    this.error,
  });

  AuthProviderExtensions copyWith({
    AuthProvider? authStatus,
    Users? user,
    Error? error,
  }) {
    return AuthProviderExtensions(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

}