import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:teslo_shop/features/shared/errors/errors.dart';

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
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      'GET',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
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

  /// Realiza una petición PATCH
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _request(
      'PATCH',
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

  /// Sube un archivo usando multipart/form-data
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    io.File file, {
    Map<String, String>? headers,
    String fieldName = 'file',
  }) async {
    final client = io.HttpClient()
      ..connectionTimeout = const Duration(seconds: 30); // Timeout más largo para uploads

    try {
      // Combinar headers (sin Content-Type, se establecerá automáticamente)
      final requestHeaders = <String, String>{};
      if (headers != null) {
        requestHeaders.addAll(headers);
        requestHeaders.remove('Content-Type'); // Remover Content-Type si existe
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('[ApiHttpClient] Subiendo archivo a: $uri');

      final request = await client.postUrl(uri);
      
      // Configurar headers
      requestHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Crear el multipart request
      final boundary = 'dart-http-boundary-${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');

      // Construir el body multipart
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split(Platform.pathSeparator).last;
      
      // Crear el header del multipart
      final headerBytes = utf8.encode(
        '--$boundary\r\n'
        'Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n'
        'Content-Type: ${_getContentType(fileName)}\r\n\r\n',
      );
      
      // Footer del multipart
      final footerBytes = utf8.encode('\r\n--$boundary--\r\n');

      // Calcular el tamaño total
      final contentLength = headerBytes.length + fileBytes.length + footerBytes.length;
      request.contentLength = contentLength;
      
      // Escribir el contenido
      request.add(headerBytes);
      request.add(fileBytes);
      request.add(footerBytes);

      // Enviar la petición
      final response = await request.close().timeout(receiveTimeout);

      // Leer la respuesta
      final responseBody = await response
          .transform(utf8.decoder)
          .join();

      dynamic jsonResponse;
      if (responseBody.isNotEmpty) {
        try {
          jsonResponse = jsonDecode(responseBody);
        } catch (e) {
          throw NetworkError.invalidJson(
            details: 'Respuesta del servidor: $responseBody',
            originalError: e,
          );
        }
      }

      debugPrint('[ApiHttpClient] Respuesta de upload recibida - Status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final responseData = jsonResponse is Map<String, dynamic> 
            ? jsonResponse
            : null;
        final errorMessage = _extractErrorMessage(response.statusCode, responseData);
        throw ServerError.fromStatusCode(
          response.statusCode,
          responseData: responseData,
          customMessage: errorMessage.isNotEmpty ? errorMessage : null,
        );
      }

      if (jsonResponse is Map<String, dynamic>) {
        return jsonResponse;
      } else if (jsonResponse is List) {
        return {'data': jsonResponse};
      } else {
        return {'data': jsonResponse};
      }
    } on NetworkError {
      rethrow;
    } on ServerError {
      rethrow;
    } catch (e) {
      if (e is NetworkError || e is ServerError) {
        rethrow;
      }
      throw NetworkError(
        message: 'Error al subir archivo: ${e.toString()}',
        code: 'UPLOAD_ERROR',
        originalError: e,
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Obtiene el Content-Type basado en la extensión del archivo
  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Método interno para realizar las peticiones HTTP
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final client = io.HttpClient()
      ..connectionTimeout = connectTimeout;

    try {
      // Combinar headers por defecto con headers personalizados
      final requestHeaders = <String, String>{...defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Construir la URL completa con query parameters si existen
      final baseUri = Uri.parse('$baseUrl$endpoint');
      final uri = queryParameters != null && queryParameters.isNotEmpty
          ? baseUri.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())))
          : baseUri;
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
      if (body != null && (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
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
          throw NetworkError.invalidJson(
            details: 'Respuesta del servidor: $responseBody',
            originalError: e,
          );
        }
      }

      // Manejar errores HTTP
      debugPrint('[ApiHttpClient] Respuesta recibida - Status: ${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final responseData = jsonResponse is Map<String, dynamic> 
            ? jsonResponse
            : null;
        debugPrint('[ApiHttpClient] Error response data: $responseData');
        final errorMessage = _extractErrorMessage(response.statusCode, responseData);
        
        debugPrint('[ApiHttpClient] Error HTTP ${response.statusCode}: $errorMessage');
        throw ServerError.fromStatusCode(
          response.statusCode,
          responseData: responseData,
          customMessage: errorMessage.isNotEmpty ? errorMessage : null,
        );
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
    } on NetworkError {
      rethrow;
    } on ServerError {
      rethrow;
    } on io.SocketException catch (e) {
      throw NetworkError.connectionRefused(
        url: '$baseUrl$endpoint',
        details: e.message,
      );
    } on TimeoutException {
      throw NetworkError.timeout(
        url: '$baseUrl$endpoint',
        timeout: connectTimeout,
      );
    } catch (e) {
      // Capturar timeout y otros errores
      if (e is NetworkError || e is ServerError) {
        rethrow;
      }
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('timeout') ||
          errorString.contains('timed out')) {
        throw NetworkError.timeout(
          url: '$baseUrl$endpoint',
          timeout: connectTimeout,
        );
      }
      throw NetworkError(
        message: 'Error desconocido: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Extrae el mensaje de error del backend si está disponible
  String _extractErrorMessage(int statusCode, Map<String, dynamic>? data) {
    if (data == null) return '';
    
    // Intentar extraer el mensaje del backend en diferentes formatos comunes
    if (data['message'] != null) {
      final message = data['message'];
      if (message is String) return _cleanMessage(message);
      if (message is List && message.isNotEmpty) {
        // Si es una lista, tomar el primer elemento
        final first = message.first;
        if (first is String) return _cleanMessage(first);
        return _cleanMessage(first.toString());
      }
      return _cleanMessage(message.toString());
    }
    
    // Algunos servidores usan 'error' en lugar de 'message'
    if (data['error'] != null) {
      final error = data['error'];
      if (error is String) return _cleanMessage(error);
      if (error is Map && error['message'] != null) {
        return _cleanMessage(error['message'].toString());
      }
      return _cleanMessage(error.toString());
    }
    
    // Algunos servidores devuelven un array de errores en 'errors'
    if (data['errors'] != null) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is Map) {
          if (firstError['msg'] != null) {
            return _cleanMessage(firstError['msg'].toString());
          }
          if (firstError['message'] != null) {
            return _cleanMessage(firstError['message'].toString());
          }
        }
        if (firstError is String) {
          return _cleanMessage(firstError);
        }
        return _cleanMessage(firstError.toString());
      }
      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstValue = errors[firstKey];
        if (firstValue is List && firstValue.isNotEmpty) {
          final firstItem = firstValue.first;
          if (firstItem is String) return _cleanMessage(firstItem);
          return _cleanMessage(firstItem.toString());
        }
        if (firstValue is String) return _cleanMessage(firstValue);
        return _cleanMessage(firstValue.toString());
      }
    }
    
    // Si no hay mensaje personalizado, retornar vacío para usar el mensaje por defecto
    return '';
  }
  
  /// Limpia el mensaje de error, removiendo corchetes y espacios innecesarios
  String _cleanMessage(String message) {
    // Remover corchetes externos si existen
    String cleaned = message.trim();
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }
    return cleaned;
  }
}
