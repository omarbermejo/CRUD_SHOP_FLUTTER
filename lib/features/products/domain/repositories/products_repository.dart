import 'dart:io';
import '../entities/product.dart';

/// Repositorio de productos - Interfaz en Domain Layer
/// Define los contratos para operaciones con productos
abstract class ProductsRepository {
  /// Obtiene todos los productos
  Future<List<Product>> getProducts({int limit = 100, int offset = 0});

  /// Busca productos por término
  Future<List<Product>> searchProducts(String term);

  /// Obtiene un producto por ID
  Future<Product> getProductById(String id);

  /// Crea un nuevo producto
  Future<Product> createProduct(Map<String, dynamic> productData);

  /// Actualiza un producto existente
  Future<Product> updateProduct(String id, Map<String, dynamic> productData);

  /// Elimina un producto
  Future<void> deleteProduct(String id);

  /// Sube una imagen de producto
  Future<String> uploadProductImage(File imageFile);
}
