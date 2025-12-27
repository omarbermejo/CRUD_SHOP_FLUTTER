import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'
    show StateNotifier, StateNotifierProvider;
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import '../../domain/datasource/products_datasource.dart';

/// Provider del DataSource
final productsDataSourceProvider = Provider<ProductsDataSource>((ref) {
  return ProductsDatasourceImp();
});

/// Provider del Repositorio
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final dataSource = ref.watch(productsDataSourceProvider);
  return ProductsRepositoryImpl(dataSource);
});

/// Providers de Casos de Uso
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return GetProductsUseCase(repository);
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return SearchProductsUseCase(repository);
});

final getProductByIdUseCaseProvider = Provider<GetProductByIdUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return GetProductByIdUseCase(repository);
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return CreateProductUseCase(repository);
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return UpdateProductUseCase(repository);
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return DeleteProductUseCase(repository);
});

final uploadProductImageUseCaseProvider =
    Provider<UploadProductImageUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return UploadProductImageUseCase(repository);
});

/// Providers de datos (usando casos de uso)
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final useCase = ref.watch(getProductsUseCaseProvider);
  return await useCase();
});

/// Provider para el término de búsqueda
final searchTermProvider =
    StateNotifierProvider<SearchTermNotifier, String>((ref) {
  return SearchTermNotifier();
});

class SearchTermNotifier extends StateNotifier<String> {
  SearchTermNotifier() : super('');

  void updateSearchTerm(String term) {
    state = term;
  }

  void clearSearch() {
    state = '';
  }
}

/// Provider para productos buscados (usando caso de uso)
final searchProductsProvider = FutureProvider.autoDispose
    .family<List<Product>, String>((ref, searchTerm) async {
  if (searchTerm.trim().isEmpty) {
    return [];
  }
  final useCase = ref.watch(searchProductsUseCaseProvider);
  return await useCase(searchTerm.trim());
});

/// Provider para detalle de producto (usando caso de uso)
final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, productId) async {
  final useCase = ref.watch(getProductByIdUseCaseProvider);
  return await useCase(productId);
});

/// Provider para crear producto (usando caso de uso)
final productCreateProvider = FutureProvider.autoDispose
    .family<ProductCreateResult, Map<String, dynamic>>(
        (ref, productData) async {
  final useCase = ref.watch(createProductUseCaseProvider);
  try {
    final product = await useCase(productData);
    return ProductCreateResult.success(product);
  } catch (e) {
    return ProductCreateResult.error(e.toString());
  }
});

/// Provider para actualizar producto (usando caso de uso)
final productUpdateProvider = FutureProvider.autoDispose
    .family<ProductEditResult, ProductEditParams>((ref, params) async {
  final useCase = ref.watch(updateProductUseCaseProvider);
  try {
    final product = await useCase(params.id, params.productData);
    return ProductEditResult.success(product);
  } catch (e) {
    return ProductEditResult.error(e.toString());
  }
});

/// Clases auxiliares para resultados
class ProductCreateResult {
  final bool isSuccess;
  final String? error;
  final dynamic product;

  ProductCreateResult.success(this.product)
      : isSuccess = true,
        error = null;

  ProductCreateResult.error(this.error)
      : isSuccess = false,
        product = null;
}

class ProductEditParams {
  final String id;
  final Map<String, dynamic> productData;

  ProductEditParams({
    required this.id,
    required this.productData,
  });
}

class ProductEditResult {
  final bool isSuccess;
  final String? error;
  final dynamic product;

  ProductEditResult.success(this.product)
      : isSuccess = true,
        error = null;

  ProductEditResult.error(this.error)
      : isSuccess = false,
        product = null;
}
