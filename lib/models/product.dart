import 'base_model.dart';

class Product extends BaseModel {
  String name;
  String code;
  double price;
  int stock;
  String? description;
  String? image;
  String category;
  bool isActive;

  Product({
    super.id,
    required this.name,
    required this.code,
    required this.price,
    this.stock = 0,
    this.description,
    this.image,
    this.category = 'Minuman',
    this.isActive = true,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'price': price,
      'stock': stock,
      'description': description,
      'image': image,
      'category': category,
      'isActive': isActive,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      code: json['code'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String?,
      image: json['image'] as String?,
      category: json['category'] as String? ?? 'Minuman',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? code,
    double? price,
    int? stock,
    String? description,
    String? image,
    String? category,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }
}
