import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.read(authServiceProvider));
});

class CurrentUserNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = await _authService.getCurrentUser();
  }

  Future<bool> login(String username, String password) async {
    final user = await _authService.login(username, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  bool hasPermission(String permission) {
    return state?.hasPermission(permission) ?? false;
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<User>>>((ref) {
  return UsersNotifier(ref.read(authServiceProvider));
});

class UsersNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final AuthService _authService;

  UsersNotifier(this._authService) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _authService.getAllUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addUser(User user) async {
    await _authService.addUser(user);
    await loadUsers();
  }

  Future<void> updateUser(User user) async {
    await _authService.updateUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await _authService.deleteUser(id);
    await loadUsers();
  }
}
