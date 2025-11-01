# API Documentation

## Storage Service

### Products

#### `addProduct(Product product)`
Menambahkan produk baru ke storage.

**Parameters:**
- `product`: Object Product yang akan ditambahkan

**Returns:** `Future<int>` - ID produk yang baru ditambahkan

**Example:**
```dart
final product = Product(
  name: 'Kopi Hitam',
  code: 'KOPI001',
  price: 7000,
  stock: 50,
  category: 'Minuman',
);
final id = await storage.addProduct(product);
```

#### `getProduct(int id)`
Mengambil data produk berdasarkan ID.

**Parameters:**
- `id`: ID produk

**Returns:** `Future<Product?>` - Object Product atau null jika tidak ditemukan

#### `getAllProducts()`
Mengambil semua produk dari storage.

**Returns:** `Future<List<Product>>` - List semua produk

#### `updateProduct(Product product)`
Mengupdate data produk yang sudah ada.

**Parameters:**
- `product`: Object Product dengan data yang sudah diupdate (harus memiliki ID)

**Returns:** `Future<void>`

#### `deleteProduct(int id)`
Menghapus produk dari storage.

**Parameters:**
- `id`: ID produk yang akan dihapus

**Returns:** `Future<void>`

---

### Transactions

#### `addTransaction(Transaction transaction)`
Menambahkan transaksi baru.

**Parameters:**
- `transaction`: Object Transaction

**Returns:** `Future<int>` - ID transaksi yang baru ditambahkan

**Example:**
```dart
final transaction = Transaction(
  date: DateTime.now(),
  total: 25000,
  paid: 30000,
  change: 5000,
  customer: 'Umum',
  paymentMethod: 'Tunai',
);
final id = await storage.addTransaction(transaction);
```

#### `getTransaction(int id)`
Mengambil data transaksi berdasarkan ID.

**Parameters:**
- `id`: ID transaksi

**Returns:** `Future<Transaction?>` - Object Transaction atau null

#### `getAllTransactions()`
Mengambil semua transaksi.

**Returns:** `Future<List<Transaction>>` - List semua transaksi

---

### Transaction Items

#### `addTransactionItem(TransactionItem item)`
Menambahkan item transaksi.

**Parameters:**
- `item`: Object TransactionItem

**Returns:** `Future<int>` - ID item yang baru ditambahkan

#### `getTransactionItems(int transactionId)`
Mengambil semua item dari transaksi tertentu.

**Parameters:**
- `transactionId`: ID transaksi

**Returns:** `Future<List<TransactionItem>>` - List item transaksi

---

### Stock Movements

#### `addStockMovement(StockMovement movement)`
Menambahkan pergerakan stok dan otomatis mengupdate stok produk.

**Parameters:**
- `movement`: Object StockMovement

**Returns:** `Future<int>` - ID movement yang baru ditambahkan

**Example:**
```dart
final movement = StockMovement(
  productId: 1,
  change: 10, // positif untuk penambahan, negatif untuk pengurangan
  reason: 'Restock',
  createdAt: DateTime.now(),
);
await storage.addStockMovement(movement);
```

#### `getProductStockMovements(int productId)`
Mengambil riwayat pergerakan stok produk.

**Parameters:**
- `productId`: ID produk

**Returns:** `Future<List<StockMovement>>` - List pergerakan stok

---

## Providers

### ProductsProvider

State notifier untuk mengelola state produk.

**Methods:**
- `loadProducts()`: Reload data produk dari storage
- `addProduct(Product product)`: Tambah produk baru
- `updateProduct(Product product)`: Update produk
- `deleteProduct(int id)`: Hapus produk

**Usage:**
```dart
// Watch products
final productsAsync = ref.watch(productsProvider);

// Add product
await ref.read(productsProvider.notifier).addProduct(product);

// Update product
await ref.read(productsProvider.notifier).updateProduct(product);

// Delete product
await ref.read(productsProvider.notifier).deleteProduct(id);
```

---

### TransactionsProvider

State notifier untuk mengelola state transaksi.

**Methods:**
- `loadTransactions()`: Reload data transaksi
- `addTransaction(Transaction transaction, List<TransactionItem> items)`: Tambah transaksi dengan items

**Usage:**
```dart
// Watch transactions
final transactionsAsync = ref.watch(transactionsProvider);

// Add transaction
await ref.read(transactionsProvider.notifier)
    .addTransaction(transaction, items);
```

---

### CartProvider

State notifier untuk mengelola keranjang belanja.

**Methods:**
- `addItem(Product product)`: Tambah produk ke keranjang
- `removeItem(int productId)`: Hapus item dari keranjang
- `updateQuantity(int productId, int quantity)`: Update quantity item
- `clear()`: Kosongkan keranjang

**Properties:**
- `total`: Total harga semua item di keranjang

**Usage:**
```dart
// Watch cart
final cart = ref.watch(cartProvider);

// Add item
ref.read(cartProvider.notifier).addItem(product);

// Update quantity
ref.read(cartProvider.notifier).updateQuantity(productId, 5);

// Get total
final total = ref.read(cartProvider.notifier).total;

// Clear cart
ref.read(cartProvider.notifier).clear();
```

---

## Models

### Product
```dart
class Product {
  int? id;
  String name;
  String code;
  double price;
  int stock;
  String? description;
  String? image;
  String category;
  bool isActive;
}
```

### Transaction
```dart
class Transaction {
  int? id;
  DateTime date;
  double total;
  String customer;
  String? notes;
  String paymentMethod;
  double paid;
  double change;
}
```

### TransactionItem
```dart
class TransactionItem {
  int? id;
  int transactionId;
  int productId;
  String productName;
  int qty;
  double price;
  double subtotal;
}
```

### StockMovement
```dart
class StockMovement {
  int? id;
  int productId;
  int change;
  String reason;
  DateTime createdAt;
}
```
