// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';

import 'package:teslo_shop/features/auth/presentation/provides/login_form_providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textStyles = Theme.of(context).textTheme;

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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (!context.canPop()) return;
                        context.pop();
                      },
                      icon: const Icon(Icons.arrow_back_rounded,
                          size: 40, color: Colors.white),
                    ),
                    const Spacer(flex: 1),
                    Text('Crear cuenta',
                        style:
                            textStyles.titleLarge?.copyWith(color: Colors.white)),
                    const Spacer(flex: 2),
                  ],
                ),

                const SizedBox(height: 50),

                Container(
                  height: size.height - 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(100)),
                  ),
                  child: const _RegisterForm(),
                )
              ],
            ),
          ),
        ),
      ),
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

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text('Nueva cuenta', style: textStyles.titleMedium),
          const SizedBox(height: 50),

          CustomTextFormField(
            label: 'Nombre completo',
            keyboardType: TextInputType.name,
            onChanged: notifier.setFullName,
            errorMessage: loginForm.fullName.isEmpty
                ? null
                : LoginFormValidators.validateFullName(loginForm.fullName),
          ),

          const SizedBox(height: 30),

          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.setEmail,
            errorMessage: loginForm.email.isEmpty
                ? null
                : LoginFormValidators.validateEmail(loginForm.email),
          ),

          const SizedBox(height: 30),

          CustomTextFormField(
            label: 'Contraseña',
            obscureText: true,
            onChanged: notifier.setPassword,
            errorMessage: loginForm.password.isEmpty
                ? null
                : LoginFormValidators.validatePassword(loginForm.password),
          ),

          const SizedBox(height: 30),

          CustomTextFormField(
            label: 'Repita la contraseña',
            obscureText: true,
            onChanged: notifier.setConfirmPassword,
            errorMessage: loginForm.confirmPassword.isEmpty
                ? null
                : LoginFormValidators.validateConfirmPassword(
                    loginForm.password,
                    loginForm.confirmPassword,
                  ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
              text: authState.status == AuthStatus.checking ? 'Cargando...' : 'Crear',
              buttonColor: Colors.black,
              onPressed: authState.status == AuthStatus.checking
                  ? null
                  : () async {
                      // Validación campos vacíos
                      if (loginForm.fullName.isEmpty ||
                          loginForm.email.isEmpty ||
                          loginForm.password.isEmpty ||
                          loginForm.confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor complete todos los campos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validaciones
                      final emailError =
                          LoginFormValidators.validateEmail(loginForm.email);
                      final passwordError =
                          LoginFormValidators.validatePassword(loginForm.password);
                      final confirmPasswordError =
                          LoginFormValidators.validateConfirmPassword(
                            loginForm.password,
                            loginForm.confirmPassword,
                          );

                      if (emailError != null ||
                          passwordError != null ||
                          confirmPasswordError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              emailError ??
                                  passwordError ??
                                  confirmPasswordError!,
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Register real con token
                      await authNotifier.register(loginForm.email, loginForm.password, loginForm.fullName);

                      final authResult = ref.read(authProvider);

                      if (!context.mounted) return;

                      if (authResult.status == AuthStatus.authenticated) {
                        context.go('/');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authResult.errorMessage ?? 'Error'),
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
              const Text('¿Ya tienes cuenta?'),
              TextButton(
                onPressed: () {
                  if (context.canPop()) return context.pop();
                  context.go('/login');
                },
                child: const Text('Ingresa aquí'),
              )
            ],
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
