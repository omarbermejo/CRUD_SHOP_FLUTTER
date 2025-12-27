import 'dart:io';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/datasource/products_datasource.dart';

/// Implementación del repositorio de productos
/// Esta clase implementa ProductsRepository y usa el DataSource para obtener datos
/// En Clean Architecture, el repositorio actúa como intermediario entre los casos de uso
/// y las fuentes de datos (DataSource)
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDataSource _dataSource;

  ProductsRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts({int limit = 100, int offset = 0}) async {
    try {
      // El datasource ya retorna List<Product>, solo lo pasamos
      return await _dataSource.getProducts(limit: limit, offset: offset);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(String term) async {
    try {
      // El datasource ya retorna List<Product>, solo lo pasamos
      return await _dataSource.searchProducts(term);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      // El datasource ya retorna Product, solo lo pasamos
      return await _dataSource.getProductById(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      // El datasource ya retorna Product, solo lo pasamos
      return await _dataSource.createProduct(productData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(
      String id, Map<String, dynamic> productData) async {
    try {
      // El datasource ya retorna Product, solo lo pasamos
      return await _dataSource.updateProduct(id, productData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _dataSource.deleteProduct(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadProductImage(File imageFile) async {
    try {
      return await _dataSource.uploadProductImage(imageFile);
    } catch (e) {
      rethrow;
    }
  }
}
