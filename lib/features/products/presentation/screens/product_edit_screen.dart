// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teslo_shop/config/theme/app_theme.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_form_provider.dart';
import 'package:teslo_shop/features/products/presentation/providers/products_providers.dart';
import 'package:teslo_shop/features/products/presentation/screens/my_products_screen.dart';
import 'package:teslo_shop/features/products/presentation/widgets/widgets.dart';
import 'package:teslo_shop/features/shared/shared.dart';

// Los providers y clases están en products_providers.dart

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
        leading: PlatformHelper.isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.pop(),
                child: Icon(
                  CupertinoIcons.back,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsExtension.darkColors['primary']
                      : AppColorsExtension.lightColors['primary'],
                ),
              )
            : null,
        title: const Text('Editar Producto'),
      ),
      body: productAsync.when(
        data: (product) {
          // Cargar los datos del producto en el formulario
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(productFormProvider.notifier).loadProduct(product);
          });

          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.responsivePadding(context,
                basePadding: 20, minPadding: 16, maxPadding: 32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Producto',
                  style: textStyles.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.responsiveFontSize(context,
                        baseSize: 24, minSize: 20, maxSize: 32),
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.responsivePadding(context,
                        basePadding: 30, minPadding: 20, maxPadding: 40)),
                _ProductEditForm(productId: productId),
              ],
            ),
          );
        },
        loading: () {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colors = isDark
              ? AppColorsExtension.darkColors
              : AppColorsExtension.lightColors;
          return Center(
            child: CircularProgressIndicator(
              color: colors['primary'],
            ),
          );
        },
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
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Precio
          CustomTextFormField(
            label: 'Precio',
            hint: 'Ej: 29.99',
            errorMessage: productForm.priceError,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => formNotifier.setPrice(value),
            validator: (value) => productForm.priceError,
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Descripción
          CustomTextFormField(
            label: 'Descripción',
            hint: 'Descripción del producto',
            errorMessage: productForm.descriptionError,
            keyboardType: TextInputType.multiline,
            onChanged: (value) => formNotifier.setDescription(value),
            validator: (value) => productForm.descriptionError,
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Stock
          CustomTextFormField(
            label: 'Stock',
            hint: 'Ej: 50',
            errorMessage: productForm.stockError,
            keyboardType: TextInputType.number,
            onChanged: (value) => formNotifier.setStock(value),
            validator: (value) => productForm.stockError,
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Género
          _GenderSelector(
            selectedGender: productForm.gender,
            error: productForm.genderError,
            onGenderSelected: (gender) => formNotifier.setGender(gender),
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Tallas
          _SizesSelector(
            selectedSizes: productForm.sizes,
            onSizesChanged: (sizes) => formNotifier.setSizes(sizes),
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Tags
          CustomTextFormField(
            label: 'Tags (separados por comas)',
            hint: 'Ej: deportivo, verano, algodón',
            onChanged: (value) => formNotifier.setTagsInput(value),
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 20, minPadding: 16, maxPadding: 24)),

          // Selector de imágenes
          ProductImageSelector(
            selectedImages: productForm.selectedImages,
            uploadedImageNames: productForm.uploadedImageNames,
            onImageAdded: (image) => formNotifier.addSelectedImage(image),
            onImageRemoved: (index) => formNotifier.removeSelectedImage(index),
            onUploadedImageRemoved: (index) =>
                formNotifier.removeUploadedImageName(index),
          ),
          SizedBox(
              height: ResponsiveHelper.responsivePadding(context,
                  basePadding: 30, minPadding: 24, maxPadding: 40)),

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
          final uploadUseCase = ref.read(uploadProductImageUseCaseProvider);
          final imageName = await uploadUseCase(imageFile);
          uploadedImageNames.add(imageName);

          // Agregar el nombre de la imagen subida al estado
          formNotifier.addUploadedImageName(imageName);
        } catch (e) {
          if (context.mounted) {
            if (PlatformHelper.isIOS) {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Advertencia'),
                  content: Text('Error al subir imagen: $e'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            } else {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final colors = isDark
                  ? AppColorsExtension.darkColors
                  : AppColorsExtension.lightColors;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al subir imagen: $e'),
                  backgroundColor: colors['warning'],
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
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
      final updateUseCase = ref.read(updateProductUseCaseProvider);
      final product = await updateUseCase(widget.productId, productData);

      // Crear resultado de éxito
      final result = ProductEditResult.success(product);

      if (result.isSuccess && context.mounted) {
        // Refrescar la lista de productos y el detalle
        ref.invalidate(productsProvider);
        ref.invalidate(myProductsProvider);
        ref.invalidate(productDetailProvider(widget.productId));
        ref.invalidate(productFormProvider); // Resetear el formulario

        // Mostrar mensaje de éxito
        if (PlatformHelper.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Éxito'),
              content: const Text('Producto actualizado exitosamente'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (context.mounted) {
                      context.pop(true);
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colors = isDark
              ? AppColorsExtension.darkColors
              : AppColorsExtension.lightColors;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Producto actualizado exitosamente'),
              backgroundColor: colors['success'],
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          if (context.mounted) {
            context.pop(true);
          }
        }
      } else if (result.error != null && context.mounted) {
        if (PlatformHelper.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Error: ${result.error}'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colors = isDark
              ? AppColorsExtension.darkColors
              : AppColorsExtension.lightColors;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error}'),
              backgroundColor: colors['error'],
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        if (PlatformHelper.isIOS) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Error al actualizar producto: $e'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final colors = isDark
              ? AppColorsExtension.darkColors
              : AppColorsExtension.lightColors;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar producto: $e'),
              backgroundColor: colors['error'],
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Género',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors['text'],
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
              label: Text(
                gender['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors['text'],
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  onGenderSelected(gender['value']!);
                }
              },
              selectedColor: colors['primary'],
              checkmarkColor: Colors.white,
              backgroundColor: colors['surface'],
              side: BorderSide(color: colors['border']!),
            );
          }).toList(),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(
              color: colors['error'],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColorsExtension.darkColors : AppColorsExtension.lightColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tallas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors['text'],
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
              label: Text(
                size,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors['text'],
                ),
              ),
              onSelected: (selected) {
                final newSizes = List<String>.from(widget.selectedSizes);
                if (selected) {
                  newSizes.add(size);
                } else {
                  newSizes.remove(size);
                }
                widget.onSizesChanged(newSizes);
              },
              selectedColor: colors['primary'],
              checkmarkColor: Colors.white,
              backgroundColor: colors['surface'],
              side: BorderSide(color: colors['border']!),
            );
          }).toList(),
        ),
      ],
    );
  }
}
