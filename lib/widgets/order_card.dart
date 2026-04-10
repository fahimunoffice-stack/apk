import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt = DateFormat('dd MMM, hh:mm a').format(order.createdAt.toLocal());
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber == null || order.orderNumber!.isEmpty
                          ? 'Order'
                          : '#${order.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.customerName ?? 'Customer'),
              const SizedBox(height: 4),
              Text(dt, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('৳${order.total}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

