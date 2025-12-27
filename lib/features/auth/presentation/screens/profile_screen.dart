import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/config/theme/theme_provider.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;
    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: const Center(
          child: Text('No hay usuario autenticado'),
        ),
      );
    }

    return Scaffold(
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
        title: const Text('Mi Perfil'),
        actions: [
          // Toggle Dark Mode
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? (PlatformHelper.isIOS
                      ? CupertinoIcons.sun_max
                      : Icons.light_mode)
                  : (PlatformHelper.isIOS
                      ? CupertinoIcons.moon
                      : Icons.dark_mode),
              color: colors['text'],
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: themeMode == ThemeMode.dark ? 'Modo claro' : 'Modo oscuro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              color: colors['background'],
              child: Column(
                children: [
                  // Avatar
                  Hero(
                    tag: 'user_avatar_${user.id}',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors['primary']!.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors['primary']!,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        PlatformHelper.isIOS
                            ? CupertinoIcons.person_fill
                            : Icons.person,
                        size: 60,
                        color: colors['primary'],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nombre
                  Text(
                    user.fullName,
                    style: textStyles.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors['text'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Email
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors['surface'],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors['border']!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PlatformHelper.isIOS
                              ? CupertinoIcons.mail
                              : Icons.email_outlined,
                          size: 18,
                          color: colors['textSecondary'],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: colors['text'],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Información del perfil
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Información Personal
                  _buildSectionTitle(context, 'Información Personal'),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    icon: PlatformHelper.isIOS
                        ? CupertinoIcons.person_circle
                        : Icons.person_outline,
                    title: 'Nombre completo',
                    value: user.fullName,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    icon: PlatformHelper.isIOS
                        ? CupertinoIcons.mail
                        : Icons.email_outlined,
                    title: 'Correo electrónico',
                    value: user.email,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    icon: PlatformHelper.isIOS
                        ? CupertinoIcons.number
                        : Icons.badge_outlined,
                    title: 'ID de usuario',
                    value: user.id,
                  ),

                  const SizedBox(height: 32),

                  // Sección de Roles
                  _buildSectionTitle(context, 'Roles y Permisos'),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors['surface'],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors['border']!,
                        width: 1,
                      ),
                    ),
                    child: user.roles.isEmpty
                        ? Row(
                            children: [
                              Icon(
                                PlatformHelper.isIOS
                                    ? CupertinoIcons.info
                                    : Icons.info_outline,
                                color: colors['textSecondary'],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sin roles asignados',
                                style: TextStyle(
                                  color: colors['textSecondary'],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: user.roles.map((role) {
                              final isAdmin = role.toLowerCase() == 'admin';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? (isDark
                                          ? const Color(0xFF4A1E4A)
                                          : const Color(0xFFE1BEE7))
                                      : colors['primary']!.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isAdmin
                                        ? (isDark
                                            ? const Color(0xFFBA68C8)
                                            : const Color(0xFF9C27B0))
                                        : colors['primary']!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAdmin
                                          ? (PlatformHelper.isIOS
                                              ? CupertinoIcons.star_fill
                                              : Icons.star)
                                          : (PlatformHelper.isIOS
                                              ? CupertinoIcons.person_fill
                                              : Icons.person),
                                      size: 16,
                                      color: isAdmin
                                          ? (isDark
                                              ? const Color(0xFFBA68C8)
                                              : const Color(0xFF9C27B0))
                                          : colors['primary'],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      role.toUpperCase(),
                                      style: TextStyle(
                                        color: isAdmin
                                            ? (isDark
                                                ? const Color(0xFFBA68C8)
                                                : const Color(0xFF9C27B0))
                                            : colors['primary'],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Botón de cerrar sesión
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors['error'],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PlatformHelper.isIOS
                        ? CupertinoButton(
                            onPressed: () {
                              _showLogoutDialog(context, ref);
                            },
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CupertinoIcons.power,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              _showLogoutDialog(context, ref);
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors['card'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors['border']!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors['primary']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colors['primary'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors['textSecondary'],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors['text'],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    if (PlatformHelper.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cerrar sesión'),
              onPressed: () {
                Navigator.of(context).pop();
                final authNotifier = ref.read(authProvider.notifier);
                authNotifier.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      );
    } else {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colors = isDark
          ? AppColorsExtension.darkColors
          : AppColorsExtension.lightColors;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors['card'],
          title: Text(
            'Cerrar sesión',
            style: TextStyle(color: colors['text']),
          ),
          content: Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(color: colors['textSecondary']),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colors['textSecondary']),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final authNotifier = ref.read(authProvider.notifier);
                authNotifier.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: colors['error'],
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      );
    }
  }
}
