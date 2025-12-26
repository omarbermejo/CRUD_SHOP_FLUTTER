import '../general/app_error.dart';

/// Error del servidor HTTP
class ServerError extends AppError {
  final int statusCode;
  final Map<String, dynamic>? responseData;

  const ServerError({
    required super.message,
    required this.statusCode,
    this.responseData,
    super.code,
    super.originalError,
  });

  /// Error 400 - Bad Request
  factory ServerError.badRequest({
    Map<String, dynamic>? responseData,
    String? customMessage,
  }) {
    // Si hay un mensaje personalizado del servidor, usarlo; si no, usar el mensaje por defecto
    final message = customMessage != null && customMessage.isNotEmpty
        ? customMessage
        : 'Solicitud incorrecta. Verifica los datos enviados.';
    return ServerError(
      message: message,
      statusCode: 400,
      code: 'BAD_REQUEST',
      responseData: responseData,
    );
  }

  /// Error 401 - Unauthorized
        factory ServerError.unauthorized({
          Map<String, dynamic>? responseData,
          String? customMessage,
        }) {
          // Si el mensaje personalizado está vacío o es genérico, usar un mensaje más descriptivo
          final message = customMessage != null && customMessage.isNotEmpty && customMessage != 'Unauthorized'
              ? customMessage
              : 'No tienes permisos para realizar esta acción. Es posible que necesites permisos de administrador.';
          return ServerError(
            message: message,
            statusCode: 401,
            code: 'UNAUTHORIZED',
            responseData: responseData,
          );
        }

  /// Error 403 - Forbidden
  factory ServerError.forbidden({
    Map<String, dynamic>? responseData,
    String? customMessage,
  }) {
    return ServerError(
      message: customMessage ?? 'No tienes permisos para realizar esta acción.',
      statusCode: 403,
      code: 'FORBIDDEN',
      responseData: responseData,
    );
  }

  /// Error 404 - Not Found
  factory ServerError.notFound({
    Map<String, dynamic>? responseData,
    String? customMessage,
  }) {
    return ServerError(
      message: customMessage ?? 'Endpoint no encontrado.',
      statusCode: 404,
      code: 'NOT_FOUND',
      responseData: responseData,
    );
  }

  /// Error 500+ - Internal Server Error
  factory ServerError.internal({
    Map<String, dynamic>? responseData,
    int? statusCode,
    String? customMessage,
  }) {
    final code = statusCode ?? 500;
    return ServerError(
      message: customMessage ?? 'Error del servidor. Intenta más tarde.',
      statusCode: code,
      code: 'INTERNAL_SERVER_ERROR',
      responseData: responseData,
    );
  }

  /// Factory desde código de estado HTTP
  factory ServerError.fromStatusCode(
    int statusCode, {
    Map<String, dynamic>? responseData,
    String? customMessage,
  }) {
    switch (statusCode) {
      case 400:
        return ServerError.badRequest(
          responseData: responseData,
          customMessage: customMessage,
        );
      case 401:
        return ServerError.unauthorized(
          responseData: responseData,
          customMessage: customMessage,
        );
      case 403:
        return ServerError.forbidden(
          responseData: responseData,
          customMessage: customMessage,
        );
      case 404:
        return ServerError.notFound(
          responseData: responseData,
          customMessage: customMessage,
        );
      case 500:
      case 502:
      case 503:
        return ServerError.internal(
          statusCode: statusCode,
          responseData: responseData,
          customMessage: customMessage,
        );
      default:
        return ServerError(
          message: customMessage ?? 'Error del servidor (código: $statusCode).',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
          responseData: responseData,
        );
    }
  }
}

