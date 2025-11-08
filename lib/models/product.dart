class Product {
  final String productId;
  final String title;
  final String description;
  final int carat;
  final double weight;
  final double price;
  final int stock;
  final String imageUrl;

  Product({
    required this.productId,
    required this.title,
    required this.description,
    required this.carat,
    required this.weight,
    required this.price,
    required this.stock,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['_id'] ?? json['productId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      carat: (json['carat'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
