

class ProductResponse {
  final int id;
  final String name;
  final String category;
  final double unit_price;
  final String cost_price;
  final String sku;
  final int business_id;
  final int quantity;
  final int reorder_level;
  final bool is_low_stock;
  final String description;
  final String product_image;
  final DateTime is_created_at;
  final DateTime is_updated_at;

  static double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  ProductResponse({
    required this.id,
    required this.name,
    required this.category,
    required this.unit_price,
    required this.cost_price,
    required this.sku,
    required this.business_id,
    required this.quantity,
    required this.reorder_level,
    required this.is_low_stock,
    required this.description,
    required this.product_image,
    required this.is_created_at,
    required this.is_updated_at,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      unit_price: _toDouble(json['unit_price']),
      cost_price: json['cost_price'] as String,
      sku: json['sku'] as String,
      business_id: json['business_id'] as int,
      quantity: json['quantity'] as int,
      reorder_level: json['reorder_level'] as int,
      is_low_stock: json['is_low_stock'] as bool,
      description: json['description'] as String,
      product_image: json['product_image'] as String,
      is_created_at: DateTime.parse(json['is_created_at'] as String),
      is_updated_at: DateTime.parse(json['is_updated_at'] as String),
    );
  }
}