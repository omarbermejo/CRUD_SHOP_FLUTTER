import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_providers.dart';
import 'package:teslo_shop/features/products/presentation/widgets/product_card.dart';
import 'package:teslo_shop/features/shared/shared.dart';

final myProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  final authState = ref.watch(authProvider);

  final currentUser = authState.user;
  if (currentUser == null) {
    return [];
  }

  final currentUserId = currentUser.id;
  final allProducts = await useCase();

  if (allProducts.isEmpty) {
    return [];
  }

  final currentUserIdNormalized = currentUserId.toString().trim();
  final filteredProducts = <Product>[];
  for (var product in allProducts) {
    final productUserId = product.userId?.toString().trim();
    if (productUserId != null && productUserId == currentUserIdNormalized) {
      filteredProducts.add(product);
    }
  }

  return filteredProducts;
});

class MyProductsScreen extends ConsumerStatefulWidget {
  const MyProductsScreen({super.key});

  @override
  ConsumerState<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends ConsumerState<MyProductsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _navigateToCreateProduct() async {
    final result = await context.push('/products/create');
    if (result == true && mounted) {
      ref.invalidate(productsProvider);
      ref.invalidate(myProductsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(myProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Scaffold(
      key: scaffoldKey,
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Mis Productos'),
        actions: [
          PlatformHelper.isIOS
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _navigateToCreateProduct,
                  child: Icon(
                    CupertinoIcons.add,
                    color: colors['text'],
                  ),
                )
              : IconButton(
                  onPressed: _navigateToCreateProduct,
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Crear producto',
                )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myProductsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: productsAsync.when(
          data: (products) => _MyProductsView(
            products: products,
            onCreateProduct: _navigateToCreateProduct,
          ),
          loading: () => Center(
            child: PlatformHelper.isIOS
                ? CupertinoActivityIndicator(
                    color: colors['primary'],
                  )
                : CircularProgressIndicator(
                    color: colors['primary'],
                  ),
          ),
          error: (error, stack) => _ErrorView(
            error: error.toString(),
            onRetry: () => ref.invalidate(myProductsProvider),
          ),
        ),
      ),
      floatingActionButton: PlatformHelper.isIOS
          ? Container(
              decoration: BoxDecoration(
                color: colors['primary'],
                borderRadius: BorderRadius.circular(30),
              ),
              child: CupertinoButton(
                onPressed: _navigateToCreateProduct,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.add,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Nuevo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _navigateToCreateProduct,
              backgroundColor: colors['primary'],
              elevation: 0,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nuevo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }
}

class _MyProductsView extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onCreateProduct;

  const _MyProductsView({
    required this.products,
    required this.onCreateProduct,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors['surface'],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors['primary']!.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: colors['primary']!.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No tienes productos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors['text'],
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Crea tu primer producto para comenzar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors['textSecondary'],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onCreateProduct,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Crear producto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['primary'],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final crossAxisCount = ResponsiveHelper.getGridColumns(context);
    final padding = ResponsiveHelper.responsivePadding(context,
        basePadding: 16, minPadding: 8, maxPadding: 24);
    final spacing = ResponsiveHelper.responsivePadding(context,
        basePadding: 16, minPadding: 8, maxPadding: 20);

    final aspectRatio = crossAxisCount == 1 ? 0.75 : 0.62;

    return GridView.builder(
      padding:
          EdgeInsets.symmetric(horizontal: padding, vertical: padding * 1.25),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () {
            if (context.mounted) {
              context.push('/product/${product.id}');
            }
          },
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorView({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors['error']!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: colors['error'],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar productos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors['text'],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors['textSecondary'],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors['primary'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
