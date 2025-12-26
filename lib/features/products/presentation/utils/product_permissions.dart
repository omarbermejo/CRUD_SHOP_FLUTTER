import 'package:teslo_shop/features/auth/domain/entitis/users.dart';
import 'package:teslo_shop/features/products/domain/entities/product.dart';

/// Verifica si el usuario actual puede editar un producto
/// 
/// Un usuario puede editar un producto si:
/// - Es el propietario del producto (product.userId == currentUser.id)
/// - O tiene rol de administrador (currentUser.isAdmin)
bool canEditProduct(Product product, Users? currentUser) {
  if (currentUser == null) {
    return false;
  }

  // Si es admin, puede editar cualquier producto
  if (currentUser.isAdmin) {
    return true;
  }

  // Si no es admin, solo puede editar sus propios productos
  if (product.userId != null) {
    final productUserId = product.userId!.trim();
    final currentUserId = currentUser.id.trim();
    return productUserId == currentUserId;
  }

  return false;
}

