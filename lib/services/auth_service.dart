import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String usersKey = 'users';
  static const String currentUserKey = 'current_user';
  
  final _storage = const FlutterSecureStorage();

  Future<void> _init() async {
    if (await _storage.read(key: usersKey) == null) {
      // Create default admin user
      final defaultAdmin = User(
        username: 'admin',
        password: 'admin123',
        name: 'Administrator',
        role: UserRole.admin,
      );
      
      await _storage.write(key: usersKey, value: jsonEncode([defaultAdmin.toJson()]));
    }
  }

  Future<User?> login(String username, String password) async {
    await _init();
    final data = await _storage.read(key: usersKey);
    final List<dynamic> users = jsonDecode(data ?? '[]');
    
    try {
      final userJson = users.cast<Map<String, dynamic>>().firstWhere(
        (u) => u['username'] == username && u['password'] == password && u['isActive'] == true,
      );
      
      final user = User.fromJson(userJson);
      await _storage.write(key: currentUserKey, value: jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    final data = await _storage.read(key: currentUserKey);
    if (data == null) return null;
    
    try {
      return User.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<List<User>> getAllUsers() async {
    await _init();
    final data = await _storage.read(key: usersKey);
    final List<dynamic> users = jsonDecode(data ?? '[]');
    return users.cast<Map<String, dynamic>>().map((json) => User.fromJson(json)).toList();
  }

  Future<int> addUser(User user) async {
    await _init();
    final data = await _storage.read(key: usersKey);
    final List<dynamic> users = jsonDecode(data ?? '[]');
    
    // Find max ID to avoid conflicts
    int maxId = 0;
    for (var u in users) {
      if (u is Map<String, dynamic> && u['id'] != null) {
        final userId = u['id'] as int;
        if (userId > maxId) maxId = userId;
      }
    }
    final int id = maxId + 1;
    
    user.id = id;
    users.add(user.toJson());
    await _storage.write(key: usersKey, value: jsonEncode(users));
    return id;
  }

  Future<void> updateUser(User user) async {
    if (user.id == null) throw Exception('User ID cannot be null');
    
    await _init();
    final data = await _storage.read(key: usersKey);
    final List<dynamic> users = jsonDecode(data ?? '[]');
    final int index = users.indexWhere((u) => u['id'] == user.id);
    if (index != -1) {
      users[index] = user.toJson();
      await _storage.write(key: usersKey, value: jsonEncode(users));
    }
  }

  Future<void> deleteUser(int id) async {
    await _init();
    final data = await _storage.read(key: usersKey);
    final List<dynamic> users = jsonDecode(data ?? '[]');
    users.removeWhere((u) => u['id'] == id);
    await _storage.write(key: usersKey, value: jsonEncode(users));
  }
}
