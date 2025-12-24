// lib/models/product.dart
class Product {
  final String name;
  final String imagePath;
  final double price;
  final bool isFavorite;

  // ✅ TAMBAHAN (FIX ERROR)
  final String description;

  Product({
    required this.name,
    required this.imagePath,
    required this.price,
    this.isFavorite = false,
    this.description = '', // default aman
  });
}
