import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/app_prefs_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../utils/constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String? storeId;
  const SettingsScreen({super.key, required this.storeId});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _saving = false;
  String? _error;

  final _storeName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _district = TextEditingController();

  @override
  void dispose() {
    _storeName.dispose();
    _phone.dispose();
    _address.dispose();
    _district.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider).valueOrNull;
    final themeMode = prefs?.themeMode ?? ThemeMode.dark;

    final storeAsync = ref.watch(myStoreProvider);
    final store = storeAsync.valueOrNull;
    if (store != null && _storeName.text.isEmpty) {
      _storeName.text = store.storeName ?? '';
      _phone.text = store.phone ?? '';
      _address.text = store.address ?? '';
      _district.text = store.district ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('থিম'),
              subtitle: const Text('Dark / Light'),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                onChanged: (m) {
                  if (m == null) return;
                  ref.read(appPrefsProvider.notifier).setThemeMode(m);
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _sectionTitle('Facebook Page Connection'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Webhook URL',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  const SelectableText(
                    'https://ztblsqwnouzivmrrjjjh.supabase.co/functions/v1/facebook-webhook',
                  ),
                  const SizedBox(height: 12),
                  if (widget.storeId == null)
                    const Text('স্টোর লোড হচ্ছে...')
                  else
                    _FacebookPagesList(storeId: widget.storeId!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _sectionTitle('Store Info'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _storeName,
                    decoration: const InputDecoration(
                      labelText: 'স্টোর নাম',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phone,
                    decoration: const InputDecoration(
                      labelText: 'ফোন',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: 'ঠিকানা',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _district,
                    decoration: const InputDecoration(
                      labelText: 'জেলা',
                      border: OutlineInputBorder(),
                    ),
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
                    onPressed: _saving || store == null ? null : () => _saveStore(store.id),
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
            ),
          ),
          const SizedBox(height: 12),
          _sectionTitle('Modules'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bottom nav ট্যাবগুলো Onboarding থেকে নিয়ন্ত্রিত।'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in (prefs?.enabledModules ?? const <AppModule>{}))
                        Chip(label: Text(m.key)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
      );

  Future<void> _saveStore(String storeId) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(storeServiceProvider).updateStore(storeId, {
        'store_name': _storeName.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'district': _district.text.trim(),
      });
      ref.invalidate(myStoreProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সেভ করা হয়েছে।')),
      );
    } catch (_) {
      setState(() => _error = 'সেভ করা যায়নি।');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _FacebookPagesList extends ConsumerStatefulWidget {
  final String storeId;
  const _FacebookPagesList({required this.storeId});

  @override
  ConsumerState<_FacebookPagesList> createState() => _FacebookPagesListState();
}

class _FacebookPagesListState extends ConsumerState<_FacebookPagesList> {
  bool _loading = true;
  List<Map<String, dynamic>> _pages = const [];
  String? _error;

  final _pageId = TextEditingController();
  final _pageName = TextEditingController();
  final _token = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageId.dispose();
    _pageName.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client
          .from('facebook_pages')
          .select('*')
          .eq('store_id', widget.storeId)
          .order('created_at', ascending: false)
          .limit(50);
      setState(() => _pages = (res as List).cast<Map<String, dynamic>>());
    } catch (_) {
      setState(() => _error = 'পেজ লোড করা যায়নি।');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text(_error!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pages.isEmpty)
          const Text('কোনো পেজ কানেক্টেড নেই।')
        else
          Column(
            children: [
              for (final p in _pages)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text((p['page_name'] as String?) ?? ''),
                  subtitle: Text('page_id: ${(p['page_id'] as String?) ?? ''}'),
                  trailing: (p['is_active'] as bool?) == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.remove_circle_outline),
                ),
            ],
          ),
        const Divider(),
        const Text('নতুন পেজ যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _pageName,
          decoration: const InputDecoration(
            labelText: 'Page name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pageId,
          decoration: const InputDecoration(
            labelText: 'Page ID',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _token,
          decoration: const InputDecoration(
            labelText: 'Page access token',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () async {
            final pageId = _pageId.text.trim();
            final pageName = _pageName.text.trim();
            final token = _token.text.trim();
            if (pageId.isEmpty || pageName.isEmpty || token.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('সব ফিল্ড দিন।')),
              );
              return;
            }
            try {
              await Supabase.instance.client.from('facebook_pages').insert({
                'store_id': widget.storeId,
                'page_id': pageId,
                'page_name': pageName,
                'page_access_token': token,
                'is_active': true,
              });
              _pageId.clear();
              _pageName.clear();
              _token.clear();
              await _load();
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('সেভ করা যায়নি।')),
              );
            }
          },
          child: const Text('পেজ যোগ করুন'),
        ),
      ],
    );
  }
}

