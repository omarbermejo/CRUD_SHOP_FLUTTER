import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Caso de uso: Crear producto
class CreateProductUseCase {
  final ProductsRepository repository;

  CreateProductUseCase(this.repository);

  Future<Product> call(Map<String, dynamic> productData) {
    return repository.createProduct(productData);
  }
}
