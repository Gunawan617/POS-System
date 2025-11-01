import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/sample_data.dart';
import 'package:intl/intl.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Load Sample Data',
            onPressed: () => _loadSampleData(context, ref),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada produk', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.coffee),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kode: ${product.code}'),
                      Text('Kategori: ${product.category}'),
                      Text('Stok: ${product.stock}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showProductDialog(context, ref, product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _deleteProduct(context, ref, product),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, {Product? product}) {
    final nameController = TextEditingController(text: product?.name);
    final codeController = TextEditingController(text: product?.code);
    final priceController = TextEditingController(text: product?.price.toString());
    final stockController = TextEditingController(text: product?.stock.toString() ?? '0');
    final descController = TextEditingController(text: product?.description);
    String selectedCategory = product?.category ?? 'Minuman';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Produk',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Minuman', 'Makanan', 'Snack']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final newProduct = Product(
                id: product?.id,
                name: nameController.text,
                code: codeController.text,
                price: double.tryParse(priceController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
                description: descController.text,
                category: selectedCategory,
              );

              if (product == null) {
                await ref.read(productsProvider.notifier).addProduct(newProduct);
              } else {
                await ref.read(productsProvider.notifier).updateProduct(newProduct);
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(productsProvider.notifier).deleteProduct(product.id!);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}


  Future<void> _loadSampleData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Sample Data'),
        content: const Text('Ini akan menambahkan 8 produk contoh. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final products = SampleData.getSampleProducts();
      for (var product in products) {
        await ref.read(productsProvider.notifier).addProduct(product);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample data berhasil ditambahkan!')),
        );
      }
    }
  }
