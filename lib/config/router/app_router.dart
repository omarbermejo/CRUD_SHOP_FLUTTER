import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/auth.dart';
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
  ///! TODO: Bloquear si no se está autenticado de alguna manera
);