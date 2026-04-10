class Order {
  final String id;
  final String storeId;
  final String? orderNumber;
  final String? customerName;
  final String? customerPhone;
  final String status;
  final num total;
  final DateTime createdAt;
  final List<dynamic> items;
  final Map<String, dynamic> raw;

  Order({
    required this.id,
    required this.storeId,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.raw,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      orderNumber: json['order_number'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      total: (json['total'] as num?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List?) ?? const [],
      raw: json,
    );
  }
}

