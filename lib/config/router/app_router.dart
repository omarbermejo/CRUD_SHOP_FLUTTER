import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/auth.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/products/products.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    ///* Auth Routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    ///* Product Routes
    GoRoute(
      path: '/',
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: '/products/create',
      builder: (context, state) => const ProductCreateScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductScreenDetails(productId: productId);
      },
    ),
    GoRoute(
      path: '/products/my-products',
      builder: (context, state) => const MyProductsScreen(),
    ),
    GoRoute(
      path: '/products/edit/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductEditScreen(productId: productId);
      },
    ),
  ],
  redirect: (context, state) {
    final authState = ProviderScope.containerOf(context).read(authProvider);
    if (authState.status == AuthStatus.authenticated && state.path == '/login') {
      return '/';
    }
    if (authState.status == AuthStatus.unauthenticated && state.path != '/login') {
      return '/login';
    }
    return null;
  },
);
