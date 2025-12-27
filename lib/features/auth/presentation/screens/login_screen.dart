import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/auth/presentation/provides/login_form_providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colors['background'],
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
                        basePadding: 60, minPadding: 40, maxPadding: 80)),
                _buildHeader(context),
                SizedBox(
                    height: ResponsiveHelper.responsivePadding(context,
                        basePadding: 48, minPadding: 32, maxPadding: 64)),
                const _LoginForm(),
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
              ? CupertinoIcons.cart_fill
              : Icons.shopping_bag_rounded,
          size: ResponsiveHelper.responsiveFontSize(context,
              baseSize: 80, minSize: 60, maxSize: 100),
          color: colors['primary'],
        ),
        const SizedBox(height: 24),
        Text(
          'Bienvenido',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors['text'],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors['textSecondary'],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  bool _hasInitialized = false;
  final bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Limpiar el formulario la primera vez que se construye la pantalla
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(loginFormProvider.notifier).reset();
        }
      });
    }

    final loginForm = ref.watch(loginFormProvider);
    final loginNotifier = ref.read(loginFormProvider.notifier);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          label: 'Correo electrónico',
          hint: 'tu@email.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: loginNotifier.setEmail,
          errorMessage: loginForm.email.isEmpty
              ? null
              : LoginFormValidators.validateEmail(loginForm.email),
        ),
        CustomTextFormField(
          label: 'Contraseña',
          hint: 'Ingresa tu contraseña',
          obscureText: _obscurePassword,
          onChanged: loginNotifier.setPassword,
          errorMessage: loginForm.password.isEmpty
              ? null
              : LoginFormValidators.validatePassword(loginForm.password),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Implementar recuperación de contraseña
            },
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: colors['primary']),
            ),
          ),
        ),
        SizedBox(
            height: ResponsiveHelper.responsivePadding(context,
                basePadding: 32, minPadding: 24, maxPadding: 40)),
        CustomFilledButton(
          text: authState.status == AuthStatus.checking
              ? 'Iniciando sesión...'
              : 'Iniciar sesión',
          onPressed: authState.status == AuthStatus.checking
              ? null
              : () => _handleLogin(context, ref, loginForm, authNotifier),
        ),
        SizedBox(
            height: ResponsiveHelper.responsivePadding(context,
                basePadding: 24, minPadding: 20, maxPadding: 32)),
        _buildSignUpLink(context),
      ],
    );
  }

  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    dynamic loginForm,
    dynamic authNotifier,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    final emailError = LoginFormValidators.validateEmail(loginForm.email);
    final passwordError =
        LoginFormValidators.validatePassword(loginForm.password);

    if (emailError != null || passwordError != null) {
      if (PlatformHelper.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error de validación'),
            content: Text(emailError ?? passwordError!),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colors['card'],
            title: Text(
              'Error de validación',
              style: TextStyle(color: colors['text']),
            ),
            content: Text(
              emailError ?? passwordError!,
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
      return;
    }

    await authNotifier.login(loginForm.email, loginForm.password);
    final result = ref.read(authProvider);

    if (!context.mounted) return;

    if (result.status == AuthStatus.authenticated) {
      context.go('/');
    } else {
      if (PlatformHelper.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(result.errorMessage ?? 'Error al iniciar sesión'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colors['card'],
            title: Text(
              'Error',
              style: TextStyle(color: colors['text']),
            ),
            content: Text(
              result.errorMessage ?? 'Error al iniciar sesión',
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
    }
  }

  Widget _buildSignUpLink(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    if (PlatformHelper.isIOS) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿No tienes cuenta? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors['textSecondary'],
                ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => context.push('/register'),
            child: Text(
              'Regístrate',
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
            '¿No tienes cuenta? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors['textSecondary'],
                ),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            child: Text(
              'Regístrate',
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
