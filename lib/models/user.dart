class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? shopName;
  final String? description;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shopName,
    this.description,
  });

  // Convertir depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'seller',
      shopName: json['shopName'],
      description: json['description'],
    );
  }

  // Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'shopName': shopName,
      'description': description,
    };
  }

  // Créer une copie avec des modifications
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? shopName,
    String? description,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
    );
  }
}
  final String userId;
  final String name;
  final String email;
  final String role;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'] ?? json['userId'], // MongoDB utilise _id
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Utilisateur',
    );
  }
}
