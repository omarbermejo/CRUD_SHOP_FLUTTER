class Product {
  final String id;
  final String title;
  final double price;
  final String description;
  final String slug;
  final int stock;
  final List<String> sizes;
  final String gender;
  final List<String> tags;
  final List<String> images;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.slug,
    required this.stock,
    required this.sizes,
    required this.gender,
    required this.tags,
    required this.images,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      price: (map['price'] is int) 
          ? (map['price'] as int).toDouble() 
          : (map['price'] as num?)?.toDouble() ?? 0.0,
      description: map['description']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      stock: map['stock'] is int 
          ? map['stock'] as int 
          : (map['stock'] as num?)?.toInt() ?? 0,
      sizes: List<String>.from(map['sizes'] ?? []),
      gender: map['gender']?.toString() ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      userId: map['userId']?.toString(),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'slug': slug,
      'stock': stock,
      'sizes': sizes,
      'gender': gender,
      'tags': tags,
      'images': images,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? title,
    double? price,
    String? description,
    String? slug,
    int? stock,
    List<String>? sizes,
    String? gender,
    List<String>? tags,
    List<String>? images,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      stock: stock ?? this.stock,
      sizes: sizes ?? this.sizes,
      gender: gender ?? this.gender,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

