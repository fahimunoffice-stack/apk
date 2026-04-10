import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/store_provider.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _name = TextEditingController();
  String _category = 'general';
  String _language = 'bn';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('স্টোর সেটআপ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'আপনার স্টোরের তথ্য দিন',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'স্টোর নাম',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'ক্যাটাগরি',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('General')),
              DropdownMenuItem(value: 'fashion', child: Text('Fashion')),
              DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
              DropdownMenuItem(value: 'grocery', child: Text('Grocery')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'general'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: const InputDecoration(
              labelText: 'ভাষা',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) => setState(() => _language = v ?? 'bn'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('সেভ করুন'),
          ),
          const SizedBox(height: 10),
          Text(
            'সেভ করার পর আপনার অ্যাকাউন্টের জন্য RLS অনুযায়ী ডাটা অ্যাক্সেস সক্রিয় হবে।',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final name = _name.text.trim();
      if (name.isEmpty) {
        setState(() => _error = 'স্টোর নাম দিন।');
        return;
      }

      final storeService = ref.read(storeServiceProvider);
      await storeService.createStore(
        storeName: name,
        category: _category,
        language: _language,
      );

      if (mounted) context.go('/home');
    } catch (_) {
      setState(() => _error = 'সেভ করা যায়নি। আবার চেষ্টা করুন।');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

