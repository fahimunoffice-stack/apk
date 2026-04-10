import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/order_provider.dart';
import '../../widgets/status_badge.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(orderServiceProvider).fetchOrder(widget.orderId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return const Scaffold(
            body: Center(child: Text('অর্ডার লোড করা যায়নি।')),
          );
        }

        final order = snap.data!;

        final items = order.items;
        final paid = (order.raw['is_paid'] as bool?) ?? false;
        final tracking = (order.raw['tracking_number'] as String?) ?? '';
        final courier = (order.raw['courier_name'] as String?) ?? '';
        final notes = (order.raw['notes'] as String?) ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text(order.orderNumber == null ? 'অর্ডার' : '#${order.orderNumber}'),
            actions: [
              IconButton(
                tooltip: 'SMS notify',
                onPressed: () async {
                  try {
                    await ref.read(orderServiceProvider).smsNotify(order.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SMS পাঠানো হয়েছে।')),
                    );
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SMS পাঠানো যায়নি।')),
                    );
                  }
                },
                icon: const Icon(Icons.sms_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName ?? 'Customer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('গ্রাহক তথ্য',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(order.customerPhone ?? '')),
                          TextButton(
                            onPressed: (order.customerPhone ?? '').trim().isEmpty
                                ? null
                                : () => _call(order.customerPhone!),
                            child: const Text('Call'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('ঠিকানা: ${(order.raw['address'] as String?) ?? ''}'),
                      Text('জেলা: ${(order.raw['district'] as String?) ?? ''}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('আইটেমস',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (items.isEmpty)
                        const Text('কোনো আইটেম নেই।')
                      else
                        for (final it in items)
                          _ItemRow(item: (it as Map).cast<String, dynamic>()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('স্ট্যাটাস আপডেট',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: order.status,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'pending', child: Text('pending')),
                          DropdownMenuItem(value: 'confirmed', child: Text('confirmed')),
                          DropdownMenuItem(value: 'processing', child: Text('processing')),
                          DropdownMenuItem(value: 'shipped', child: Text('shipped')),
                          DropdownMenuItem(value: 'delivered', child: Text('delivered')),
                          DropdownMenuItem(value: 'cancelled', child: Text('cancelled')),
                        ],
                        onChanged: _saving
                            ? null
                            : (v) async {
                                if (v == null) return;
                                await _update(order.id, {'status': v});
                                setState(() {});
                              },
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        value: paid,
                        onChanged: _saving
                            ? null
                            : (v) async {
                                await _update(order.id, {'is_paid': v});
                                setState(() {});
                              },
                        title: const Text('Paid'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: courier,
                        decoration: const InputDecoration(
                          labelText: 'Courier name',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (v) => _update(order.id, {'courier_name': v}),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: tracking,
                        decoration: const InputDecoration(
                          labelText: 'Tracking number',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (v) =>
                            _update(order.id, {'tracking_number': v}),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: notes,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (v) => _update(order.id, {'notes': v}),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('মোট'),
                  trailing: Text('৳${order.total}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> _update(String orderId, Map<String, dynamic> patch) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(orderServiceProvider).updateFields(orderId, patch);
    } catch (_) {
      setState(() => _error = 'আপডেট করা যায়নি।');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = (item['name'] ?? item['product_name'] ?? '').toString();
    final qty = (item['qty'] ?? item['quantity'] ?? 1).toString();
    final price = (item['price'] ?? item['unit_price'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(name.isEmpty ? 'Item' : name)),
          Text('x$qty'),
          const SizedBox(width: 12),
          Text('৳$price'),
        ],
      ),
    );
  }
}

