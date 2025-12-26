import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/products/domain/datasource/products_datasource.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/infrastructure/products_datasource_imp.dart';
import 'package:teslo_shop/features/products/presentation/widgets/product_card.dart';
import 'package:teslo_shop/features/shared/shared.dart';

final productsDatasourceProvider = Provider<ProductsDataSource>((ref) {
  return ProductsDatasourceImp();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final datasource = ref.watch(productsDatasourceProvider);
  return await datasource.getProducts();
});

/// Provider para el término de búsqueda
final searchTermProvider = StateNotifierProvider<SearchTermNotifier, String>((ref) {
  return SearchTermNotifier();
});

class SearchTermNotifier extends StateNotifier<String> {
  SearchTermNotifier() : super('');

  void updateSearchTerm(String term) {
    state = term;
  }

  void clearSearch() {
    state = '';
  }
}

/// Provider para productos buscados
final searchProductsProvider = FutureProvider.family<List<Product>, String>((ref, searchTerm) async {
  if (searchTerm.trim().isEmpty) {
    // Si no hay término de búsqueda, devolver lista vacía
    return [];
  }
  
  final datasource = ref.watch(productsDatasourceProvider);
  return await datasource.searchProducts(searchTerm.trim());
});

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(searchTermProvider.notifier).clearSearch();
        _searchFocusNode.unfocus();
      } else {
        // Esperar un frame para que el campo de búsqueda se cree
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchTerm = ref.watch(searchTermProvider);
    final productsAsync = ref.watch(productsProvider);
    final searchProductsAsync = ref.watch(searchProductsProvider(searchTerm));

    // Determinar qué datos mostrar: resultados de búsqueda o todos los productos
    final bool isSearching = searchTerm.isNotEmpty;
    final AsyncValue<List<Product>> displayProductsAsync = isSearching
        ? searchProductsAsync
        : productsAsync;

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                cursorColor: Colors.white,
                onChanged: (value) {
                  ref.read(searchTermProvider.notifier).updateSearchTerm(value);
                },
              )
            : const Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: displayProductsAsync.when(
        data: (products) => _ProductsView(
          products: products,
          isSearching: isSearching,
          searchTerm: searchTerm,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () {
            if (isSearching) {
              ref.invalidate(searchProductsProvider(searchTerm));
            } else {
              ref.invalidate(productsProvider);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo producto'),
        icon: const Icon(Icons.add),
        onPressed: () {
          context.push('/products/create');
        },
      ),
    );
  }
}

class _ProductsView extends StatelessWidget {
  final List<Product> products;
  final bool isSearching;
  final String searchTerm;

  const _ProductsView({
    required this.products,
    this.isSearching = false,
    this.searchTerm = '',
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
                isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                isSearching
                    ? 'No se encontraron productos'
                    : 'No hay productos disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (isSearching) ...[
                const SizedBox(height: 8),
                Text(
                  'Intenta con otro término de búsqueda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
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
            // TODO: Navegar a detalle del producto
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

  const _ErrorView({
    required this.error,
    this.onRetry,
  });

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
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
