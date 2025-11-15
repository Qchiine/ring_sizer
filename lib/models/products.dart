class Product {
  final String id;
  final String title;
  final String description;
  final int carat;
  final double weight;
  final double price;
  final int stock;
  final String? imageUrl;
  final String sellerId;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.carat,
    required this.weight,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.sellerId,
  });

  // Convertir depuis JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      carat: json['carat'] ?? 18,
      weight: (json['weight'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'],
      sellerId: json['seller'] ?? '',
    );
  }

  // Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'carat': carat,
      'weight': weight,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'seller': sellerId,
    };
  }

  // Créer une copie avec des modifications
  Product copyWith({
    String? id,
    String? title,
    String? description,
    int? carat,
    double? weight,
    double? price,
    int? stock,
    String? imageUrl,
    String? sellerId,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      carat: carat ?? this.carat,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
    );
  }

  // Méthode pour obtenir l'icône selon le type de produit
  String getIcon() {
    if (title.toLowerCase().contains('bague')) return '💍';
    if (title.toLowerCase().contains('bracelet')) return '⌚';
    if (title.toLowerCase().contains('collier')) return '📿';
    if (title.toLowerCase().contains('boucle')) return '💎';
    return '✨';
  }
}