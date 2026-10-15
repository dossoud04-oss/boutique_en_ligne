class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Sans nom',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] ?? 0,
      imageUrl: map['image_url'],
      categoryName: map['categories'] != null ? map['categories']['name'] : null,
    );
  }
}
