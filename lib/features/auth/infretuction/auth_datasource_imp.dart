import 'package:flutter/foundation.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/features/auth/domain/data_source/auth_datasource.dart';
import 'package:teslo_shop/features/auth/domain/entitis/auth_response.dart';
import 'package:teslo_shop/features/auth/domain/entitis/users.dart';
import 'package:teslo_shop/features/shared/infra/http/http_client.dart';

class AuthDatasourceImp extends AuthDataSource {
  ApiHttpClient? _httpClient;

  ApiHttpClient get httpClient {
    _httpClient ??= _createHttpClient();
    return _httpClient!;
  }

  AuthDatasourceImp();

  ApiHttpClient _createHttpClient() {
    try {
      // Obtener la URL de la API desde la configuración
      final apiUrl = EnveriomentConfig.apiUrl;
      debugPrint('[AuthDatasource] Configurando cliente HTTP con baseUrl: $apiUrl');

      final client = ApiHttpClient(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        defaultHeaders: {'Content-Type': 'application/json'},
      );
      debugPrint('[AuthDatasource] Cliente HTTP configurado correctamente');
      return client;
    } on Exception catch (e) {
      debugPrint('[AuthDatasource] Error al configurar cliente HTTP: $e');
      // Re-lanzar excepciones de configuración con su mensaje original
      // (Estas ya tienen mensajes descriptivos de EnveriomentConfig)
      rethrow;
    } catch (e) {
      debugPrint('[AuthDatasource] Error inesperado al configurar cliente HTTP: $e');
      throw Exception('Error al configurar el cliente HTTP: $e');
    }
  }

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      debugPrint('[AuthDatasource] Iniciando login para: $email');
      final response = await httpClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      debugPrint('[AuthDatasource] Login exitoso. Response: $response');
      
      // El servidor devuelve los datos directamente, necesitamos transformarlos
      // al formato que espera AuthResponse: { user: {...}, token: "..." }
      final formattedResponse = {
        'user': response,
        'token': response['token'],
      };
      
      return AuthResponse.fromMap(formattedResponse);
    } catch (e, stackTrace) {
      debugPrint('[AuthDatasource] Error en login: $e');
      debugPrint('[AuthDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<AuthResponse> register(
      String email, String password, String fullName) async {
    try {
      debugPrint('[AuthDatasource] Iniciando registro para: $email');
      final response = await httpClient.post('/auth/register', body: {
        'email': email,
        'password': password,
        'fullName': fullName,
      });
      debugPrint('[AuthDatasource] Registro exitoso. Response: $response');
      
      // El servidor devuelve los datos directamente, necesitamos transformarlos
      // al formato que espera AuthResponse: { user: {...}, token: "..." }
      final formattedResponse = {
        'user': response,
        'token': response['token'],
      };
      
      return AuthResponse.fromMap(formattedResponse);
    } catch (e, stackTrace) {
      debugPrint('[AuthDatasource] Error en registro: $e');
      debugPrint('[AuthDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<Users> checkAuthStatus(String token) async {
    try {
      debugPrint('[AuthDatasource] Verificando estado de autenticación');
      final response = await httpClient.get(
        '/auth/check-status',
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint('[AuthDatasource] Check status exitoso. Response: $response');
      return Users.fromMap(response['user']);
    } catch (e, stackTrace) {
      debugPrint('[AuthDatasource] Error en checkAuthStatus: $e');
      debugPrint('[AuthDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> logout() async {
    // aquí podrías llamar un endpoint si lo tienes, por ejemplo:
    // await httpClient.post('/auth/logout');
    return;
  }

  String _handleError(dynamic error) {
    // El ApiHttpClient ya maneja los errores y los convierte en HttpException
    // con mensajes descriptivos, así que solo necesitamos extraer el mensaje
    final errorString = error.toString();

    // Si ya es una excepción con mensaje, extraer solo el mensaje
    if (errorString.contains('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }

    // Si es un HttpException, extraer el mensaje
    if (errorString.contains('HttpException: ')) {
      return errorString.replaceFirst('HttpException: ', '');
    }

    // Retornar el mensaje de error tal cual
    return errorString;
  }
}
