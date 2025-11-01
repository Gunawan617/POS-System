import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class CashierScreen extends ConsumerStatefulWidget {
  const CashierScreen({super.key});

  @override
  ConsumerState<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends ConsumerState<CashierScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Product List
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua'),
                      _buildCategoryChip('Minuman'),
                      _buildCategoryChip('Makanan'),
                      _buildCategoryChip('Snack'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final filteredProducts = products.where((p) {
                        final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
                            p.code.toLowerCase().contains(_searchQuery);
                        final matchesCategory = _selectedCategory == 'Semua' ||
                            p.category == _selectedCategory;
                        return matchesSearch && matchesCategory && p.isActive;
                      }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          ),
          // Cart
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const Row(
                    children: [
                      Icon(Icons.shopping_cart),
                      SizedBox(width: 8),
                      Text(
                        'Keranjang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Keranjang kosong', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return _buildCartItem(item);
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(ref.read(cartProvider.notifier).total),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: cart.isEmpty
                                  ? null
                                  : () {
                                      ref.read(cartProvider.notifier).clear();
                                    },
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: cart.isEmpty ? null : _processPayment,
                              child: const Text('Bayar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(cartProvider.notifier).addItem(product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.coffee,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(item.product.price),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id!,
                          item.quantity - 1,
                        );
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id!,
                          item.quantity + 1,
                        );
                  },
                ),
              ],
            ),
            SizedBox(
              width: 80,
              child: Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(item.subtotal),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                ref.read(cartProvider.notifier).removeItem(item.product.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).total;

    final paidController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(total)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Bayar',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Proses'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final paid = double.tryParse(paidController.text) ?? 0;
      if (paid < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jumlah bayar kurang!')),
        );
        return;
      }

      final change = paid - total;
      final transaction = Transaction(
        date: DateTime.now(),
        total: total,
        paid: paid,
        change: change,
      );

      final items = cart.map((item) => TransactionItem(
        transactionId: 0,
        productId: item.product.id!,
        productName: item.product.name,
        qty: item.quantity,
        price: item.product.price,
        subtotal: item.subtotal,
      )).toList();

      await ref.read(transactionsProvider.notifier).addTransaction(transaction, items);
      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pembayaran Berhasil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(total)}'),
                Text('Bayar: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(paid)}'),
                Text(
                  'Kembalian: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(change)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
