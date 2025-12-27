import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Caso de uso: Actualizar producto
class UpdateProductUseCase {
  final ProductsRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Product> call(String id, Map<String, dynamic> productData) {
    return repository.updateProduct(id, productData);
  }
}
