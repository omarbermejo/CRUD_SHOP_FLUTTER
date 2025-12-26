import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teslo_shop/features/auth/domain/data_source/auth_datasource.dart';
import 'package:teslo_shop/features/auth/infretuction/auth_datasource_imp.dart';
import 'package:teslo_shop/features/auth/infretuction/token_storage.dart';
import 'auth_state.dart';

final authDatasourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDatasourceImp();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final datasource = ref.watch(authDatasourceProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthNotifier(datasource, storage)..checkAuthStatus();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSource datasource;
  final TokenStorage storage;

  AuthNotifier(this.datasource, this.storage) : super(const AuthState());

  /// Logica del login
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.checking);

      final response = await datasource.login(email, password);

      await storage.saveToken(response.token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        token: response.token,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Checha el estado de autenticación-
  Future<void> checkAuthStatus() async {
    final token = await storage.getToken();

    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await datasource.checkAuthStatus(token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );
    } catch (_) {
      await storage.removeToken();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Hace un logout
  Future<void> logout() async {
    await storage.removeToken();

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      token: null,
    );
  }
}
