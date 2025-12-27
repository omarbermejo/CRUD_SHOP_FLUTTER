import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Caso de uso: Obtener todos los productos
class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<Product>> call({int limit = 100, int offset = 0}) {
    return repository.getProducts(limit: limit, offset: offset);
  }
}
