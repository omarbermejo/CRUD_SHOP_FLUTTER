import 'package:flutter/material.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Hero(
      tag: 'product_${product.id}',
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: colors['card'],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors['border']!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del producto
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          _ProductImage(
                            images: product.images,
                            buildImageUrl: _buildImageUrl,
                          ),
                          // Badge de género en la esquina superior
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _GenderChip(gender: product.gender),
                          ),
                        ],
                      ),
                    ),

                    // Información del producto
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.responsivePadding(context,
                                basePadding: 12,
                                minPadding: 10,
                                maxPadding: 16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Título
                            Text(
                              product.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize:
                                        ResponsiveHelper.responsiveFontSize(
                                            context,
                                            baseSize: 16,
                                            minSize: 14,
                                            maxSize: 18),
                                    fontWeight: FontWeight.w600,
                                    color: colors['text'],
                                    height: 1.3,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Precio
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.responsiveFontSize(
                                    context,
                                    baseSize: 20,
                                    minSize: 18,
                                    maxSize: 24),
                                fontWeight: FontWeight.bold,
                                color: colors['primary'],
                              ),
                            ),

                            const Spacer(),

                            // Stock y tallas
                            Row(
                              children: [
                                _StockBadge(stock: product.stock),
                                const SizedBox(width: 8),
                                if (product.sizes.isNotEmpty)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colors['background'],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Tallas: ${product.sizes.join(', ')}',
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper
                                              .responsiveFontSize(context,
                                                  baseSize: 11,
                                                  minSize: 9,
                                                  maxSize: 13),
                                          color: colors['textSecondary'],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Descripción
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.responsiveFontSize(
                                    context,
                                    baseSize: 12,
                                    minSize: 10,
                                    maxSize: 14),
                                color: colors['textSecondary'],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botón de ayuda en la esquina inferior derecha
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  // TODO: Mostrar información del producto o ayuda
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors['primary'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final List<String> images;
  final String Function(String) buildImageUrl;

  const _ProductImage({
    required this.images,
    required this.buildImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;
    final imageName = images.isNotEmpty ? images.first : null;
    final imageUrl = imageName != null ? buildImageUrl(imageName) : null;

    final imageHeight = ResponsiveHelper.responsivePadding(context,
        basePadding: 180, minPadding: 150, maxPadding: 220);

    return Container(
      width: double.infinity,
      height: imageHeight,
      color: colors['background'],
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: colors['background'],
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: colors['textSecondary'],
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: colors['background'],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: colors['primary'],
                    ),
                  ),
                );
              },
            )
          : Container(
              color: colors['background'],
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: colors['textSecondary'],
                ),
              ),
            ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String gender;

  const _GenderChip({required this.gender});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    Color backgroundColor;
    Color textColor;

    switch (gender.toLowerCase()) {
      case 'men':
        backgroundColor = const Color(0xFFB3D9FF); // Azul pastel
        textColor = const Color(0xFF1E88E5);
        break;
      case 'women':
        backgroundColor = const Color(0xFFFFB3D9); // Rosa pastel
        textColor = const Color(0xFFE91E63);
        break;
      case 'kid':
        backgroundColor = const Color(0xFFFFE0B3); // Naranja pastel
        textColor = const Color(0xFFF57C00);
        break;
      case 'unisex':
        backgroundColor = const Color(0xFFE1BEE7); // Morado pastel
        textColor = const Color(0xFF9C27B0);
        break;
      default:
        backgroundColor = colors['background']!;
        textColor = colors['textSecondary']!;
    }

    if (isDark) {
      // Ajustar colores para dark mode
      switch (gender.toLowerCase()) {
        case 'men':
          backgroundColor = const Color(0xFF1E3A5F);
          textColor = const Color(0xFF64B5F6);
          break;
        case 'women':
          backgroundColor = const Color(0xFF4A1E3A);
          textColor = const Color(0xFFF48FB1);
          break;
        case 'kid':
          backgroundColor = const Color(0xFF4A3A1E);
          textColor = const Color(0xFFFFB74D);
          break;
        case 'unisex':
          backgroundColor = const Color(0xFF3A1E4A);
          textColor = const Color(0xFFBA68C8);
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        gender.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLowStock = stock < 10;
    final isOutOfStock = stock == 0;

    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    if (isOutOfStock) {
      backgroundColor =
          isDark ? const Color(0xFF4A1E1E) : const Color(0xFFFFE5E5);
      textColor = isDark ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F);
      text = 'SIN STOCK';
      icon = Icons.cancel_outlined;
    } else if (isLowStock) {
      backgroundColor =
          isDark ? const Color(0xFF4A3A1E) : const Color(0xFFFFF4E5);
      textColor = isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00);
      text = 'Stock: $stock';
      icon = Icons.warning_amber_rounded;
    } else {
      backgroundColor =
          isDark ? const Color(0xFF1E4A2E) : const Color(0xFFE5F5E5);
      textColor = isDark ? const Color(0xFF81C784) : const Color(0xFF388E3C);
      text = 'Stock: $stock';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
