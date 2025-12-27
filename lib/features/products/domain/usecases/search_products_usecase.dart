import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Caso de uso: Buscar productos
class SearchProductsUseCase {
  final ProductsRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<Product>> call(String searchTerm) {
    if (searchTerm.trim().isEmpty) {
      return Future.value([]);
    }
    return repository.searchProducts(searchTerm.trim());
  }
}
