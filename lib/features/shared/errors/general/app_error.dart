/// Clase base para todos los errores de la aplicación
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

