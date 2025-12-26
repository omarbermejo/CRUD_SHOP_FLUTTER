import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/auth/presentation/provides/login_form_providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: GeometricalBackground(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Icon(
                  Icons.production_quantity_limits_rounded,
                  color: Colors.white,
                  size: 100,
                ),
                const SizedBox(height: 80),
                Container(
                  height: size.height - 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(100)),
                  ),
                  child: const _LoginForm(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final loginNotifier = ref.read(loginFormProvider.notifier);

    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text('Login', style: textStyles.titleLarge),
          const SizedBox(height: 90),

          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            onChanged: loginNotifier.setEmail,
            errorMessage: loginForm.email.isEmpty
                ? null
                : LoginFormValidators.validateEmail(loginForm.email),
          ),

          const SizedBox(height: 30),

          CustomTextFormField(
            label: 'Contraseña',
            obscureText: true,
            onChanged: loginNotifier.setPassword,
            errorMessage: loginForm.password.isEmpty
                ? null
                : LoginFormValidators.validatePassword(loginForm.password),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: authState.status == AuthStatus.checking
                  ? 'Cargando...'
                  : 'Ingresar',
              buttonColor: Colors.black,
              onPressed: authState.status == AuthStatus.checking
                  ? null
                  : () async {

                      final emailError =
                          LoginFormValidators.validateEmail(loginForm.email);
                      final passwordError =
                          LoginFormValidators.validatePassword(loginForm.password);

                      if (emailError != null || passwordError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(emailError ?? passwordError!),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      await authNotifier.login(
                        loginForm.email,
                        loginForm.password,
                      );

                      final result = ref.read(authProvider);

                      if (!context.mounted) return;

                      if (result.status == AuthStatus.authenticated) {
                        context.go('/');
                      } else {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.errorMessage ?? 'Error al iniciar sesión',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
            ),
          ),

          const Spacer(flex: 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿No tienes cuenta?'),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Crea una aquí'),
              )
            ],
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
