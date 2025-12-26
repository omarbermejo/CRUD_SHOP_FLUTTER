// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_form_provider.dart';
import 'package:teslo_shop/features/products/presentation/screens/my_products_screen.dart';
import 'package:teslo_shop/features/products/presentation/screens/products_screen.dart';
import 'package:teslo_shop/features/products/presentation/widgets/widgets.dart';
import 'package:teslo_shop/features/shared/shared.dart';

final productCreateProvider =
    FutureProvider.autoDispose.family<ProductCreateResult, Map<String, dynamic>>(
  (ref, productData) async {
    final datasource = ref.watch(productsDatasourceProvider);
    try {
      final product = await datasource.createProduct(productData);
      return ProductCreateResult.success(product);
    } on AppError catch (e) {
      // Capturar errores específicos de la aplicación
      return ProductCreateResult.error(e.message);
    } catch (e) {
      // Capturar otros errores
      return ProductCreateResult.error(e.toString());
    }
  },
);

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

class ProductCreateScreen extends ConsumerWidget {
  const ProductCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuevo Producto',
              style: textStyles.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const _ProductForm(),
          ],
        ),
      ),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm();

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
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

          // Botón crear
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              text: _isSubmitting ? 'Creando...' : 'Crear Producto',
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
      final productData = ref.read(productFormProvider).toMap();
      final result = await ref.read(
        productCreateProvider(productData).future,
      );

      if (result.isSuccess && context.mounted) {
        // Refrescar la lista de productos
        ref.invalidate(productsProvider);
        ref.invalidate(myProductsProvider);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Navegar de vuelta
        if (context.mounted) {
          context.pop(true); // Retornar true para indicar éxito
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
            content: Text('Error al crear producto: $e'),
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

