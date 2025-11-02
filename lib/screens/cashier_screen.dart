import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/print_service.dart';
import '../services/storage_service.dart';
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
    
    // Deteksi ukuran layar dan orientasi untuk responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    // Material Design Breakpoints (lebih akurat)
    // Small mobile: < 360px (sangat kecil)
    // Mobile: 360-599px
    // Tablet: 600-839px (small tablet), 840-1199px (large tablet)
    // Desktop: >= 1200px
    final isSmallMobile = screenWidth < 360;
    final isMobilePortrait = screenWidth < 600 && orientation == Orientation.portrait;
    final isMobileLandscape = screenWidth < 600 && orientation == Orientation.landscape;
    final isSmallTablet = screenWidth >= 600 && screenWidth < 840;
    final isLargeTablet = screenWidth >= 840 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    
    // Tentukan jumlah kolom grid berdasarkan ukuran layar dengan optimasi lebih baik
    int crossAxisCount;
    if (isSmallMobile) {
      crossAxisCount = 2; // Tetap 2 untuk layar sangat kecil
    } else if (isMobilePortrait) {
      crossAxisCount = 2; // Standard mobile portrait
    } else if (isMobileLandscape) {
      crossAxisCount = screenWidth < 480 ? 3 : 4; // Lebih fleksibel untuk landscape
    } else if (isSmallTablet) {
      crossAxisCount = 3;
    } else if (isLargeTablet) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = screenWidth < 1600 ? 4 : 5; // Desktop bisa lebih banyak kolom
    }
    
    // Tentukan lebar cart berdasarkan ukuran layar dengan optimasi lebih baik
    double? cartWidth;
    if (isMobilePortrait) {
      cartWidth = null; // Menggunakan full width di portrait
    } else if (isMobileLandscape) {
      cartWidth = isSmallMobile ? 260.0 : 280.0;
    } else if (isSmallTablet) {
      cartWidth = 300.0;
    } else if (isLargeTablet) {
      cartWidth = 350.0;
    } else {
      cartWidth = screenWidth < 1600 ? 400.0 : 450.0; // Desktop lebih besar
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isMobilePortrait
          ? _buildMobilePortraitLayout(context, productsAsync, cart, crossAxisCount, isSmallMobile)
          : _buildDesktopLayout(context, productsAsync, cart, crossAxisCount, cartWidth!, isMobileLandscape),
    );
  }

  Widget _buildMobilePortraitLayout(BuildContext context, AsyncValue<List<Product>> productsAsync, List<CartItem> cart, int crossAxisCount, bool isSmallMobile) {
    final padding = isSmallMobile ? 8.0 : 12.0;
    final fontSize = isSmallMobile ? 12.0 : 14.0;
    
    return Column(
      children: [
        // Product List Section
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: Icon(Icons.search, size: isSmallMobile ? 18 : 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallMobile ? 12 : 16,
                      vertical: isSmallMobile ? 10 : 12,
                    ),
                  ),
                  style: TextStyle(fontSize: fontSize),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    _buildCategoryChip('Semua', isSmallMobile),
                    _buildCategoryChip('Minuman', isSmallMobile),
                    _buildCategoryChip('Makanan', isSmallMobile),
                    _buildCategoryChip('Snack', isSmallMobile),
                  ],
                ),
              ),
              SizedBox(height: isSmallMobile ? 4 : 8),
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
                      padding: EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: isSmallMobile ? 0.7 : 0.75,
                        crossAxisSpacing: isSmallMobile ? 6 : 8,
                        mainAxisSpacing: isSmallMobile ? 6 : 8,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product, isSmallMobile);
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
        // Cart Section - Collapsible
        Container(
          height: MediaQuery.of(context).size.height * (isSmallMobile ? 0.35 : 0.4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(padding),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, size: isSmallMobile ? 18 : 20),
                    SizedBox(width: isSmallMobile ? 6 : 8),
                    Expanded(
                      child: Text(
                        'Keranjang',
                        style: TextStyle(
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (cart.isNotEmpty)
                      Text(
                        '${cart.length} item',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 10 : 12,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: cart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: isSmallMobile ? 40 : 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: isSmallMobile ? 6 : 8),
                            Text(
                              'Keranjang kosong',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isSmallMobile ? 11 : 12,
                              ),
                            ),
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
                padding: EdgeInsets.all(padding),
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
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(ref.read(cartProvider.notifier).total),
                            style: TextStyle(
                              fontSize: fontSize + 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallMobile ? 8 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: cart.isEmpty
                                ? null
                                : () {
                                    ref.read(cartProvider.notifier).clear();
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallMobile ? 6 : 8,
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallMobile ? 6 : 8),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: cart.isEmpty ? null : _processPayment,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallMobile ? 6 : 8,
                              ),
                            ),
                            child: Text(
                              'Bayar',
                              style: TextStyle(fontSize: fontSize),
                            ),
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
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AsyncValue<List<Product>> productsAsync, List<CartItem> cart, int crossAxisCount, double cartWidth, bool isMobileLandscape) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallTablet = screenWidth >= 600 && screenWidth < 840;
    final isLargeTablet = screenWidth >= 840 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    
    // Optimasi padding dan font size berdasarkan ukuran layar
    double padding;
    double fontSize;
    double totalFontSize;
    
    if (isMobileLandscape) {
      padding = 8.0;
      fontSize = 14.0;
      totalFontSize = 18.0;
    } else if (isSmallTablet) {
      padding = 12.0;
      fontSize = 16.0;
      totalFontSize = 20.0;
    } else if (isLargeTablet) {
      padding = 14.0;
      fontSize = 17.0;
      totalFontSize = 22.0;
    } else {
      padding = 16.0;
      fontSize = 18.0;
      totalFontSize = 24.0;
    }
    
    return Row(
      children: [
        // Product List
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMobileLandscape ? 12 : 16,
                      vertical: isMobileLandscape ? 10 : 12,
                    ),
                  ),
                  style: TextStyle(fontSize: isMobileLandscape ? 14 : 16),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    _buildCategoryChip('Semua', false),
                    _buildCategoryChip('Minuman', false),
                    _buildCategoryChip('Makanan', false),
                    _buildCategoryChip('Snack', false),
                  ],
                ),
              ),
              SizedBox(height: isMobileLandscape ? 4 : 8),
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
                      padding: EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: isMobileLandscape ? 0.75 : 0.8,
                        crossAxisSpacing: isMobileLandscape ? 8 : 12,
                        mainAxisSpacing: isMobileLandscape ? 8 : 12,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product, false);
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
          width: cartWidth,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(left: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(padding),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, size: fontSize + 6),
                    SizedBox(width: isMobileLandscape ? 6 : 8),
                    Text(
                      'Keranjang',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: isMobileLandscape ? 48 : 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: isMobileLandscape ? 8 : 16),
                            Text(
                              'Keranjang kosong',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isMobileLandscape ? 12 : 14,
                              ),
                            ),
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
                padding: EdgeInsets.all(padding),
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
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(ref.read(cartProvider.notifier).total),
                          style: TextStyle(
                            fontSize: totalFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobileLandscape ? 8 : 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: cart.isEmpty
                                ? null
                                : () {
                                    ref.read(cartProvider.notifier).clear();
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isMobileLandscape ? 8 : 12,
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(fontSize: fontSize - 2),
                            ),
                          ),
                        ),
                        SizedBox(width: isMobileLandscape ? 6 : 8),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: cart.isEmpty ? null : _processPayment,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isMobileLandscape ? 8 : 12,
                              ),
                            ),
                            child: Text(
                              'Bayar',
                              style: TextStyle(fontSize: fontSize - 2),
                            ),
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
    );
  }

  Widget _buildCategoryChip(String category, bool isSmallMobile) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: isSmallMobile ? 6 : 8),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(fontSize: isSmallMobile ? 11 : 13),
        ),
        selected: isSelected,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallMobile ? 6 : 8,
          vertical: isSmallMobile ? 4 : 6,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isSmallMobile) {
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
              child: _buildProductImage(product),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallMobile ? 6 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallMobile ? 11 : 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallMobile ? 2 : 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallMobile ? 10 : 12,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 8,
        vertical: 4,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        child: Row(
          children: [
            Expanded(
              flex: isMobile ? 2 : 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
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
                    ).format(item.product.price),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isMobile ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    size: isMobile ? 20 : 24,
                  ),
                  iconSize: isMobile ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.product.id!,
                          item.quantity - 1,
                        );
                  },
                ),
                Container(
                  width: isMobile ? 24 : 32,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: isMobile ? 20 : 24,
                  ),
                  iconSize: isMobile ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
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
              width: isMobile ? 60 : 80,
              child: Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(item.subtotal),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: isMobile ? 20 : 24,
              ),
              iconSize: isMobile ? 20 : 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
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

      final transactionId = await ref.read(transactionsProvider.notifier).addTransaction(transaction, items);
      transaction.id = transactionId;
      
      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        final printInvoice = await showDialog<bool>(
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
                const SizedBox(height: 16),
                const Text('Cetak struk?', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tidak'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.print),
                label: const Text('Cetak'),
              ),
            ],
          ),
        );

        if (printInvoice == true && mounted) {
          try {
            await PrintService.printInvoice(transaction, items);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal cetak: $e')),
              );
            }
          }
        }
      }
    }
  }

  Widget _buildProductImage(Product product) {
    if (product.image != null && product.image!.isNotEmpty) {
      return kIsWeb
          ? Image.network(
              product.image!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.coffee,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            )
          : Image.file(
              File(product.image!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.coffee,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            );
    }
    
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.coffee,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
