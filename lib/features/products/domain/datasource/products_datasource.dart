import 'package:teslo_shop/features/products/domain/entities/product.dart';

abstract class ProductsDataSource {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(String id);
  Future<Product> createProduct(Map<String, dynamic> product);
  Future<Product> updateProduct(String id, Map<String, dynamic> product);
  Future<void> deleteProduct(String id);
}

