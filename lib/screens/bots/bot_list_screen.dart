import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bot_provider.dart';
import '../../widgets/bot_rule_tile.dart';
import 'bot_edit_screen.dart';

class BotListScreen extends ConsumerWidget {
  final String? storeId;
  const BotListScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sid = storeId;
    if (sid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rulesAsync = ref.watch(botRulesStreamProvider(sid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('বট রুলস'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(botRulesStreamProvider(sid)),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: rulesAsync.when(
        data: (rules) {
          if (rules.isEmpty) {
            return const Center(child: Text('কোনো রুল নেই।'));
          }
          return ListView.separated(
            itemCount: rules.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final r = rules[i];
              return BotRuleTile(
                rule: r,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BotEditScreen(storeId: sid, existing: r),
                  ),
                ),
                onDelete: () async {
                  await ref.read(botServiceProvider).deleteRule(r.id);
                },
                onToggle: (v) async {
                  await ref.read(botServiceProvider).toggleActive(r.id, v);
                },
              );
            },
          );
        },
        error: (_, __) => const Center(child: Text('লোড করা যাচ্ছে না।')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BotEditScreen(storeId: sid),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

