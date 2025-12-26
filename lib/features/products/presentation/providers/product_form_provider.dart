import 'dart:io';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;
import 'package:teslo_shop/features/products/domain/entities/product.dart';

/// Estado del formulario de producto
class ProductFormState {
  final String title;
  final String price;
  final String description;
  final String slug;
  final String stock;
  final List<String> sizes;
  final String gender;
  final String tagsInput; // Input de tags separados por comas
  final List<File> selectedImages; // Imágenes seleccionadas desde el dispositivo
  final List<String> uploadedImageNames; // Nombres de imágenes ya subidas al servidor
  final String? titleError;
  final String? priceError;
  final String? descriptionError;
  final String? stockError;
  final String? genderError;

  const ProductFormState({
    this.title = '',
    this.price = '',
    this.description = '',
    this.slug = '',
    this.stock = '',
    this.sizes = const [],
    this.gender = '',
    this.tagsInput = '',
    this.selectedImages = const [],
    this.uploadedImageNames = const [],
    this.titleError,
    this.priceError,
    this.descriptionError,
    this.stockError,
    this.genderError,
  });

  ProductFormState copyWith({
    String? title,
    String? price,
    String? description,
    String? slug,
    String? stock,
    List<String>? sizes,
    String? gender,
    String? tagsInput,
    List<File>? selectedImages,
    List<String>? uploadedImageNames,
    String? titleError,
    String? priceError,
    String? descriptionError,
    String? stockError,
    String? genderError,
    bool clearTitleError = false,
    bool clearPriceError = false,
    bool clearDescriptionError = false,
    bool clearStockError = false,
    bool clearGenderError = false,
  }) {
    return ProductFormState(
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      stock: stock ?? this.stock,
      sizes: sizes ?? this.sizes,
      gender: gender ?? this.gender,
      tagsInput: tagsInput ?? this.tagsInput,
      selectedImages: selectedImages ?? this.selectedImages,
      uploadedImageNames: uploadedImageNames ?? this.uploadedImageNames,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      priceError: clearPriceError ? null : (priceError ?? this.priceError),
      descriptionError: clearDescriptionError ? null : (descriptionError ?? this.descriptionError),
      stockError: clearStockError ? null : (stockError ?? this.stockError),
      genderError: clearGenderError ? null : (genderError ?? this.genderError),
    );
  }

  /// Convierte el estado a un Map para enviar al backend
  /// Formato esperado por CreateProductDto:
  /// - title: string (required)
  /// - price: number (required)
  /// - description: string (required)
  /// - slug: string (required)
  /// - stock: number (required)
  /// - sizes: array of strings (required)
  /// - gender: string (required)
  /// - tags: array of strings (required)
  /// - images: array of strings (required)
  Map<String, dynamic> toMap() {
    // Generar slug desde el título si no existe
    final generatedSlug = slug.trim().isEmpty 
        ? _generateSlug(title)
        : slug.trim();

    // Parsear tags desde el input
    final tags = tagsInput
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    // Convertir price a número
    final priceValue = double.tryParse(price.trim()) ?? 0.0;
    
    // Convertir stock a número entero
    final stockValue = int.tryParse(stock.trim()) ?? 0;

    return {
      'title': title.trim(),
      'price': priceValue,
      'description': description.trim(),
      'slug': generatedSlug,
      'stock': stockValue,
      'sizes': sizes,
      'gender': gender.trim(),
      'tags': tags,
      'images': List<String>.from(uploadedImageNames), // Imágenes ya subidas al servidor
    };
  }

  /// Genera un slug desde el título
  String _generateSlug(String title) {
    if (title.isEmpty) return '';
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// Obtiene la lista de tags parseados
  List<String> get tags => tagsInput
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  ProductFormNotifier() : super(const ProductFormState());

  void setTitle(String title) {
    final newSlug = _generateSlug(title);
    state = state.copyWith(
      title: title,
      slug: newSlug,
      clearTitleError: true,
    );
  }

  void setPrice(String price) {
    state = state.copyWith(
      price: price,
      clearPriceError: true,
    );
  }

  void setDescription(String description) {
    state = state.copyWith(
      description: description,
      clearDescriptionError: true,
    );
  }

  void setSlug(String slug) {
    state = state.copyWith(slug: slug);
  }

  void setStock(String stock) {
    state = state.copyWith(
      stock: stock,
      clearStockError: true,
    );
  }

  void setSizes(List<String> sizes) {
    state = state.copyWith(sizes: sizes);
  }

  void setGender(String gender) {
    state = state.copyWith(
      gender: gender,
      clearGenderError: true,
    );
  }

  void setTagsInput(String tagsInput) {
    state = state.copyWith(tagsInput: tagsInput);
  }

  void addSelectedImage(File image) {
    final updatedImages = List<File>.from(state.selectedImages)..add(image);
    state = state.copyWith(selectedImages: updatedImages);
  }

  void removeSelectedImage(int index) {
    final updatedImages = List<File>.from(state.selectedImages)..removeAt(index);
    state = state.copyWith(selectedImages: updatedImages);
  }

  void addUploadedImageName(String imageName) {
    final updatedNames = List<String>.from(state.uploadedImageNames)..add(imageName);
    state = state.copyWith(uploadedImageNames: updatedNames);
  }

  void removeUploadedImageName(int index) {
    final updatedNames = List<String>.from(state.uploadedImageNames)..removeAt(index);
    state = state.copyWith(uploadedImageNames: updatedNames);
  }

  void reset() {
    state = const ProductFormState();
  }

  /// Carga los datos de un producto existente en el formulario
  void loadProduct(Product product) {
    state = ProductFormState(
      title: product.title,
      price: product.price.toString(),
      description: product.description,
      slug: product.slug,
      stock: product.stock.toString(),
      sizes: List<String>.from(product.sizes),
      gender: product.gender,
      tagsInput: product.tags.join(', '),
      uploadedImageNames: List<String>.from(product.images),
    );
  }

  bool validate() {
    String? titleError;
    String? priceError;
    String? descriptionError;
    String? stockError;
    String? genderError;

    if (state.title.isEmpty) {
      titleError = 'El título es obligatorio';
    }

    final priceValue = double.tryParse(state.price);
    if (state.price.isEmpty) {
      priceError = 'El precio es obligatorio';
    } else if (priceValue == null || priceValue <= 0) {
      priceError = 'El precio debe ser un número mayor a 0';
    }

    if (state.description.isEmpty) {
      descriptionError = 'La descripción es obligatoria';
    }

    final stockValue = int.tryParse(state.stock);
    if (state.stock.isEmpty) {
      stockError = 'El stock es obligatorio';
    } else if (stockValue == null || stockValue < 0) {
      stockError = 'El stock debe ser un número mayor o igual a 0';
    }

    if (state.gender.isEmpty) {
      genderError = 'Debes seleccionar un género';
    }

    state = state.copyWith(
      titleError: titleError,
      priceError: priceError,
      descriptionError: descriptionError,
      stockError: stockError,
      genderError: genderError,
    );

    return titleError == null &&
        priceError == null &&
        descriptionError == null &&
        stockError == null &&
        genderError == null;
  }

  String _generateSlug(String title) {
    if (title.isEmpty) return '';
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }
}

final productFormProvider =
    StateNotifierProvider<ProductFormNotifier, ProductFormState>((ref) {
  return ProductFormNotifier();
});

