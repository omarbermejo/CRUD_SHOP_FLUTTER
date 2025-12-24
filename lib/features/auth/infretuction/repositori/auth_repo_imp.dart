
import 'package:teslo_shop/features/auth/domain/data_source/auth_datasource.dart';
import 'package:teslo_shop/features/auth/domain/entitis/users.dart';
import 'package:teslo_shop/features/auth/domain/repositis/auth_repositis.dart';
import 'package:teslo_shop/features/auth/infretuction/auth_datasource_imp.dart';

class AuthRepoImp extends AuthRepositis {
  final AuthDataSource dataSource;

  AuthRepoImp(
    AuthDataSource? dataSource,
  ) : dataSource = dataSource ?? AuthDatasourceImp();

  @override
  Future<Users> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<Users> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<Users> logout() {
    return dataSource.logout();
  }

  @override
  Future<Users> register(String email, String password, String fullName) {
    return dataSource.register(email, password, fullName);
  }
  // Implementación del repositorio de autenticación
}