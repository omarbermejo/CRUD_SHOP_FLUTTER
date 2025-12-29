import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:teslo_shop/config/const/env.dart';
import 'package:teslo_shop/features/auth/infretuction/token_storage.dart';
import 'package:teslo_shop/features/products/domain/datasource/products_datasource.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';
import 'package:teslo_shop/features/shared/errors/errors.dart';
import 'package:teslo_shop/features/shared/infra/http/http_client.dart';

class ProductsDatasourceImp extends ProductsDataSource {
  ApiHttpClient? _httpClient;
  final TokenStorage _tokenStorage = TokenStorage();

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

  /// Obtiene los headers con el token de autenticación
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenStorage.getToken();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('[ProductsDatasource] Token de autenticación agregado a headers');
    } else {
      debugPrint('[ProductsDatasource] Advertencia: No se encontró token de autenticación');
    }
    return headers;
  }

  /// Normaliza los datos del producto para Product.fromMap
  /// Extrae userId del objeto user si existe
  Map<String, dynamic> _normalizeProductData(Map<String, dynamic> productData) {
    final normalized = Map<String, dynamic>.from(productData);
    
    // Extraer userId del objeto user si existe
    if (normalized.containsKey('user') && normalized['user'] is Map) {
      final userMap = normalized['user'] as Map<String, dynamic>;
      if (userMap.containsKey('id')) {
        normalized['userId'] = userMap['id'].toString();
        debugPrint('[ProductsDatasource] userId extraído del objeto user: ${normalized['userId']}');
      }
    }
    
    return normalized;
  }


  /// Parsea la respuesta de productos de diferentes formatos
  List<Product> _parseProductsResponse(Map<String, dynamic> response) {
    List<dynamic> productsList = [];
    
    if (response.containsKey('data') && response['data'] is List) {
      productsList = response['data'] as List<dynamic>;
      debugPrint('[ProductsDatasource] Productos encontrados en response.data: ${productsList.length} elementos');
    } else if (response.containsKey('products') && response['products'] is List) {
      productsList = response['products'] as List<dynamic>;
      debugPrint('[ProductsDatasource] Productos encontrados en response.products: ${productsList.length} elementos');
    } else {
      for (var key in response.keys) {
        if (response[key] is List) {
          productsList = response[key] as List<dynamic>;
          debugPrint('[ProductsDatasource] Productos encontrados en response.$key: ${productsList.length} elementos');
          break;
        }
      }
    }

    return productsList
        .map((product) {
          try {
            final productMap = product as Map<String, dynamic>;
         
            final normalized = _normalizeProductData(productMap);
            final parsedProduct = Product.fromMap(normalized);
            
          
            return parsedProduct;
          } catch (e, stackTrace) {
            debugPrint('[ProductsDatasource] Error al parsear producto: $e');
            debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
            rethrow;
          }
        })
        .toList();
  }

  @override
  Future<List<Product>> getProducts({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      debugPrint('[ProductsDatasource] Obteniendo lista de productos desde /products');
      debugPrint('[ProductsDatasource] Parámetros: limit=$limit, offset=$offset');
      final headers = await _getAuthHeaders();
      debugPrint('[ProductsDatasource] Headers enviados: ${headers.keys}');
      
      // El endpoint GET /api/products requiere limit y offset como query parameters
      final response = await httpClient.get(
        '/products',
        headers: headers,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      
      debugPrint('[ProductsDatasource] Respuesta recibida - Tipo: ${response.runtimeType}');
      debugPrint('[ProductsDatasource] Respuesta completa: $response');
      debugPrint('[ProductsDatasource] Respuesta keys: ${response.keys}');
      
      final products = _parseProductsResponse(response);
      
      debugPrint('[ProductsDatasource] Total de productos parseados: ${products.length}');
      
      // Debug: mostrar resumen de userIds encontrados
      final userIds = products.map((p) => p.userId).where((id) => id != null).toSet();
      debugPrint('[ProductsDatasource] UserIds únicos encontrados en productos: $userIds');
      
      if (products.isEmpty) {
        debugPrint('[ProductsDatasource] ADVERTENCIA: El endpoint /products devolvió 0 productos');
        
      }
      
      return products;
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al obtener productos: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al obtener productos: ${e.toString()}',
        code: 'GET_PRODUCTS_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Product>> searchProducts(String term) async {
    try {
      debugPrint('[ProductsDatasource] Buscando productos con término: $term');
      final headers = await _getAuthHeaders();
      
      // El endpoint GET /api/products/all/{term} busca productos por término
      final encodedTerm = Uri.encodeComponent(term);
      final response = await httpClient.get('/products/all/$encodedTerm', headers: headers);
      
      debugPrint('[ProductsDatasource] Búsqueda exitosa');
      return _parseProductsResponse(response);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al buscar productos: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al buscar productos: ${e.toString()}',
        code: 'SEARCH_PRODUCTS_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      debugPrint('[ProductsDatasource] Obteniendo producto con id: $id');
      final headers = await _getAuthHeaders();
      final response = await httpClient.get('/products/$id', headers: headers);
      debugPrint('[ProductsDatasource] Producto obtenido exitosamente');
      
      // Normalizar la respuesta para Product.fromMap
      Map<String, dynamic> productData = response;
      if (response.containsKey('data') && response['data'] is Map) {
        productData = response['data'] as Map<String, dynamic>;
      }
      
      final normalized = _normalizeProductData(productData);
      return Product.fromMap(normalized);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al obtener producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al obtener producto: ${e.toString()}',
        code: 'GET_PRODUCT_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> product) async {
    try {
      debugPrint('[ProductsDatasource] Creando nuevo producto');
      final headers = await _getAuthHeaders();
      final response = await httpClient.post('/products', body: product, headers: headers);
      debugPrint('[ProductsDatasource] Producto creado exitosamente');
      
      // Normalizar la respuesta para Product.fromMap
      // El servidor puede devolver el producto directamente o dentro de un objeto 'data'
      Map<String, dynamic> productData = response;
      if (response.containsKey('data') && response['data'] is Map) {
        productData = response['data'] as Map<String, dynamic>;
      }

      final normalized = _normalizeProductData(productData);
      
      return Product.fromMap(normalized);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al crear producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al crear producto: ${e.toString()}',
        code: 'CREATE_PRODUCT_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      debugPrint('[ProductsDatasource] Actualizando producto con id: $id');
      final headers = await _getAuthHeaders();
      // La API usa PATCH 
      final response = await httpClient.patch('/products/$id', body: product, headers: headers);
      debugPrint('[ProductsDatasource] Producto actualizado exitosamente');
      
      // Normalizar la respuesta para Product.fromMap
      Map<String, dynamic> productData = response;
      if (response.containsKey('data') && response['data'] is Map) {
        productData = response['data'] as Map<String, dynamic>;
      }
      
      final normalized = _normalizeProductData(productData);
      return Product.fromMap(normalized);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al actualizar producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al actualizar producto: ${e.toString()}',
        code: 'UPDATE_PRODUCT_ERROR',
        originalError: e,
      );
    }
  }

  /// Sube una imagen al servidor
  /// Retorna el nombre del archivo subido
  @override
  Future<String> uploadProductImage(File imageFile) async {
    try {
      debugPrint('[ProductsDatasource] Subiendo imagen: ${imageFile.path}');
      final headers = await _getAuthHeaders();
      
      final response = await httpClient.uploadFile(
        '/files/product',
        imageFile,
        headers: headers,
        fieldName: 'file',
      );
      
      debugPrint('[ProductsDatasource] Imagen subida exitosamente. Respuesta: $response');
      
      // El servidor debería devolver el nombre del archivo en la respuesta
      // Según la documentación, el endpoint POST /api/files/product devuelve el nombre del archivo
      if (response.containsKey('image')) {
        return response['image'] as String;
      } else if (response.containsKey('filename')) {
        return response['filename'] as String;
      } else if (response.containsKey('file')) {
        return response['file'] as String;
      } else if (response.containsKey('name')) {
        return response['name'] as String;
      } else if (response.containsKey('images')) {
        return response['images'] as String;
      } else {
        // Si no hay nombre en la respuesta, usar el nombre del archivo original
        final fileName = imageFile.path.split(Platform.pathSeparator).last;
        debugPrint('[ProductsDatasource] No se encontró nombre en la respuesta, usando: $fileName');
        return fileName;
      }
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al subir imagen: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al subir imagen: ${e.toString()}',
        code: 'UPLOAD_IMAGE_ERROR',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      debugPrint('[ProductsDatasource] Eliminando producto con id: $id');
      final headers = await _getAuthHeaders();
      await httpClient.delete('/products/$id', headers: headers);
      debugPrint('[ProductsDatasource] Producto eliminado exitosamente');
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ProductsDatasource] Error al eliminar producto: $e');
      debugPrint('[ProductsDatasource] StackTrace: $stackTrace');
      throw NetworkError(
        message: 'Error inesperado al eliminar producto: ${e.toString()}',
        code: 'DELETE_PRODUCT_ERROR',
        originalError: e,
      );
    }
  }
}

