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
      name: json['product_name'] as String,
      category: json['category'] as int?,
      unit_price: _toDouble(json['unit_price']),
      cost_price: _toNullableString(json['cost_price']),
      sku: _toNullableString(json['sku']),
      business_id: json['business_id'] as int,
      quantity: json['quantity'] as int,
      reorder_level: json['reorder_level'] as int,
      is_low_stock: json['is_low_stock'] as bool,
      description: _toNullableString(json['description']),
      product_image: _toNullableString(json['product_Img']) ?? '',
      is_created_at: DateTime.parse(json['is_created_at'] as String),
      is_updated_at: DateTime.parse(json['is_updated_at'] as String),
    );
  }
}

class ProductRequest {
  final String product_name;
  final int? category;
  final double unit_price;
  final String? cost_price;
  final String? sku;
  final int quantity;
  final int? reorder_level;
  final String? description;

  ProductRequest({
    required this.product_name,
    this.category,
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