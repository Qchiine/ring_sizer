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
      role: json['role'] ?? 'buyer', // Le rôle par défaut est acheteur
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
}
