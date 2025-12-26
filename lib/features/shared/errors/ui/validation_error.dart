import '../general/app_error.dart';

/// Error de validación de formularios o inputs
class ValidationError extends AppError {
  final String? fieldName;

  const ValidationError({
    required super.message,
    this.fieldName,
    super.code,
    super.originalError,
  });

  /// Error de campo requerido
  factory ValidationError.required({String? fieldName}) {
    return ValidationError(
      message: 'El campo ${fieldName ?? 'es requerido'}',
      code: 'REQUIRED_FIELD',
      fieldName: fieldName,
    );
  }

  /// Error de formato de email inválido
  factory ValidationError.invalidEmail() {
    return ValidationError(
      message: 'Por favor ingrese un correo electrónico válido.',
      code: 'INVALID_EMAIL',
      fieldName: 'email',
    );
  }

  /// Error de contraseña muy corta
  factory ValidationError.passwordTooShort({int minLength = 6}) {
    return ValidationError(
      message: 'La contraseña debe tener al menos $minLength caracteres.',
      code: 'PASSWORD_TOO_SHORT',
      fieldName: 'password',
    );
  }

  /// Error de contraseñas no coinciden
  factory ValidationError.passwordsDoNotMatch() {
    return ValidationError(
      message: 'Las contraseñas no coinciden.',
      code: 'PASSWORDS_DO_NOT_MATCH',
      fieldName: 'confirmPassword',
    );
  }

  /// Error de nombre completo vacío
  factory ValidationError.fullNameRequired() {
    return ValidationError(
      message: 'Por favor ingrese su nombre completo.',
      code: 'FULL_NAME_REQUIRED',
      fieldName: 'fullName',
    );
  }
}

