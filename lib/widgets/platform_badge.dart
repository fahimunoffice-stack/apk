import 'package:flutter/material.dart';

class PlatformBadge extends StatelessWidget {
  final String? platform;
  const PlatformBadge({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    final p = (platform ?? 'messenger').toLowerCase();
    final (icon, color, label) = switch (p) {
      'instagram' => (Icons.camera_alt, const Color(0xFFE1306C), 'IG'),
      'whatsapp' => (Icons.chat, const Color(0xFF25D366), 'WA'),
      _ => (Icons.message, const Color(0xFF1877F2), 'MSG'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

