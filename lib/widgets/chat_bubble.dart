import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isStore = message.senderType == 'store' || message.senderType == 'bot';
    final align = isStore ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isStore
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isStore ? 14 : 4),
      bottomRight: Radius.circular(isStore ? 4 : 14),
    );

    Widget content;
    if (message.messageType == 'image' && message.attachmentUrl != null) {
      content = _ImageBubble(
        url: message.attachmentUrl!,
        caption: (message.messageText ?? '').trim().isEmpty
            ? null
            : message.messageText!,
      );
    } else {
      content = Text(
        (message.messageText ?? '').trim(),
        style: const TextStyle(fontSize: 14),
      );
    }

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: content,
        ),
        const SizedBox(height: 3),
        Text(
          _time(context, message.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  String _time(BuildContext context, DateTime dt) {
    final t = TimeOfDay.fromDateTime(dt.toLocal());
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ap';
  }
}

class _ImageBubble extends StatelessWidget {
  final String url;
  final String? caption;
  const _ImageBubble({required this.url, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _FullScreenPhoto(url: url),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 240,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(height: 160, color: Colors.grey.shade300),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(caption!, style: const TextStyle(fontSize: 13)),
        ],
      ],
    );
  }
}

class _FullScreenPhoto extends StatelessWidget {
  final String url;
  const _FullScreenPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(url),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

