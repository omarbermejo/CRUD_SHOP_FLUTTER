import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImageSelector extends StatefulWidget {
  final List<File> selectedImages;
  final List<String> uploadedImageNames;
  final Function(File) onImageAdded;
  final Function(int) onImageRemoved;
  final Function(int) onUploadedImageRemoved;

  const ProductImageSelector({
    super.key,
    required this.selectedImages,
    required this.uploadedImageNames,
    required this.onImageAdded,
    required this.onImageRemoved,
    required this.onUploadedImageRemoved,
  });

  @override
  State<ProductImageSelector> createState() => _ProductImageSelectorState();
}

class _ProductImageSelectorState extends State<ProductImageSelector> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        widget.onImageAdded(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allImagesCount = widget.selectedImages.length + widget.uploadedImageNames.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imágenes del Producto',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        
        // Botón para agregar imágenes
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Agregar imagen',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toca para tomar foto o seleccionar de la galería',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Mostrar imágenes seleccionadas
        if (allImagesCount > 0) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allImagesCount,
              itemBuilder: (context, index) {
                // Determinar si es una imagen local o subida
                if (index < widget.selectedImages.length) {
                  // Imagen local seleccionada
                  final image = widget.selectedImages[index];
                  return _buildImageThumbnail(
                    image: image,
                    isLocal: true,
                    onRemove: () => widget.onImageRemoved(index),
                  );
                } else {
                  // Imagen ya subida al servidor
                  final uploadedIndex = index - widget.selectedImages.length;
                  final imageName = widget.uploadedImageNames[uploadedIndex];
                  return _buildUploadedImageThumbnail(
                    imageName: imageName,
                    onRemove: () => widget.onUploadedImageRemoved(uploadedIndex),
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageThumbnail({
    required File image,
    required bool isLocal,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image);
                },
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          if (isLocal)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Nueva',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadedImageThumbnail({
    required String imageName,
    required VoidCallback onRemove,
  }) {
    // Construir la URL de la imagen (asumiendo que se almacena el nombre)
    // Esto es solo para mostrar en el selector, la imagen real se mostrará desde el servidor
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 40, color: Colors.grey),
                    const SizedBox(height: 4),
                    Text(
                      imageName.length > 15 
                          ? '${imageName.substring(0, 15)}...' 
                          : imageName,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

