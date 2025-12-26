import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class SideMenu extends ConsumerStatefulWidget {

  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({
    super.key, 
    required this.scaffoldKey
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
      // Si GoRouterState no está disponible, intentar con GoRouter
      try {
        currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
      } catch (_) {
        // Si tampoco funciona, usar '/' por defecto
        currentLocation = '/';
      }
    }
    
    // Calcular el índice seleccionado basándose en la ruta actual
    int selectedIndex = 0; // Por defecto: Productos
    if (currentLocation == '/products/my-products') {
      selectedIndex = 1; // Mis productos
    } else if (currentLocation == '/' || 
               currentLocation.startsWith('/product/') ||
               currentLocation == '/products/create') {
      selectedIndex = 0; // Productos
    }

    return NavigationDrawer(
      elevation: 1,
      selectedIndex: selectedIndex,
      onDestinationSelected: (value) {
        // Navegar según la opción seleccionada
        switch (value) {
          case 0: // Productos
            context.go('/');
            break;
          case 1: // Mis productos
            context.go('/products/my-products');
            break;
        }

        widget.scaffoldKey.currentState?.closeDrawer();
      },
      children: [

        Padding(
          padding: EdgeInsets.fromLTRB(20, hasNotch ? 0 : 20, 16, 0),
          child: Text('Saludos', style: textStyles.titleMedium ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
          child: Text( user.fullName, style: textStyles.titleSmall ),
        ),

        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          label: Text('Productos'),
        ),

        const NavigationDrawerDestination(
          icon: Icon(Icons.add_circle_outline),
          label: Text('Mis productos'),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
          child: Text('Otras opciones'),
        ),

        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomFilledButton(
            onPressed: () {
              final authNotifier = ref.read(authProvider.notifier);
              authNotifier.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            text: 'Cerrar sesión'
          ),
        ),

      ]
    );
  }
}