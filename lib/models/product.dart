class ProductResponse {
  final int id;
  final String name;
  final int? category;
  final double unit_price;
  final String? cost_price;
  final String? sku;
  final int business_id;
  final int quantity;
  final int reorder_level;
  final bool is_low_stock;
  final String? description;
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

  static String? _toNullableString(dynamic value) {
    return value?.toString();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
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
  final productJson = json['product'] is Map
      ? Map<String, dynamic>.from(json['product'] as Map)
      : json;

  return ProductResponse(
    id: productJson['id'] as int,
    name: productJson['product_name'] as String,
    category: productJson['category'] as int?,
    unit_price: _toDouble(productJson['unit_price']),
    cost_price: _toNullableString(productJson['cost_price']),
    sku: _toNullableString(productJson['sku']),
    business_id: productJson['business_id'] as int,
    quantity: productJson['quantity'] as int,
    reorder_level: productJson['reorder_level'] as int,
    is_low_stock: productJson['is_low_stock'] as bool,
    description: _toNullableString(productJson['description']),
    product_image: _toNullableString(productJson['product_Img']) ?? '',
    is_created_at: DateTime.parse(productJson['is_created_at'] as String),
    is_updated_at: DateTime.parse(productJson['is_updated_at'] as String),
  );
}
}

class ProductRequest {
  final String product_name;
  final int category;
  final double unit_price;
  final String? cost_price;
  final String? sku;
  final int quantity;
  final int? reorder_level;
  final String? description;

  ProductRequest({
    required this.product_name,
    required this.category,
    required this.unit_price,
    this.cost_price,
    this.sku,
    required this.quantity,
    this.reorder_level,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_name': product_name,
      'category': category,
      'unit_price': unit_price,
      'cost_price': cost_price,
      'sku': sku,
      'quantity': quantity,
      'reorder_level': reorder_level,
      'description': description,
    };
  }
}
