import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../utils/sample_data.dart';

Future<void> loadSampleData(BuildContext context, WidgetRef ref) async {
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
