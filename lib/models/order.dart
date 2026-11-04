class OrderRequest {
  final int? customer_id;
  final int? counter_id;
  final double total_amount;
  final double tax;
  final double discount;
  final List<Item> items;

  OrderRequest({
    this.customer_id,
    this.counter_id,
    required this.total_amount,
    required this.tax,
    required this.discount,
    required this.items,
  }) : assert(
         (customer_id != null) ^ (counter_id != null),
         'Exactly one of customer_id or counter_id must be provided',
       );

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customer_id,
      'counter_id': counter_id,
      'total_amount': total_amount,
      'tax': tax,
      'discount': discount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Item {
  final int product_id;
  final int quantity;

  Item({required this.product_id, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'product_id': product_id, 'quantity': quantity};
  }
}

class OrderResponse {
  final String message;
  final Order order;
  final int? counter_id;
  final int items_created;

  OrderResponse({
    required this.message,
    required this.order,
    required this.counter_id,
    required this.items_created,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      message: json['message'] as String,
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      counter_id: json['counter_id'] as int?,
      items_created: json['items_created'] as int,
    );
  }
}

class Order {
  final int id;
  final int business_id;
  final String business_name;
  final int? customer_id;
  final String? customer_name;
  final DateTime order_date;
  final DateTime updated_at;
  final DateTime created_at;
  final double total_amount;
  final String status;
  final int? counter_id;
  final String? counter_number;
  final List<Items> items;

  Order({
    required this.id,
    required this.business_id,
    required this.business_name,
    required this.customer_id,
    required this.customer_name,
    required this.order_date,
    required this.updated_at,
    required this.created_at,
    required this.total_amount,
    required this.status,
    required this.counter_id,
    required this.counter_number,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      business_id: json['business_id'] as int,
      business_name: json['business_name'] as String,
      customer_id: json['customer_id'] as int?,
      customer_name: json['customer_name'] as String?,
      order_date: DateTime.parse(json['order_date'] as String),
      updated_at: DateTime.parse(json['updated_at'] as String),
      created_at: DateTime.parse(json['created_at'] as String),
      total_amount: _toDouble(json['total_amount']),
      status: json['status'] as String,
      counter_id: json['counter_id'] as int?,
      counter_number: json['counter_number'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => Items.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Items {
  final int id;
  final int order;
  final int product_id;
  final String product_name;
  final int quantity;
  final double unit_price;
  final double total_price;
  final String status;

  Items({
    required this.id,
    required this.order,
    required this.product_id,
    required this.product_name,
    required this.quantity,
    required this.unit_price,
    required this.total_price,
    required this.status,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      id: json['id'] as int,
      order: (json['order'] ?? json['order_id']) as int,
      product_id: json['product_id'] as int,
      product_name: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unit_price: _toDouble(json['unit_price']),
      total_price: _toDouble(json['total_price']),
      status: json['status'] as String,
    );
  }
}

double _toDouble(dynamic value) {
  return value is num ? value.toDouble() : double.parse(value as String);
}
