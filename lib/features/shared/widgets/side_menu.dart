import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({
    super.key,
    required this.scaffoldKey,
  });

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final textStyles = Theme.of(context).textTheme;

    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    // Obtener la ruta actual
    String currentLocation = '/';
    try {
      currentLocation = GoRouterState.of(context).uri.path;
    } catch (e) {
      try {
        currentLocation =
            GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      } catch (_) {
        currentLocation = '/';
      }
    }

    // Calcular el índice seleccionado basándose en la ruta actual
    int selectedIndex = 0; // Por defecto: Productos
    if (currentLocation == '/products/my-products') {
      selectedIndex = 1; // Mis productos
    } else if (currentLocation == '/profile') {
      selectedIndex = 2; // Perfil
    } else if (currentLocation == '/' ||
        currentLocation.startsWith('/product/') ||
        currentLocation == '/products/create') {
      selectedIndex = 0; // Productos
    }

    if (PlatformHelper.isIOS) {
      return _buildIOSMenu(context, hasNotch, textStyles, user, selectedIndex);
    } else {
      return _buildAndroidMenu(
          context, hasNotch, textStyles, user, selectedIndex);
    }
  }

  Widget _buildIOSMenu(BuildContext context, bool hasNotch,
      TextTheme textStyles, dynamic user, int selectedIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Drawer(
      backgroundColor: colors['background'],
      child: SafeArea(
        child: Column(
          children: [
            // Header con información del usuario (clickeable)
            GestureDetector(
              onTap: () {
                context.push('/profile');
                widget.scaffoldKey.currentState?.closeDrawer();
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, hasNotch ? 20 : 40, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'user_avatar_${user.id}',
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: colors['primary'],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola',
                                style: textStyles.titleMedium?.copyWith(
                                  color: colors['textSecondary'],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.fullName,
                                style: textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors['text'],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: colors['textSecondary'],
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Opciones del menú
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildIOSMenuItem(
                    context,
                    icon: CupertinoIcons.cart,
                    title: 'Productos',
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      context.go('/');
                      widget.scaffoldKey.currentState?.closeDrawer();
                    },
                  ),
                  _buildIOSMenuItem(
                    context,
                    icon: CupertinoIcons.bag,
                    title: 'Mis productos',
                    isSelected: selectedIndex == 1,
                    onTap: () {
                      context.go('/products/my-products');
                      widget.scaffoldKey.currentState?.closeDrawer();
                    },
                  ),
                  _buildIOSMenuItem(
                    context,
                    icon: CupertinoIcons.person_circle,
                    title: 'Mi Perfil',
                    isSelected: selectedIndex == 2,
                    onTap: () {
                      context.push('/profile');
                      widget.scaffoldKey.currentState?.closeDrawer();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton(
                color: colors['error'],
                onPressed: () {
                  final authNotifier = ref.read(authProvider.notifier);
                  authNotifier.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Container(
      color: isSelected ? colors['primary']!.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? colors['primary'] : colors['text'],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? colors['primary'] : colors['text'],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAndroidMenu(BuildContext context, bool hasNotch,
      TextTheme textStyles, dynamic user, int selectedIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return NavigationDrawer(
      elevation: 0,
      backgroundColor: colors['background'],
      selectedIndex: selectedIndex,
      onDestinationSelected: (value) {
        switch (value) {
          case 0: // Productos
            context.go('/');
            break;
          case 1: // Mis productos
            context.go('/products/my-products');
            break;
          case 2: // Perfil
            context.push('/profile');
            break;
        }
        widget.scaffoldKey.currentState?.closeDrawer();
      },
      children: [
        // Header con información del usuario (clickeable)
        GestureDetector(
          onTap: () {
            context.push('/profile');
            widget.scaffoldKey.currentState?.closeDrawer();
          },
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: colors['primary'],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Hero(
                  tag: 'user_avatar_${user.id}',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: colors['primary'],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hola',
                  style: textStyles.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: textStyles.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          label: Text('Productos'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_outlined),
          label: Text('Mis productos'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline),
          label: Text('Mi Perfil'),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomFilledButton(
            onPressed: () {
              final authNotifier = ref.read(authProvider.notifier);
              authNotifier.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            text: 'Cerrar sesión',
            buttonColor: colors['error'],
          ),
        ),
      ],
    );
  }
}
