import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/order_provider.dart';
import '../../widgets/order_card.dart';

class OrderListScreen extends ConsumerWidget {
  final String? storeId;
  const OrderListScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sid = storeId;
    if (sid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filter = ref.watch(orderStatusFilterProvider);
    final ordersAsync = ref.watch(ordersStreamProvider(sid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('অর্ডার'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(ordersStreamProvider(sid)),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(ref, 'all', 'সব'),
                  _chip(ref, 'pending', 'Pending'),
                  _chip(ref, 'confirmed', 'Confirmed'),
                  _chip(ref, 'processing', 'Processing'),
                  _chip(ref, 'shipped', 'Shipped'),
                  _chip(ref, 'delivered', 'Delivered'),
                  _chip(ref, 'cancelled', 'Cancelled'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final list = filter == 'all'
                    ? orders
                    : orders.where((o) => o.status == filter).toList();
                if (list.isEmpty) {
                  return const Center(child: Text('কোনো অর্ডার নেই।'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(ordersStreamProvider(sid));
                    await Future<void>.delayed(const Duration(milliseconds: 400));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final o = list[i];
                      return OrderCard(
                        order: o,
                        onTap: () => context.push('/home/orders/${o.id}'),
                      );
                    },
                  ),
                );
              },
              error: (_, __) => const Center(child: Text('লোড করা যাচ্ছে না।')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(WidgetRef ref, String value, String label) {
    final selected = ref.watch(orderStatusFilterProvider) == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => ref.read(orderStatusFilterProvider.notifier).state = value,
      ),
    );
  }
}

