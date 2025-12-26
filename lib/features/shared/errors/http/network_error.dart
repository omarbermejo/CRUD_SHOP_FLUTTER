import '../general/app_error.dart';

/// Error de conexión de red
class NetworkError extends AppError {
  final String? url;
  final String? details;

  const NetworkError({
    required super.message,
    this.url,
    this.details,
    super.code,
    super.originalError,
  });

  /// Error de conexión rechazada
  factory NetworkError.connectionRefused({
    String? url,
    String? details,
  }) {
    return NetworkError(
      message: 'Error de conexión. Verifica tu conexión a internet y que la URL del servidor sea correcta.',
      code: 'CONNECTION_REFUSED',
      url: url,
      details: details,
    );
  }

  /// Error de timeout
  factory NetworkError.timeout({
    String? url,
    Duration? timeout,
  }) {
    return NetworkError(
      message: 'Tiempo de espera agotado. Verifica tu conexión a internet.',
      code: 'TIMEOUT',
      url: url,
      details: timeout != null ? 'Timeout: ${timeout.inSeconds}s' : null,
    );
  }

  /// Error de formato JSON inválido
  factory NetworkError.invalidJson({
    String? details,
    dynamic originalError,
  }) {
    return NetworkError(
      message: 'Error al parsear la respuesta del servidor.',
      code: 'INVALID_JSON',
      details: details,
      originalError: originalError,
    );
  }
}

