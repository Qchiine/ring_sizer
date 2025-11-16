class Product {
  final String id;
  final String title;
  final String description;
  final int carat;
  final double weight;
  final double price;
  final int stock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.carat,
    required this.weight,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      carat: (json['carat'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  String getIcon() {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('bague') || lowerTitle.contains('ring')) {
      return '💍';
    }
    if (lowerTitle.contains('bracelet')) {
      return '⚗️'; // Vous voudrez peut-être changer cette icône
    }
    return '💎';
  }
}
