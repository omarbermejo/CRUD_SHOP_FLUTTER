
import 'package:flutter_riverpod/legacy.dart';

class LoginFormState {
  final String email;
  final String password;
  final String ConfirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final String fullName;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.fullName = '',
    this.ConfirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    String? fullName,
    String? ConfirmPassword,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,  
      ConfirmPassword: ConfirmPassword ?? this.ConfirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
// Aqui son las clases de validacion de los objetos del input
/*
  Se valida parametro por parametro cada input posible.
  Esto se hace para tener un control mayor sobre los cambios de estados.
  Para poder manejarse de una manera mas faciel y sin tanta complejidad.


  Ejemplo de USO:
  ** SETEO DE VALORES O COMPOS PARA NO LLEVAR DATOS NULOS A LA BD **
  final emailError =
      LoginFormValidators.validateEmail(loginForm.email);
  final passwordError =
      LoginFormValidators.validatePassword(loginForm.password);
    ** VALIDACION EN CASO DE NO TENER ALGUN CAMPO LLENO **
  if (emailError != null || passwordError != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(emailError ?? passwordError!),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }


*/ 

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());
  // Seteo de campos en objetos
  void setEmail(String email) {
    state = state.copyWith(email: email);
  }
  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }
  void setConfirmPassword(String ConfirmPassword) {
    state = state.copyWith(ConfirmPassword: ConfirmPassword);
  }
  // Validaciones de los campos con sus respectivas funciones
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
  static bool isValidFullName(String fullName) {
    return fullName.isNotEmpty;
  }
  static bool isValidConfirmPassword(String password, String ConfirmPassword) {
    return password == ConfirmPassword;
  }
}

class LoginFormValidators {
  static String? validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Por favor ingrese un correo electrónico válido.';
    }
    return null;
  }
  static String? validateFullName(String fullName) {
    if (fullName.isEmpty) {
      return 'Por favor ingrese su nombre completo.';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }
  static String? validateConfirmPassword(String password, String ConfirmPassword) {
    if (password != ConfirmPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }
}

final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>(
  (ref) => LoginFormNotifier(),
);
