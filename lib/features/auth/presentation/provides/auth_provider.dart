import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;
import 'package:teslo_shop/features/auth/domain/data_source/auth_datasource.dart';
import 'package:teslo_shop/features/auth/domain/entitis/auth_response.dart';
import 'package:teslo_shop/features/auth/domain/entitis/users.dart';
import 'package:teslo_shop/features/auth/infretuction/auth_datasource_imp.dart';
import 'package:teslo_shop/features/auth/infretuction/token_storage.dart';
import 'package:teslo_shop/features/shared/errors/errors.dart';
import 'package:teslo_shop/features/shared/errors/general/app_error.dart';

final authDatasourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDatasourceImp();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final datasource = ref.watch(authDatasourceProvider);
  final storage = ref.watch(tokenStorageProvider);

  return AuthNotifier(datasource, storage)..checkAuthStatus();
});

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final Users? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Users? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSource datasource;
  final TokenStorage storage;

  AuthNotifier(this.datasource, this.storage) : super(const AuthState());

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

      final AuthResponse response = await datasource.login(email, password);

      await storage.saveToken(response.token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        token: response.token,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

      final AuthResponse response = await datasource.register(email, password, fullName);

      await storage.saveToken(response.token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        token: response.token,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

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

  Future<void> logout() async {
    await storage.removeToken();

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      token: null,
    );
  }
}
