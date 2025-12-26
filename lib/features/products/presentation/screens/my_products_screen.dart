import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/screens/products_screen.dart';
import 'package:teslo_shop/features/products/presentation/widgets/product_card.dart';
import 'package:teslo_shop/features/shared/shared.dart';

final myProductsProvider = FutureProvider<List<Product>>((ref) async {
  final datasource = ref.watch(productsDatasourceProvider);
  final authState = ref.watch(authProvider);
  
  // Obtener el userId del usuario autenticado desde el token/authState
  final currentUser = authState.user;
  if (currentUser == null) {
    debugPrint('[MyProductsProvider] No hay usuario autenticado');
    return [];
  }
  
  final currentUserId = currentUser.id;
  debugPrint('[MyProductsProvider] Usuario autenticado - ID: $currentUserId, Email: ${currentUser.email}');
  
  // Obtener todos los productos desde el endpoint GET /api/products
  // Nota: El backend NO tiene un endpoint específico para productos del usuario,
  // por lo que debemos obtener todos los productos y filtrarlos por userId en el cliente

  final allProducts = await datasource.getProducts();
  debugPrint('[MyProductsProvider] Total de productos obtenidos del endpoint: ${allProducts.length}');
  
  if (allProducts.isEmpty) {
    debugPrint('[MyProductsProvider] El endpoint /products NO devolvió ningún producto');
    debugPrint('[MyProductsProvider] Verifica en el backend que:');
    debugPrint('[MyProductsProvider] 1. Los productos existan en la base de datos');
    debugPrint('[MyProductsProvider] 2. El endpoint /products esté devolviendo los productos correctamente');
    debugPrint('[MyProductsProvider] 3. No haya filtros que impidan que se devuelvan los productos');
    return [];
  }
  
  // Filtrar productos que pertenecen al usuario actual
  // Comparar userId normalizado (string, sin espacios)
  final currentUserIdNormalized = currentUserId.toString().trim();
  debugPrint('[MyProductsProvider] Filtrando productos para userId: $currentUserIdNormalized');
  
  final filteredProducts = <Product>[];
  for (var product in allProducts) {
    final productUserId = product.userId?.toString().trim();
    debugPrint('[MyProductsProvider] Comparando - Producto: ${product.title}, ProductUserId: $productUserId, CurrentUserId: $currentUserIdNormalized');
    
    if (productUserId != null && productUserId == currentUserIdNormalized) {
      debugPrint('[MyProductsProvider] Producto coincide - ID: ${product.id}, Title: ${product.title}, UserId: $productUserId');
      filteredProducts.add(product);
    } else {
      debugPrint('[MyProductsProvider] Producto NO coincide - ProductUserId: $productUserId, CurrentUserId: $currentUserIdNormalized');
    }
  }
  
  debugPrint('[MyProductsProvider] Total de productos filtrados para el usuario: ${filteredProducts.length}');
  if (filteredProducts.isEmpty && allProducts.isNotEmpty) {
    debugPrint('[MyProductsProvider] ADVERTENCIA: Hay ${allProducts.length} productos pero ninguno coincide con userId $currentUserIdNormalized');
    debugPrint('[MyProductsProvider] UserIds de productos disponibles: ${allProducts.map((p) => p.userId).where((id) => id != null).toSet()}');
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
    // Si el producto se creó exitosamente, refrescar los providers
    if (result == true && mounted) {
      ref.invalidate(productsProvider);
      ref.invalidate(myProductsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: const Text('Mis Productos'),
        actions: [
          IconButton(
            onPressed: _navigateToCreateProduct,
            icon: const Icon(Icons.add_rounded),
          )
        ],
      ),
      body: productsAsync.when(
        data: (products) => _MyProductsView(
          products: products,
          onCreateProduct: _navigateToCreateProduct,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(error: error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo producto'),
        icon: const Icon(Icons.add),
        onPressed: _navigateToCreateProduct,
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
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No tienes productos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu primer producto para comenzar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onCreateProduct,
                icon: const Icon(Icons.add),
                label: const Text('Crear producto'),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
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

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar productos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // El provider se refrescará automáticamente cuando se reconstruya
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

