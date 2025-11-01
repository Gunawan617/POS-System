import 'base_model.dart';

class Transaction extends BaseModel {
  DateTime date;
  double total;
  String customer;
  String? notes;
  String paymentMethod;
  double paid;
  double change;

  Transaction({
    super.id,
    required this.date,
    required this.total,
    this.customer = 'Umum',
    this.notes,
    this.paymentMethod = 'Tunai',
    required this.paid,
    required this.change,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'total': total,
      'customer': customer,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'paid': paid,
      'change': change,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      date: DateTime.parse(json['date'] as String),
      total: (json['total'] as num).toDouble(),
      customer: json['customer'] as String? ?? 'Umum',
      notes: json['notes'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'Tunai',
      paid: (json['paid'] as num?)?.toDouble() ?? 0,
      change: (json['change'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TransactionItem extends BaseModel {
  int transactionId;
  int productId;
  String productName;
  int qty;
  double price;
  double subtotal;

  TransactionItem({
    super.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'qty': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as int?,
      transactionId: json['transaction_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
