import '../models/product.dart';

class SampleData {
  static List<Product> getSampleProducts() {
    return [
      Product(
        name: 'Kopi Hitam',
        code: 'KOPI001',
        price: 7000,
        stock: 50,
        category: 'Minuman',
        description: 'Kopi hitam original',
      ),
      Product(
        name: 'Kopi Susu',
        code: 'KOPI002',
        price: 10000,
        stock: 45,
        category: 'Minuman',
        description: 'Kopi susu manis',
      ),
      Product(
        name: 'Es Teh',
        code: 'TEH001',
        price: 5000,
        stock: 60,
        category: 'Minuman',
        description: 'Es teh manis',
      ),
      Product(
        name: 'Teh Hangat',
        code: 'TEH002',
        price: 4000,
        stock: 55,
        category: 'Minuman',
        description: 'Teh hangat',
      ),
      Product(
        name: 'Mie Goreng',
        code: 'MIE001',
        price: 12000,
        stock: 30,
        category: 'Makanan',
        description: 'Mie goreng spesial',
      ),
      Product(
        name: 'Nasi Goreng',
        code: 'NASI001',
        price: 15000,
        stock: 25,
        category: 'Makanan',
        description: 'Nasi goreng spesial',
      ),
      Product(
        name: 'Pisang Goreng',
        code: 'SNACK001',
        price: 8000,
        stock: 40,
        category: 'Snack',
        description: 'Pisang goreng crispy',
      ),
      Product(
        name: 'Gorengan',
        code: 'SNACK002',
        price: 6000,
        stock: 50,
        category: 'Snack',
        description: 'Gorengan campur',
      ),
    ];
  }
}
