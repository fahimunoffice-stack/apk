import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final orderStatusFilterProvider =
    StateProvider<String>((ref) => 'all'); // all|pending|confirmed|...

final ordersStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, storeId) {
  final orders = ref.watch(orderServiceProvider);
  return orders.watchOrders(storeId: storeId);
});

