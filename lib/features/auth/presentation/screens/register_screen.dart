// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/auth/presentation/provides/login_form_providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors['background'],
        appBar: AppBar(
          leading: PlatformHelper.isIOS
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  child: Icon(
                    CupertinoIcons.back,
                    color: colors['primary'],
                  ),
                )
              : null,
          title: const Text('Crear cuenta'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.responsivePadding(context,
                  basePadding: 24, minPadding: 20, maxPadding: 32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: ResponsiveHelper.responsivePadding(context,
                        basePadding: 32, minPadding: 24, maxPadding: 40)),
                _buildHeader(context),
                SizedBox(
                    height: ResponsiveHelper.responsivePadding(context,
                        basePadding: 32, minPadding: 24, maxPadding: 40)),
                const _RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Column(
      children: [
        Icon(
          PlatformHelper.isIOS
              ? CupertinoIcons.person_add_solid
              : Icons.person_add_rounded,
          size: ResponsiveHelper.responsiveFontSize(context,
              baseSize: 64, minSize: 48, maxSize: 80),
          color: colors['primary'],
        ),
        const SizedBox(height: 16),
        Text(
          'Crea tu cuenta',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors['text'],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Completa el formulario para comenzar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors['textSecondary'],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RegisterForm extends ConsumerWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          label: 'Nombre completo',
          hint: 'Juan Pérez',
          keyboardType: TextInputType.name,
          onChanged: notifier.setFullName,
          errorMessage: loginForm.fullName.isEmpty
              ? null
              : LoginFormValidators.validateFullName(loginForm.fullName),
        ),
        CustomTextFormField(
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.setEmail,
          errorMessage: loginForm.email.isEmpty
              ? null
              : LoginFormValidators.validateEmail(loginForm.email),
        ),
        CustomTextFormField(
          label: 'Contraseña',
          hint: 'Mínimo 6 caracteres',
          obscureText: true,
          onChanged: notifier.setPassword,
          errorMessage: loginForm.password.isEmpty
              ? null
              : LoginFormValidators.validatePassword(loginForm.password),
        ),
        CustomTextFormField(
          label: 'Confirmar contraseña',
          hint: 'Repite tu contraseña',
          obscureText: true,
          onChanged: notifier.setConfirmPassword,
          errorMessage: loginForm.confirmPassword.isEmpty
              ? null
              : LoginFormValidators.validateConfirmPassword(
                  loginForm.password, loginForm.confirmPassword),
        ),
        SizedBox(
            height: ResponsiveHelper.responsivePadding(context,
                basePadding: 32, minPadding: 24, maxPadding: 40)),
        CustomFilledButton(
          text: authState.status == AuthStatus.checking
              ? 'Creando cuenta...'
              : 'Crear cuenta',
          onPressed: authState.status == AuthStatus.checking
              ? null
              : () => _handleRegister(context, ref, loginForm, authNotifier),
        ),
        SizedBox(
            height: ResponsiveHelper.responsivePadding(context,
                basePadding: 24, minPadding: 20, maxPadding: 32)),
        _buildLoginLink(context),
      ],
    );
  }

  Future<void> _handleRegister(
    BuildContext context,
    WidgetRef ref,
    dynamic loginForm,
    dynamic authNotifier,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    // Validación campos vacíos
    if (loginForm.fullName.isEmpty ||
        loginForm.email.isEmpty ||
        loginForm.password.isEmpty ||
        loginForm.confirmPassword.isEmpty) {
      _showError(context, 'Por favor complete todos los campos', colors);
      return;
    }

    // Validaciones
    final emailError = LoginFormValidators.validateEmail(loginForm.email);
    final passwordError =
        LoginFormValidators.validatePassword(loginForm.password);
    final confirmPasswordError = LoginFormValidators.validateConfirmPassword(
      loginForm.password,
      loginForm.confirmPassword,
    );

    if (emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      _showError(context, emailError ?? passwordError ?? confirmPasswordError!,
          colors);
      return;
    }

    // Register
    await authNotifier.register(
      loginForm.email,
      loginForm.password,
      loginForm.fullName,
    );

    final authResult = ref.read(authProvider);

    if (!context.mounted) return;

    if (authResult.status == AuthStatus.authenticated) {
      context.go('/');
    } else {
      _showError(context, authResult.errorMessage ?? 'Error al crear la cuenta',
          colors);
    }
  }

  void _showError(
      BuildContext context, String message, Map<String, Color> colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors['card'],
        title: Text(
          'Error',
          style: TextStyle(color: colors['text']),
        ),
        content: Text(
          message,
          style: TextStyle(color: colors['textSecondary']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: colors['primary']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    if (PlatformHelper.isIOS) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tienes cuenta? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors['textSecondary'],
                ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/login');
              }
            },
            child: Text(
              'Inicia sesión',
              style: TextStyle(
                color: colors['primary'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tienes cuenta? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors['textSecondary'],
                ),
          ),
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/login');
              }
            },
            child: Text(
              'Inicia sesión',
              style: TextStyle(
                color: colors['primary'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
  }
}
