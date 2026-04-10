import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/conversation.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/platform_badge.dart';

class InboxScreen extends ConsumerWidget {
  final String? storeId;
  const InboxScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sid = storeId;
    if (sid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filter = ref.watch(inboxFilterProvider);
    final convoAsync = ref.watch(conversationsStreamProvider(sid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ইনবক্স'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(conversationsStreamProvider(sid)),
            icon: const Icon(Icons.refresh),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('সব')),
                ButtonSegment(value: 'unread', label: Text('অপঠিত')),
                ButtonSegment(value: 'resolved', label: Text('Resolved')),
              ],
              selected: {filter},
              onSelectionChanged: (s) =>
                  ref.read(inboxFilterProvider.notifier).state = s.first,
            ),
          ),
          Expanded(
            child: convoAsync.when(
              data: (rows) {
                final list = _applyFilter(rows, filter);
                if (list.isEmpty) {
                  return const Center(child: Text('কোনো কথোপকথন নেই।'));
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) => _ConversationTile(convo: list[i]),
                );
              },
              error: (_, __) => const Center(
                child: Text('লোড করা যাচ্ছে না।'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  List<Conversation> _applyFilter(List<Conversation> input, String filter) {
    return switch (filter) {
      'unread' => input.where((c) => !c.isRead && !c.isResolved).toList(),
      'resolved' => input.where((c) => c.isResolved).toList(),
      _ => input,
    };
  }
}

class _ConversationTile extends ConsumerWidget {
  final Conversation convo;
  const _ConversationTile({required this.convo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = (convo.lastMessage ?? '').trim();
    final time = convo.lastMessageAt == null
        ? ''
        : timeago.format(convo.lastMessageAt!.toLocal(), locale: 'en_short');

    return ListTile(
      onTap: () {
        ref.read(chatServiceProvider).markRead(conversationId: convo.id);
        context.push('/home/chat/${convo.id}');
      },
      leading: CircleAvatar(
        backgroundImage: (convo.senderProfilePic ?? '').isEmpty
            ? null
            : CachedNetworkImageProvider(convo.senderProfilePic!),
        child: (convo.senderProfilePic ?? '').isEmpty
            ? Text((convo.senderName ?? '?').trim().isEmpty
                ? '?'
                : (convo.senderName ?? '?').trim().characters.first)
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              (convo.senderName ?? 'Unknown'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          PlatformBadge(platform: convo.platform ?? 'messenger'),
        ],
      ),
      subtitle: Text(
        subtitle.isEmpty ? '(No message)' : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          if (!convo.isRead && !convo.isResolved)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

