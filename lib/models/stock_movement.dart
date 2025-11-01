import 'base_model.dart';

class StockMovement extends BaseModel {
  int productId;
  int change;
  String reason;
  DateTime createdAt;

  StockMovement({
    super.id,
    required this.productId,
    required this.change,
    required this.reason,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'change': change,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      change: json['change'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}