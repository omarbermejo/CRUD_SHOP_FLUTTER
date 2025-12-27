import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_providers.dart';
import 'package:teslo_shop/features/products/presentation/widgets/product_card.dart';
import 'package:teslo_shop/features/shared/shared.dart';

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

    final bool isSearching = searchTerm.isNotEmpty;
    final AsyncValue<List<Product>> displayProductsAsync =
        isSearching ? searchProductsAsync : productsAsync;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Scaffold(
      key: scaffoldKey,
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors['background'],
        surfaceTintColor: Colors.transparent,
        leading: PlatformHelper.isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
                child: Icon(
                  CupertinoIcons.bars,
                  color: colors['text'],
                ),
              )
            : IconButton(
                icon: Icon(
                  Icons.menu,
                  color: colors['text'],
                ),
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
        title: _isSearching
            ? (PlatformHelper.isIOS
                ? CupertinoSearchTextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    placeholder: 'Buscar productos...',
                    style: TextStyle(
                      color: colors['text'],
                      fontSize: 16,
                    ),
                    onChanged: (value) {
                      ref
                          .read(searchTermProvider.notifier)
                          .updateSearchTerm(value);
                    },
                  )
                : TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    style: TextStyle(
                      color: colors['text'],
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle: TextStyle(
                        color: colors['textSecondary'],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      ref
                          .read(searchTermProvider.notifier)
                          .updateSearchTerm(value);
                    },
                  ))
            : Text(
                'Productos',
                style: TextStyle(
                  color: colors['text'],
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          // Botón de ayuda
          (PlatformHelper.isIOS
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _showHelpDialog(context);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors['primary'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.question_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors['primary'],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    _showHelpDialog(context);
                  },
                )),
          // Botón de búsqueda
          (PlatformHelper.isIOS
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _toggleSearch,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isSearching
                          ? colors['error']!.withOpacity(0.1)
                          : colors['primary']!.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isSearching
                          ? CupertinoIcons.xmark
                          : CupertinoIcons.search,
                      color: _isSearching ? colors['error'] : colors['primary'],
                      size: 22,
                    ),
                  ),
                )
              : IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isSearching
                          ? colors['error']!.withOpacity(0.1)
                          : colors['primary']!.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: _isSearching ? colors['error'] : colors['primary'],
                      size: 22,
                    ),
                  ),
                  onPressed: _toggleSearch,
                )),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isSearching) {
            ref.invalidate(searchProductsProvider(searchTerm));
          } else {
            ref.invalidate(productsProvider);
          }
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: displayProductsAsync.when(
          data: (products) => _ProductsView(
            products: products,
            isSearching: isSearching,
            searchTerm: searchTerm,
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
            onRetry: () {
              if (isSearching) {
                ref.invalidate(searchProductsProvider(searchTerm));
              } else {
                ref.invalidate(productsProvider);
              }
            },
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
                onPressed: () => context.push('/products/create'),
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
              onPressed: () => context.push('/products/create'),
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

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors['card'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: colors['primary'],
            ),
            const SizedBox(width: 8),
            Text(
              'Ayuda',
              style: TextStyle(
                color: colors['text'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Aquí puedes buscar y explorar todos los productos disponibles. '
          'Usa el botón de búsqueda para filtrar productos por nombre o descripción.',
          style: TextStyle(
            color: colors['textSecondary'],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(
                color: colors['primary'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                  isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                  size: 64,
                  color: colors['primary']!.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSearching
                    ? 'No se encontraron productos'
                    : 'No hay productos disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors['text'],
                    ),
                textAlign: TextAlign.center,
              ),
              if (isSearching) ...[
                const SizedBox(height: 12),
                Text(
                  'Intenta con otro término de búsqueda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors['textSecondary'],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
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

  const _ErrorView({
    required this.error,
    this.onRetry,
  });

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
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
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
