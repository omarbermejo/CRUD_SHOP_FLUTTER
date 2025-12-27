import 'dart:io';
import '../repositories/products_repository.dart';

/// Caso de uso: Subir imagen de producto
class UploadProductImageUseCase {
  final ProductsRepository repository;

  UploadProductImageUseCase(this.repository);

  Future<String> call(File imageFile) {
    return repository.uploadProductImage(imageFile);
  }
}
