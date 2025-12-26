import 'package:flutter/material.dart';
import 'package:teslo_shop/config/const/env.dart';
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
      // Si imageName ya es una URL completa, retornarla tal cual
      if (imageName.startsWith('http://') || imageName.startsWith('https://')) {
        return imageName;
      }
   
      return '$baseUrl/files/product/$imageName';
    } catch (e) {
      // Si hay error al obtener la baseUrl, retornar la imagen tal cual
      return imageName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            _ProductImage(
              images: product.images,
              buildImageUrl: _buildImageUrl,
            ),
            
            // Información del producto
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y género
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: textStyles.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _GenderChip(gender: product.gender),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Precio
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Stock y tallas
                    Row(
                      children: [
                        _StockBadge(stock: product.stock),
                        const SizedBox(width: 8),
                        if (product.sizes.isNotEmpty)
                          Expanded(
                            child: Text(
                              'Tallas: ${product.sizes.join(', ')}',
                              style: textStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 100,
                      child: Text(
                        product.description,
                        style: textStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ), 
                    
                  ],
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
    final imageName = images.isNotEmpty ? images.first : null;
    final imageUrl = imageName != null ? buildImageUrl(imageName) : null;
    
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey[200],
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          : const Center(
              child: Icon(Icons.image, size: 64, color: Colors.grey),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        gender.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
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
    final isLowStock = stock < 10;
    final isOutOfStock = stock == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? Colors.red[100]
            : isLowStock
                ? Colors.orange[100]
                : Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOutOfStock
            ? 'SIN STOCK'
            : 'Stock: $stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isOutOfStock
              ? Colors.red[900]
              : isLowStock
                  ? Colors.orange[900]
                  : Colors.green[900],
        ),
      ),
    );
  }
}

