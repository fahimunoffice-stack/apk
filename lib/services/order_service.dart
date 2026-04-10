import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';

class OrderService {
  SupabaseClient get _sb => Supabase.instance.client;

  Future<List<Order>> listOrders({
    required String storeId,
    String status = 'all',
  }) async {
    var query = _sb.from('orders').select('*').eq('store_id', storeId);
    if (status != 'all') {
      query = query.eq('status', status);
    }

    final res =
        await query.order('created_at', ascending: false).limit(200);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();
  }

  Stream<List<Order>> watchOrders({required String storeId}) {
    return _sb
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Order.fromJson).toList());
  }

  Future<Order> fetchOrder(String orderId) async {
    final res = await _sb.from('orders').select('*').eq('id', orderId).single();
    return Order.fromJson(res);
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _sb.from('orders').update({'status': status}).eq('id', orderId);
  }

  Future<void> updateFields(String orderId, Map<String, dynamic> patch) async {
    await _sb.from('orders').update(patch).eq('id', orderId);
  }

  Future<void> smsNotify(String orderId) async {
    await _sb.functions.invoke('order-sms-notify', body: {'order_id': orderId});
  }
}

