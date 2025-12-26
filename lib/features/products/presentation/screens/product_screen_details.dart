import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/products/presentation/screens/products_screen.dart';

final productDetailProvider = FutureProvider.family<Product, String>((ref, productId) async {
  final datasource = ref.watch(productsDatasourceProvider);
  return await datasource.getProductById(productId);
});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
      ),
      body: productAsync.when(
        data: (product) => _ProductDetailView(
          product: product,
          buildImageUrl: _buildImageUrl,
          textStyles: textStyles,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(productDetailProvider(productId)),
        ),
      ),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final Product product;
  final String Function(String) buildImageUrl;
  final TextTheme textStyles;

  const _ProductDetailView({
    required this.product,
    required this.buildImageUrl,
    required this.textStyles,
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
    final colorScheme = Theme.of(context).colorScheme;

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
            padding: const EdgeInsets.all(16),
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
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 16),

                // Precio
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: textStyles.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
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
                  colorScheme: colorScheme,
                ),

                const SizedBox(height: 32),

                // Botones de acción
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar agregar al carrito
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Agregar al Carrito'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
    if (widget.images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 400,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 100, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Carousel de imágenes principales
        SizedBox(
          width: double.infinity,
          height: 400,
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
                color: Colors.grey[100],
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
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
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),

        // Thumbnails
        if (widget.images.length > 1)
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300]!,
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
                          return const Icon(Icons.broken_image);
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
  final ColorScheme colorScheme;

  const _ProductInfoSection({
    required this.product,
    required this.textStyles,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          label: 'Stock disponible',
          value: product.stock.toString(),
          color: product.stock > 10
              ? Colors.green
              : product.stock > 0
                  ? Colors.orange
                  : Colors.red,
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
                labelStyle: const TextStyle(fontSize: 12),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar producto',
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
