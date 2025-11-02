import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'cashier_screen.dart';
import 'barista_screen.dart';
import 'products_screen.dart';
import 'transactions_screen.dart';
import 'reports_screen.dart';
import 'users_screen.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return const LoginScreen();
    }

    final screens = _getScreensForRole(currentUser.role);
    final destinations = _getDestinationsForRole(currentUser.role);

    return Scaffold(
      appBar: AppBar(
        title: Text('POS Warkop - ${currentUser.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Chip(
            avatar: Icon(
              _getRoleIcon(currentUser.role),
              size: 16,
            ),
            label: Text(
              _getRoleLabel(currentUser.role),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await ref.read(currentUserProvider.notifier).logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }

  List<Widget> _getScreensForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          const CashierScreen(),
          const ProductsScreen(),
          const TransactionsScreen(),
          const ReportsScreen(),
          const UsersScreen(),
        ];
      case UserRole.kasir:
        return [
          const CashierScreen(),
          const ProductsScreen(),
          const TransactionsScreen(),
          const ReportsScreen(),
        ];
      case UserRole.barista:
        return [
          const BaristaScreen(),
          const ProductsScreen(),
        ];
    }
  }

  List<NavigationDestination> _getDestinationsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ];
      case UserRole.kasir:
        return const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Laporan',
          ),
        ];
      case UserRole.barista:
        return const [
          NavigationDestination(
            icon: Icon(Icons.coffee_maker),
            label: 'Ambil Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Lihat Produk',
          ),
        ];
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.kasir:
        return Icons.point_of_sale;
      case UserRole.barista:
        return Icons.coffee_maker;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.kasir:
        return 'Kasir';
      case UserRole.barista:
        return 'Barista';
    }
  }
}
