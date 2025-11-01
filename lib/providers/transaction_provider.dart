import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import 'product_provider.dart';

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionsNotifier(ref.read(storageServiceProvider));
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final StorageService _storage;

  TransactionsNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _storage.getAllTransactions();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> addTransaction(Transaction transaction, List<TransactionItem> items) async {
    final transactionId = await _storage.addTransaction(transaction);
    
    for (var item in items) {
      item.transactionId = transactionId;
      await _storage.addTransactionItem(item);
    }
    
    await loadTransactions();
    return transactionId;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            CartItem(product: state[i].product, quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeItem(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    state = [
      for (var item in state)
        if (item.product.id == productId)
          CartItem(product: item.product, quantity: quantity)
        else
          item
    ];
  }

  void clear() {
    state = [];
  }

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
}
