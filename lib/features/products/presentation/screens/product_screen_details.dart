import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/auth/presentation/provides/auth_provider.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_providers.dart';
import 'package:teslo_shop/features/products/presentation/utils/product_permissions.dart';

class ProductScreenDetails extends ConsumerWidget {
  final String productId;

  const ProductScreenDetails({
    super.key,
    required this.productId,
  });

  String _buildImageUrl(String imageName) {
    try {
      final baseUrl = EnveriomentConfig.apiUrl;
      if (imageName.startsWith('http://') || imageName.startsWith('https://')) {
        return imageName;
      }
      return '$baseUrl/files/product/$imageName';
    } catch (e) {
      return imageName;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final textStyles = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);
    final currentUser = authState.user;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    if (PlatformHelper.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Detalle del Producto'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // TODO: Mostrar ayuda
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
              ),
              ...productAsync.when(
                data: (product) => [
                  if (canEditProduct(product, currentUser))
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        context.push('/products/edit/${product.id}');
                      },
                      child: Icon(
                        CupertinoIcons.pencil,
                        color: colors['text'],
                      ),
                    ),
                ],
                loading: () => const [],
                error: (_, __) => const [],
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: CupertinoScrollbar(
            child: CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    ref.invalidate(productDetailProvider(productId));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: productAsync.when(
                    data: (product) => _ProductDetailView(
                      product: product,
                      buildImageUrl: _buildImageUrl,
                      textStyles: textStyles,
                      currentUser: currentUser,
                    ),
                    loading: () => Center(
                      child: CupertinoActivityIndicator(
                        color: colors['primary'],
                      ),
                    ),
                    error: (error, stack) => _ErrorView(
                      error: error.toString(),
                      onRetry: () {
                        ref.invalidate(productDetailProvider(productId));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Producto'),
          actions: [
            // Botón de ayuda
            IconButton(
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
                // TODO: Mostrar ayuda
              },
            ),
            ...productAsync.when(
              data: (product) => [
                if (canEditProduct(product, currentUser))
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: colors['text'],
                    ),
                    tooltip: 'Editar producto',
                    onPressed: () {
                      context.push('/products/edit/${product.id}');
                    },
                  ),
              ],
              loading: () => const [],
              error: (_, __) => const [],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productDetailProvider(productId));
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: productAsync.when(
            data: (product) => _ProductDetailView(
              product: product,
              buildImageUrl: _buildImageUrl,
              textStyles: textStyles,
              currentUser: currentUser,
            ),
            loading: () => Center(
              child: CircularProgressIndicator(
                color: colors['primary'],
              ),
            ),
            error: (error, stack) => _ErrorView(
              error: error.toString(),
              onRetry: () {
                ref.invalidate(productDetailProvider(productId));
              },
            ),
          ),
        ),
      );
    }
  }
}

class _ProductDetailView extends StatefulWidget {
  final Product product;
  final String Function(String) buildImageUrl;
  final TextTheme textStyles;
  final dynamic currentUser;

  const _ProductDetailView({
    required this.product,
    required this.buildImageUrl,
    required this.textStyles,
    required this.currentUser,
  });

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  int _selectedImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textStyles = widget.textStyles;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imágenes del producto
          _ProductImagesCarousel(
            images: product.images,
            selectedIndex: _selectedImageIndex,
            buildImageUrl: widget.buildImageUrl,
            pageController: _pageController,
            onImageSelected: (index) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
          ),

          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.responsivePadding(context,
                basePadding: 16, minPadding: 12, maxPadding: 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y género
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: textStyles.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _GenderChip(gender: product.gender),
                  ],
                ),

                const SizedBox(height: 8),

                // Slug
                Text(
                  product.slug,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors['textSecondary'],
                  ),
                ),

                const SizedBox(height: 16),

                // Precio con estilo destacado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors['primary'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: textStyles.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Descripción
                Text(
                  'Descripción',
                  style: textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: textStyles.bodyLarge,
                ),

                const SizedBox(height: 24),

                // Información del producto
                _ProductInfoSection(
                  product: product,
                  textStyles: textStyles,
                ),

                const SizedBox(height: 32),

                // Botones de acción
                if (canEditProduct(product, widget.currentUser))
                  SizedBox(
                    width: double.infinity,
                    child: PlatformHelper.isIOS
                        ? CupertinoButton.filled(
                            onPressed: () {
                              context.push('/products/edit/${product.id}');
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.pencil, size: 18),
                                SizedBox(width: 8),
                                Text('Editar Producto'),
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              context.push('/products/edit/${product.id}');
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Editar Producto',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.responsivePadding(
                                      context,
                                      basePadding: 16,
                                      minPadding: 12,
                                      maxPadding: 20)),
                              backgroundColor: colors['primary'],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),

                if (canEditProduct(product, widget.currentUser))
                  SizedBox(
                      height: ResponsiveHelper.responsivePadding(context,
                          basePadding: 12, minPadding: 8, maxPadding: 16)),

                SizedBox(
                  width: double.infinity,
                  child: PlatformHelper.isIOS
                      ? CupertinoButton.filled(
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: const Text('Próximamente'),
                                content: const Text(
                                    'La funcionalidad de carrito estará disponible pronto.'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.cart, size: 18),
                              SizedBox(width: 8),
                              Text('Agregar al Carrito'),
                            ],
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'La funcionalidad de carrito estará disponible pronto.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: colors['surface'],
                                action: SnackBarAction(
                                  label: 'OK',
                                  textColor: colors['primary'],
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: const Text(
                            'Agregar al Carrito',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.responsivePadding(
                                    context,
                                    basePadding: 16,
                                    minPadding: 12,
                                    maxPadding: 20)),
                            backgroundColor: colors['primary'],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImagesCarousel extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  final String Function(String) buildImageUrl;
  final PageController pageController;
  final ValueChanged<int> onImageSelected;

  const _ProductImagesCarousel({
    required this.images,
    required this.selectedIndex,
    required this.buildImageUrl,
    required this.pageController,
    required this.onImageSelected,
  });

  @override
  State<_ProductImagesCarousel> createState() => _ProductImagesCarouselState();
}

class _ProductImagesCarouselState extends State<_ProductImagesCarousel> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    final imageHeight = ResponsiveHelper.responsivePadding(context,
        basePadding: 400, minPadding: 250, maxPadding: 500);
    final thumbnailHeight = ResponsiveHelper.responsivePadding(context,
        basePadding: 100, minPadding: 70, maxPadding: 120);
    final thumbnailSize = ResponsiveHelper.responsivePadding(context,
        basePadding: 80, minPadding: 60, maxPadding: 100);

    if (widget.images.isEmpty) {
      return Container(
        width: double.infinity,
        height: imageHeight,
        color: colors['background'],
        child: Center(
          child: Icon(
            Icons.image,
            size: ResponsiveHelper.responsiveFontSize(context,
                baseSize: 100, minSize: 60, maxSize: 120),
            color: colors['textSecondary'],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Carousel de imágenes principales
        SizedBox(
          width: double.infinity,
          height: imageHeight,
          child: PageView.builder(
            controller: widget.pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onImageSelected(index);
            },
            itemBuilder: (context, index) {
              final imageUrl = widget.buildImageUrl(widget.images[index]);
              return Container(
                width: double.infinity,
                color: colors['background'],
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: colors['primary'],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 100,
                        color: colors['textSecondary'],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Indicadores de página
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? colors['primary']
                        : colors['textSecondary']!.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

        // Thumbnails
        if (widget.images.length > 1)
          Container(
            height: thumbnailHeight,
            padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.responsivePadding(context,
                    basePadding: 12, minPadding: 8, maxPadding: 16)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.responsivePadding(context,
                      basePadding: 16, minPadding: 12, maxPadding: 24)),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                final thumbnailUrl = widget.buildImageUrl(widget.images[index]);

                return GestureDetector(
                  onTap: () {
                    widget.pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: thumbnailSize,
                    height: thumbnailSize,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? colors['primary']! : colors['border']!,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colors['background'],
                            child: Icon(
                              Icons.broken_image,
                              color: colors['textSecondary'],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  final Product product;
  final TextTheme textStyles;

  const _ProductInfoSection({
    required this.product,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    Color stockColor;
    if (product.stock > 10) {
      stockColor = colors['success']!;
    } else if (product.stock > 0) {
      stockColor = colors['warning']!;
    } else {
      stockColor = colors['error']!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: 'Stock disponible',
          value: product.stock.toString(),
          color: stockColor,
        ),
        const SizedBox(height: 12),
        if (product.sizes.isNotEmpty)
          _InfoRow(
            label: 'Tallas disponibles',
            value: product.sizes.join(', '),
          ),
        const SizedBox(height: 12),
        if (product.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags.map((tag) {
              return Chip(
                label: Text(tag),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: colors['text'],
                ),
                backgroundColor: colors['surface'],
                side: BorderSide(color: colors['border']!),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors['textSecondary'],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color ?? colors['text'],
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String gender;

  const _GenderChip({required this.gender});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (gender.toLowerCase()) {
      case 'men':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        break;
      case 'women':
        backgroundColor = Colors.pink[100]!;
        textColor = Colors.pink[900]!;
        break;
      case 'kid':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        break;
      case 'unisex':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[900]!;
        break;
      default:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.grey[900]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        gender.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
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
              'Error al cargar producto',
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
            PlatformHelper.isIOS
                ? CupertinoButton.filled(
                    onPressed: onRetry,
                    child: const Text('Reintentar'),
                  )
                : ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColorsExtension.darkColors['primary']
                              : AppColorsExtension.lightColors['primary'],
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
