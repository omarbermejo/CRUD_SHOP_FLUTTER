import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Caso de uso: Obtener producto por ID
class GetProductByIdUseCase {
  final ProductsRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<Product> call(String productId) {
    return repository.getProductById(productId);
  }
}
