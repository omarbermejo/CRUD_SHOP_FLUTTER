import '../repositories/products_repository.dart';

/// Caso de uso: Eliminar producto
class DeleteProductUseCase {
  final ProductsRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(String productId) {
    return repository.deleteProduct(productId);
  }
}
