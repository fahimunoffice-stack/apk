import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/chat_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/chat_bubble.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _text = TextEditingController();
  final _caption = TextEditingController();
  final _scroll = ScrollController();

  bool _sending = false;
  XFile? _pendingImage;

  @override
  void dispose() {
    _text.dispose();
    _caption.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(myStoreProvider);
    final store = storeAsync.valueOrNull;
    final storeId = store?.id;

    final messagesAsync = ref.watch(messagesStreamProvider(widget.conversationId));

    ref.listen(messagesStreamProvider(widget.conversationId), (_, __) {
      unawaited(_scrollToBottom());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('চ্যাট'),
        actions: [
          IconButton(
            tooltip: 'Bot থামাও',
            onPressed: () => _setAutoReplyDisabled(true),
            icon: const Icon(Icons.pause_circle_outline),
          ),
          IconButton(
            tooltip: 'Bot চালু করো',
            onPressed: () => _setAutoReplyDisabled(false),
            icon: const Icon(Icons.play_circle_outline),
          ),
          IconButton(
            tooltip: 'Resolved',
            onPressed: () => _toggleResolved(),
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (msgs) {
                if (msgs.isEmpty) {
                  return const Center(child: Text('কোনো মেসেজ নেই।'));
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    final isStore =
                        m.senderType == 'store' || m.senderType == 'bot';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Align(
                        alignment: isStore
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatBubble(message: m),
                      ),
                    );
                  },
                );
              },
              error: (_, __) => const Center(child: Text('লোড করা যাচ্ছে না।')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          if (_pendingImage != null)
            _pendingMediaPreview(
              context,
              storeId: storeId,
              file: _pendingImage!,
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : () => _openAttachSheet(storeId),
                    icon: const Icon(Icons.attach_file),
                    tooltip: 'অ্যাটাচ',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'মেসেজ লিখুন...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _sendText,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingMediaPreview(
    BuildContext context, {
    required String? storeId,
    required XFile file,
  }) {
    return Material(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ছবি পাঠাতে যাচ্ছেন',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _caption,
              decoration: const InputDecoration(
                labelText: 'ক্যাপশন (ঐচ্ছিক)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _pendingImage = null;
                    _caption.clear();
                  }),
                  child: const Text('বাতিল'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _sending
                      ? null
                      : () => _sendPendingImage(storeId: storeId),
                  icon: const Icon(Icons.send),
                  label: const Text('পাঠান'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendText() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(chatServiceProvider)
          .sendText(conversationId: widget.conversationId, text: text);
      _text.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মেসেজ পাঠানো যায়নি।')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendPendingImage({required String? storeId}) async {
    final img = _pendingImage;
    if (img == null) return;
    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('স্টোর লোড হয়নি।')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final chat = ref.read(chatServiceProvider);
      final url = await chat.uploadChatImageToStorage(storeId: storeId, file: img);
      await chat.sendMedia(
        conversationId: widget.conversationId,
        imageUrl: url,
        caption: _caption.text.trim().isEmpty ? null : _caption.text.trim(),
        mediaType: 'image',
      );
      setState(() {
        _pendingImage = null;
        _caption.clear();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ছবি পাঠানো যায়নি।')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openAttachSheet(String? storeId) async {
    final action = await showModalBottomSheet<_AttachAction>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('পণ্যের ছবি পাঠান'),
              onTap: () => Navigator.pop(context, _AttachAction.product),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('গ্যালারি থেকে ছবি'),
              onTap: () => Navigator.pop(context, _AttachAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('ক্যামেরা'),
              onTap: () => Navigator.pop(context, _AttachAction.camera),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );

    if (action == null) return;

    if (action == _AttachAction.gallery || action == _AttachAction.camera) {
      final picker = ImagePicker();
      final img = await picker.pickImage(
        source:
            action == _AttachAction.camera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (img == null) return;
      setState(() => _pendingImage = img);
      return;
    }

    if (action == _AttachAction.product) {
      if (storeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('স্টোর লোড হয়নি।')),
        );
        return;
      }
      final product = await showModalBottomSheet<_ProductPick>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _ProductPicker(storeId: storeId),
      );
      if (product == null) return;

      await ref.read(chatServiceProvider).sendMedia(
            conversationId: widget.conversationId,
            imageUrl: product.imageUrl,
            caption: product.caption,
            mediaType: 'image',
          );
    }
  }

  Future<void> _toggleResolved() async {
    try {
      // We don't know current state here; set true as quick action.
      await ref
          .read(chatServiceProvider)
          .setResolved(conversationId: widget.conversationId, value: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resolved করা হয়েছে।')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপডেট করা যায়নি।')),
      );
    }
  }

  Future<void> _setAutoReplyDisabled(bool v) async {
    try {
      await ref
          .read(chatServiceProvider)
          .setAutoReplyDisabled(conversationId: widget.conversationId, value: v);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(v ? 'Bot থামানো হয়েছে।' : 'Bot চালু করা হয়েছে।')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আপডেট করা যায়নি।')),
      );
    }
  }

  Future<void> _scrollToBottom() async {
    if (!_scroll.hasClients) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }
}

enum _AttachAction { product, gallery, camera }

class _ProductPick {
  final String imageUrl;
  final String caption;
  _ProductPick({required this.imageUrl, required this.caption});
}

class _ProductPicker extends ConsumerStatefulWidget {
  final String storeId;
  const _ProductPicker({required this.storeId});

  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client
          .from('products')
          .select('id, name, name_bn, price, discount_price, images')
          .eq('store_id', widget.storeId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(60);
      setState(() => _items = (res as List).cast<Map<String, dynamic>>());
    } catch (_) {
      setState(() => _error = 'পণ্য লোড করা যায়নি।');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: pad),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('পণ্য নির্বাচন'),
              actions: [
                IconButton(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final p = _items[i];
                          final images = (p['images'] as List?) ?? const [];
                          final imageUrl =
                              images.isEmpty ? null : images.first as String?;
                          final nameBn = (p['name_bn'] as String?)?.trim();
                          final name = (p['name'] as String?)?.trim();
                          final title = (nameBn?.isNotEmpty == true)
                              ? nameBn!
                              : (name?.isNotEmpty == true ? name! : 'পণ্য');
                          final price = (p['discount_price'] as num?) ??
                              (p['price'] as num?) ??
                              0;

                          return InkWell(
                            onTap: imageUrl == null
                                ? null
                                : () {
                                    Navigator.pop(
                                      context,
                                      _ProductPick(
                                        imageUrl: imageUrl,
                                        caption: '$title — ৳$price',
                                      ),
                                    );
                                  },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      child: imageUrl == null
                                          ? const Icon(Icons.image_not_supported_outlined)
                                          : Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('৳$price'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}

