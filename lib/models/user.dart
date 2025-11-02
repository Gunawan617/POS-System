import 'base_model.dart';

enum UserRole {
  admin,
  kasir,
  barista,
}

class User extends BaseModel {
  String username;
  String password;
  String name;
  UserRole role;
  bool isActive;

  User({
    super.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.isActive = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'role': role.name,
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.kasir,
      ),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  bool hasPermission(String permission) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin bisa semua
      case UserRole.kasir:
        return ['cashier', 'view_transactions', 'view_reports'].contains(permission);
      case UserRole.barista:
        return ['barista', 'view_products'].contains(permission);
    }
  }
}
