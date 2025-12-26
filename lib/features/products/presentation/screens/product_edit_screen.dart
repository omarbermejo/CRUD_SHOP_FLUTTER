// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_form_provider.dart';
import 'package:teslo_shop/features/products/presentation/screens/my_products_screen.dart';
import 'package:teslo_shop/features/products/presentation/screens/product_screen_details.dart';
import 'package:teslo_shop/features/products/presentation/screens/products_screen.dart';
import 'package:teslo_shop/features/products/presentation/widgets/widgets.dart';
import 'package:teslo_shop/features/shared/shared.dart';

final productEditProvider =
    FutureProvider.autoDispose.family<ProductEditResult, ProductEditParams>(
  (ref, params) async {
    final datasource = ref.watch(productsDatasourceProvider);
    try {
      final product = await datasource.updateProduct(params.id, params.productData);
      return ProductEditResult.success(product);
    } on AppError catch (e) {
      return ProductEditResult.error(e.message);
    } catch (e) {
      return ProductEditResult.error(e.toString());
    }
  },
);

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

class ProductEditScreen extends ConsumerWidget {
  final String productId;

  const ProductEditScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: productAsync.when(
        data: (product) {
          // Cargar los datos del producto en el formulario
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(productFormProvider.notifier).loadProduct(product);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Producto',
                  style: textStyles.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _ProductEditForm(productId: productId),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(productDetailProvider(productId)),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error al cargar el producto',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ProductEditForm extends ConsumerStatefulWidget {
  final String productId;

  const _ProductEditForm({
    required this.productId,
  });

  @override
  ConsumerState<_ProductEditForm> createState() => _ProductEditFormState();
}

class _ProductEditFormState extends ConsumerState<_ProductEditForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final productForm = ref.watch(productFormProvider);
    final formNotifier = ref.read(productFormProvider.notifier);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          CustomTextFormField(
            label: 'Título',
            hint: 'Ej: Camiseta deportiva',
            errorMessage: productForm.titleError,
            onChanged: (value) => formNotifier.setTitle(value),
            validator: (value) => productForm.titleError,
          ),
          const SizedBox(height: 20),

          // Precio
          CustomTextFormField(
            label: 'Precio',
            hint: 'Ej: 29.99',
            errorMessage: productForm.priceError,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => formNotifier.setPrice(value),
            validator: (value) => productForm.priceError,
          ),
          const SizedBox(height: 20),

          // Descripción
          CustomTextFormField(
            label: 'Descripción',
            hint: 'Descripción del producto',
            errorMessage: productForm.descriptionError,
            keyboardType: TextInputType.multiline,
            onChanged: (value) => formNotifier.setDescription(value),
            validator: (value) => productForm.descriptionError,
          ),
          const SizedBox(height: 20),

          // Stock
          CustomTextFormField(
            label: 'Stock',
            hint: 'Ej: 50',
            errorMessage: productForm.stockError,
            keyboardType: TextInputType.number,
            onChanged: (value) => formNotifier.setStock(value),
            validator: (value) => productForm.stockError,
          ),
          const SizedBox(height: 20),

          // Género
          _GenderSelector(
            selectedGender: productForm.gender,
            error: productForm.genderError,
            onGenderSelected: (gender) => formNotifier.setGender(gender),
          ),
          const SizedBox(height: 20),

          // Tallas
          _SizesSelector(
            selectedSizes: productForm.sizes,
            onSizesChanged: (sizes) => formNotifier.setSizes(sizes),
          ),
          const SizedBox(height: 20),

          // Tags
          CustomTextFormField(
            label: 'Tags (separados por comas)',
            hint: 'Ej: deportivo, verano, algodón',
            onChanged: (value) => formNotifier.setTagsInput(value),
          ),
          const SizedBox(height: 20),

          // Selector de imágenes
          ProductImageSelector(
            selectedImages: productForm.selectedImages,
            uploadedImageNames: productForm.uploadedImageNames,
            onImageAdded: (image) => formNotifier.addSelectedImage(image),
            onImageRemoved: (index) => formNotifier.removeSelectedImage(index),
            onUploadedImageRemoved: (index) => formNotifier.removeUploadedImageName(index),
          ),
          const SizedBox(height: 30),

          // Botón actualizar
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: _isSubmitting ? 'Actualizando...' : 'Actualizar Producto',
              onPressed: _isSubmitting
                  ? null
                  : () => _handleSubmit(context, ref, formNotifier),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    ProductFormNotifier formNotifier,
  ) async {
    if (!formNotifier.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final formState = ref.read(productFormProvider);
      
      // Subir imágenes nuevas primero
      final uploadedImageNames = <String>[];
      for (var imageFile in formState.selectedImages) {
        try {
          final datasource = ref.read(productsDatasourceProvider);
          final imageName = await datasource.uploadProductImage(imageFile);
          uploadedImageNames.add(imageName);
          
          // Agregar el nombre de la imagen subida al estado
          formNotifier.addUploadedImageName(imageName);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir imagen: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
      
      // Combinar imágenes subidas con las que ya estaban
      final allImageNames = [
        ...formState.uploadedImageNames,
        ...uploadedImageNames,
      ];
      
      // Actualizar el estado con todas las imágenes
      final updatedFormState = ProductFormState(
        title: formState.title,
        price: formState.price,
        description: formState.description,
        slug: formState.slug,
        stock: formState.stock,
        sizes: formState.sizes,
        gender: formState.gender,
        tagsInput: formState.tagsInput,
        uploadedImageNames: allImageNames,
      );
      
      // Usar el estado actualizado para actualizar el producto
      final productData = updatedFormState.toMap();
      final params = ProductEditParams(
        id: widget.productId,
        productData: productData,
      );
      final result = await ref.read(productEditProvider(params).future);

      if (result.isSuccess && context.mounted) {
        // Refrescar la lista de productos y el detalle
        ref.invalidate(productsProvider);
        ref.invalidate(myProductsProvider);
        ref.invalidate(productDetailProvider(widget.productId));
        ref.invalidate(productFormProvider); // Resetear el formulario

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Navegar de vuelta
        if (context.mounted) {
          context.pop(true);
        }
      } else if (result.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _GenderSelector extends StatelessWidget {
  final String selectedGender;
  final String? error;
  final Function(String) onGenderSelected;

  const _GenderSelector({
    required this.selectedGender,
    required this.onGenderSelected,
    this.error,
  });

  final List<Map<String, String>> _genders = const [
    {'value': 'men', 'label': 'Hombre'},
    {'value': 'women', 'label': 'Mujer'},
    {'value': 'kid', 'label': 'Niño'},
    {'value': 'unisex', 'label': 'Unisex'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Género',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _genders.map((gender) {
            final isSelected = selectedGender == gender['value'];
            return FilterChip(
              selected: isSelected,
              label: Text(gender['label']!),
              onSelected: (selected) {
                if (selected) {
                  onGenderSelected(gender['value']!);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _SizesSelector extends StatefulWidget {
  final List<String> selectedSizes;
  final Function(List<String>) onSizesChanged;

  const _SizesSelector({
    required this.selectedSizes,
    required this.onSizesChanged,
  });

  @override
  State<_SizesSelector> createState() => _SizesSelectorState();
}

class _SizesSelectorState extends State<_SizesSelector> {
  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tallas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableSizes.map((size) {
            final isSelected = widget.selectedSizes.contains(size);
            return FilterChip(
              selected: isSelected,
              label: Text(size),
              onSelected: (selected) {
                final newSizes = List<String>.from(widget.selectedSizes);
                if (selected) {
                  newSizes.add(size);
                } else {
                  newSizes.remove(size);
                }
                widget.onSizesChanged(newSizes);
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}

