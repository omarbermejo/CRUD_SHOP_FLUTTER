import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';

/// Cliente HTTP manual usando HttpClient nativo de Dart
class ApiHttpClient {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, String> defaultHeaders;

  ApiHttpClient({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? {
          'Content-Type': 'application/json',
        };

  /// Realiza una petición GET
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _request(
      'GET',
      endpoint,
      headers: headers,
    );
  }

  /// Realiza una petición POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _request(
      'POST',
      endpoint,
      body: body,
      headers: headers,
    );
  }

  /// Realiza una petición PUT
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _request(
      'PUT',
      endpoint,
      body: body,
      headers: headers,
    );
  }

  /// Realiza una petición DELETE
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _request(
      'DELETE',
      endpoint,
      headers: headers,
    );
  }

  /// Método interno para realizar las peticiones HTTP
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final client = io.HttpClient()
      ..connectionTimeout = connectTimeout;

    try {
      // Combinar headers por defecto con headers personalizados
      final requestHeaders = <String, String>{...defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Construir la URL completa
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('[ApiHttpClient] Realizando petición $method a: $uri');

      // Crear la petición con timeout
      final request = await client
          .openUrl(method, uri)
          .timeout(connectTimeout);

      // Configurar headers
      requestHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Configurar opciones de la petición
      request.followRedirects = true;
      request.maxRedirects = 5;

      // Si hay body, escribirlo
      if (body != null && (method == 'POST' || method == 'PUT')) {
        final jsonBody = jsonEncode(body);
        final bodyBytes = utf8.encode(jsonBody);
        request.contentLength = bodyBytes.length;
        request.add(bodyBytes);
      }

      // Enviar la petición y esperar la respuesta con timeout
      final response = await request
          .close()
          .timeout(receiveTimeout);

      // Leer el cuerpo de la respuesta
      final responseBody = await response
          .transform(utf8.decoder)
          .join();

      // Parsear la respuesta JSON
      dynamic jsonResponse;
      if (responseBody.isNotEmpty) {
        try {
          jsonResponse = jsonDecode(responseBody);
        } catch (e) {
          throw io.HttpException(
            'Error al parsear la respuesta JSON: $e\n'
            'Respuesta del servidor: $responseBody',
          );
        }
      }

      // Manejar errores HTTP
      debugPrint('[ApiHttpClient] Respuesta recibida - Status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = _handleHttpError(
          response.statusCode,
          jsonResponse,
        );
        debugPrint('[ApiHttpClient] Error HTTP ${response.statusCode}: $errorMessage');
        throw io.HttpException(errorMessage);
      }

      // Retornar la respuesta parseada
      final responsePreview = jsonResponse.toString();
      final preview = responsePreview.length > 200 
          ? '${responsePreview.substring(0, 200)}...' 
          : responsePreview;
      debugPrint('[ApiHttpClient] Respuesta exitosa: $preview');
      if (jsonResponse is Map<String, dynamic>) {
        return jsonResponse;
      } else if (jsonResponse is List) {
        return {'data': jsonResponse};
      } else {
        return {'data': jsonResponse};
      }
    } on io.SocketException catch (e) {
      final errorMessage = 'Error de conexión. Verifica tu conexión a internet y que la URL del servidor sea correcta.\n'
          'URL intentada: $baseUrl$endpoint\n'
          'Detalle: ${e.message}\n'
          'Si estás usando Android Emulator, asegúrate de usar http://10.0.2.2:3000/api en lugar de localhost';
      throw io.HttpException(errorMessage);
    } on io.HttpException {
      rethrow;
    } catch (e) {
      // Capturar timeout y otros errores
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('timeout') ||
          errorString.contains('timed out')) {
        throw io.HttpException(
          'Tiempo de espera agotado. Verifica tu conexión a internet.',
        );
      }
      throw io.HttpException(
        'Error desconocido: ${e.toString()}',
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Maneja los errores HTTP y retorna un mensaje descriptivo
  String _handleHttpError(int statusCode, dynamic data) {
    // Intentar extraer el mensaje del backend
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    // Mensajes por código de estado
    switch (statusCode) {
      case 400:
        return 'Solicitud incorrecta. Verifica los datos enviados.';
      case 401:
        return 'Credenciales inválidas.';
      case 403:
        return 'No tienes permisos para realizar esta acción.';
      case 404:
        return 'Endpoint no encontrado.';
      case 500:
      case 502:
      case 503:
        return 'Error del servidor. Intenta más tarde.';
      default:
        return 'Error del servidor (código: $statusCode).';
    }
  }
}
