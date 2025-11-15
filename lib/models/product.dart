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
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      carat: json['carat'],
      weight: (json['weight'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      imageUrl: json['imageUrl'],
    );
  }

  String getIcon() {
    if (title.toLowerCase().contains('bague') || title.toLowerCase().contains('ring')) {
      return '💍';
    }
    if (title.toLowerCase().contains('bracelet')) {
      return '⚗️';
    }
    return '💎';
  }
}
