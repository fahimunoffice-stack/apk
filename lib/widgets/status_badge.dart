import 'package:flutter/material.dart';

import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final (label, color) = switch (s) {
      'pending' => ('Pending', AppColors.pending),
      'confirmed' => ('Confirmed', AppColors.confirmed),
      'processing' => ('Processing', AppColors.confirmed),
      'shipped' => ('Shipped', AppColors.shipped),
      'delivered' => ('Delivered', AppColors.delivered),
      'cancelled' => ('Cancelled', AppColors.cancelled),
      _ => (status, Theme.of(context).colorScheme.outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

