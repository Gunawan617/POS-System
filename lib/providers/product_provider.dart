import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(ref.read(storageServiceProvider));
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final StorageService _storage;

  ProductsNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _storage.getAllProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduct(Product product) async {
    await _storage.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _storage.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _storage.deleteProduct(id);
    await loadProducts();
  }
}
