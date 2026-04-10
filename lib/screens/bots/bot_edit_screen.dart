import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auto_reply.dart';
import '../../providers/bot_provider.dart';

class BotEditScreen extends ConsumerStatefulWidget {
  final String storeId;
  final AutoReplyRule? existing;
  const BotEditScreen({super.key, required this.storeId, this.existing});

  @override
  ConsumerState<BotEditScreen> createState() => _BotEditScreenState();
}

class _BotEditScreenState extends ConsumerState<BotEditScreen> {
  late final TextEditingController _keyword;
  late final TextEditingController _reply;
  bool _active = true;
  String _platform = 'messenger';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _keyword = TextEditingController(text: widget.existing?.triggerKeyword ?? '');
    _reply = TextEditingController(text: widget.existing?.replyText ?? '');
    _active = widget.existing?.isActive ?? true;
    _platform = widget.existing?.platform ?? 'messenger';
  }

  @override
  void dispose() {
    _keyword.dispose();
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'রুল এডিট' : 'নতুন রুল'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _keyword,
            decoration: const InputDecoration(
              labelText: 'Trigger keyword',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reply,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Reply text',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _platform,
            decoration: const InputDecoration(
              labelText: 'Platform',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'messenger', child: Text('Messenger')),
              DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp (future)')),
              DropdownMenuItem(value: 'instagram', child: Text('Instagram (future)')),
            ],
            onChanged: (v) => setState(() => _platform = v ?? 'messenger'),
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: const Text('Active'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('সেভ'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final keyword = _keyword.text.trim();
      final reply = _reply.text.trim();
      if (keyword.isEmpty || reply.isEmpty) {
        setState(() => _error = 'Keyword এবং reply text দিন।');
        return;
      }
      await ref.read(botServiceProvider).upsertRule(
            id: widget.existing?.id,
            storeId: widget.storeId,
            triggerKeyword: keyword,
            replyText: reply,
            isActive: _active,
            platform: _platform,
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _error = 'সেভ করা যায়নি।');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

