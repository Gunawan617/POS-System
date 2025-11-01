import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import '../models/transaction.dart';

class StorageService {
  static const String productsKey = 'products';
  static const String transactionsKey = 'transactions';
  static const String transactionItemsKey = 'transaction_items';
  static const String stockMovementsKey = 'stock_movements';

  final _storage = const FlutterSecureStorage();

  Future<void> _init() async {
    if (await _storage.read(key: productsKey) == null) {
      await _storage.write(key: productsKey, value: jsonEncode([]));
    }
    if (await _storage.read(key: transactionsKey) == null) {
      await _storage.write(key: transactionsKey, value: jsonEncode([]));
    }
    if (await _storage.read(key: transactionItemsKey) == null) {
      await _storage.write(key: transactionItemsKey, value: jsonEncode([]));
    }
    if (await _storage.read(key: stockMovementsKey) == null) {
      await _storage.write(key: stockMovementsKey, value: jsonEncode([]));
    }
  }

  // Products
  Future<int> addProduct(Product product) async {
    await _init();
    final data = await _storage.read(key: productsKey);
    final List<dynamic> products = jsonDecode(data ?? '[]');
    final int id = products.isEmpty ? 1 : (products.last['id'] as int) + 1;
    product.id = id;
    products.add(product.toJson());
    await _storage.write(key: productsKey, value: jsonEncode(products));
    return id;
  }

  Future<Product?> getProduct(int id) async {
    await _init();
    final data = await _storage.read(key: productsKey);
    final List<dynamic> products = jsonDecode(data ?? '[]');
    try {
      final productJson = products.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['id'] == id,
      );
      return Product.fromJson(productJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> getAllProducts() async {
    await _init();
    final data = await _storage.read(key: productsKey);
    final List<dynamic> products = jsonDecode(data ?? '[]');
    return products
        .cast<Map<String, dynamic>>()
        .map((json) => Product.fromJson(json))
        .toList();
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) throw Exception('Product ID cannot be null');
    
    await _init();
    final data = await _storage.read(key: productsKey);
    final List<dynamic> products = jsonDecode(data ?? '[]');
    final int index = products.indexWhere((p) => p['id'] == product.id);
    if (index != -1) {
      products[index] = product.toJson();
      await _storage.write(key: productsKey, value: jsonEncode(products));
    }
  }

  Future<void> deleteProduct(int id) async {
    await _init();
    final data = await _storage.read(key: productsKey);
    final List<dynamic> products = jsonDecode(data ?? '[]');
    products.removeWhere((p) => p['id'] == id);
    await _storage.write(key: productsKey, value: jsonEncode(products));
  }

  // Transactions
  Future<int> addTransaction(Transaction transaction) async {
    await _init();
    final data = await _storage.read(key: transactionsKey);
    final List<dynamic> transactions = jsonDecode(data ?? '[]');
    final int id = transactions.isEmpty ? 1 : (transactions.last['id'] as int) + 1;
    transaction.id = id;
    transactions.add(transaction.toJson());
    await _storage.write(key: transactionsKey, value: jsonEncode(transactions));
    return id;
  }

  Future<Transaction?> getTransaction(int id) async {
    await _init();
    final data = await _storage.read(key: transactionsKey);
    final List<dynamic> transactions = jsonDecode(data ?? '[]');
    try {
      final transactionJson = transactions.cast<Map<String, dynamic>>().firstWhere(
        (t) => t['id'] == id,
      );
      return Transaction.fromJson(transactionJson);
    } catch (e) {
      return null;
    }
  }

  Future<List<Transaction>> getAllTransactions() async {
    await _init();
    final data = await _storage.read(key: transactionsKey);
    final List<dynamic> transactions = jsonDecode(data ?? '[]');
    return transactions
        .cast<Map<String, dynamic>>()
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  // Transaction Items
  Future<int> addTransactionItem(TransactionItem item) async {
    await _init();
    final data = await _storage.read(key: transactionItemsKey);
    final List<dynamic> items = jsonDecode(data ?? '[]');
    final int id = items.isEmpty ? 1 : (items.last['id'] as int) + 1;
    item.id = id;
    items.add(item.toJson());
    await _storage.write(key: transactionItemsKey, value: jsonEncode(items));
    return id;
  }

  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    await _init();
    final data = await _storage.read(key: transactionItemsKey);
    final List<dynamic> items = jsonDecode(data ?? '[]');
    return items
        .cast<Map<String, dynamic>>()
        .where((json) => json['transaction_id'] == transactionId)
        .map((json) => TransactionItem.fromJson(json))
        .toList();
  }

  // Stock Movements
  Future<int> addStockMovement(StockMovement movement) async {
    await _init();
    final data = await _storage.read(key: stockMovementsKey);
    final List<dynamic> movements = jsonDecode(data ?? '[]');
    final int id = movements.isEmpty ? 1 : (movements.last['id'] as int) + 1;
    movement.id = id;
    movements.add(movement.toJson());
    await _storage.write(key: stockMovementsKey, value: jsonEncode(movements));

    // Update product stock
    final product = await getProduct(movement.productId);
    if (product != null) {
      product.stock += movement.change;
      await updateProduct(product);
    }

    return id;
  }

  Future<List<StockMovement>> getProductStockMovements(int productId) async {
    await _init();
    final data = await _storage.read(key: stockMovementsKey);
    final List<dynamic> movements = jsonDecode(data ?? '[]');
    return movements
        .cast<Map<String, dynamic>>()
        .where((json) => json['product_id'] == productId)
        .map((json) => StockMovement.fromJson(json))
        .toList();
  }

  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
