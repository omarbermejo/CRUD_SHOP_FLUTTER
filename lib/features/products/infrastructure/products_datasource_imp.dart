import 'package:flutter/foundation.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/features/products/domain/datasource/products_datasource.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/shared/infra/http/http_client.dart';

class ProductsDatasourceImp extends ProductsDataSource {
  ApiHttpClient? _httpClient;

  ApiHttpClient get httpClient {
    _httpClient ??= _createHttpClient();
    return _httpClient!;
  }

  ProductsDatasourceImp();

  ApiHttpClient _createHttpClient() {
    try {
      final apiUrl = EnveriomentConfig.apiUrl;
      debugPrint('[ProductsDatasource] Configurando cliente HTTP con baseUrl: $apiUrl');

      final client = ApiHttpClient(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        defaultHeaders: {'Content-Type': 'application/json'},
      );
      debugPrint('[ProductsDatasource] Cliente HTTP configurado correctamente');
      return client;
    } on Exception catch (e) {
      debugPrint('[ProductsDatasource] Error al configurar cliente HTTP: $e');
      rethrow;
    } catch (e) {
      debugPrint('[ProductsDatasource] Error inesperado al configurar cliente HTTP: $e');
      throw Exception('Error al configurar el cliente HTTP: $e');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      debugPrint('[ProductsDatasource] Obteniendo lista de productos');
      final response = await httpClient.get('/products');
      debugPrint('[ProductsDatasource] Productos obtenidos exitosamente');
      
      // El servidor puede devolver una lista directamente o dentro de un objeto 'products'
      List<dynamic> productsList;
      
      // Verificar si la respuesta es directamente una lista
      if (response.containsKey('data') && response['data'] is List) {
        productsList = response['data'] as List<dynamic>;
      } else if (response.containsKey('products') && response['products'] is List) {
        productsList = response['products'] as List<dynamic>;
      } else {
        // Si la respuesta no es un Map con 'data' o 'products', asumimos que es un Map
        // pero necesitamos convertir los valores a lista si es necesario
        productsList = [];
      }

      return productsList
          .map((product) => Product.fromMap(product as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al obtener productos: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      debugPrint('[ProductsDatasource] Obteniendo producto con id: $id');
      final response = await httpClient.get('/products/$id');
      debugPrint('[ProductsDatasource] Producto obtenido exitosamente');
      return Product.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al obtener producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> product) async {
    try {
      debugPrint('[ProductsDatasource] Creando nuevo producto');
      final response = await httpClient.post('/products', body: product);
      debugPrint('[ProductsDatasource] Producto creado exitosamente');
      return Product.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al crear producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      debugPrint('[ProductsDatasource] Actualizando producto con id: $id');
      final response = await httpClient.put('/products/$id', body: product);
      debugPrint('[ProductsDatasource] Producto actualizado exitosamente');
      return Product.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al actualizar producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      debugPrint('[ProductsDatasource] Eliminando producto con id: $id');
      await httpClient.delete('/products/$id');
      debugPrint('[ProductsDatasource] Producto eliminado exitosamente');
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al eliminar producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw Exception(_handleError(e));
    }
  }

  String _handleError(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }
    if (errorString.contains('HttpException: ')) {
      return errorString.replaceFirst('HttpException: ', '');
    }
    return errorString;
  }
}

