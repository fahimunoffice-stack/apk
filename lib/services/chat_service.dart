import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/conversation.dart';
import '../models/message.dart';

class ChatService {
  SupabaseClient get _sb => Supabase.instance.client;

  Future<List<Conversation>> listConversations({
    required String storeId,
    String filter = 'all', // all|unread|resolved
  }) async {
    var query = _sb
        .from('messenger_conversations')
        .select('*')
        .eq('store_id', storeId);

    if (filter == 'unread') {
      query = query.eq('is_read', false).eq('is_resolved', false);
    } else if (filter == 'resolved') {
      query = query.eq('is_resolved', true);
    }

    final res =
        await query.order('last_message_at', ascending: false).limit(200);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList();
  }

  Stream<List<Conversation>> watchConversations({
    required String storeId,
  }) {
    return _sb
        .from('messenger_conversations')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .order('last_message_at', ascending: false)
        .map((rows) => rows.map(Conversation.fromJson).toList());
  }

  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
  }) async {
    final res = await _sb
        .from('messenger_messages')
        .select('*')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .limit(500);
    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .toList();
  }

  Stream<List<ChatMessage>> watchMessages({
    required String conversationId,
  }) {
    return _sb
        .from('messenger_messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map(ChatMessage.fromJson).toList());
  }

  Future<void> sendText({
    required String conversationId,
    required String text,
  }) async {
    await _sb.functions.invoke(
      'messenger-send',
      body: {'conversation_id': conversationId, 'message_text': text},
    );
  }

  Future<void> sendMedia({
    required String conversationId,
    required String imageUrl,
    String? caption,
    String mediaType = 'image',
  }) async {
    await _sb.functions.invoke(
      'messenger-send-media',
      body: {
        'conversation_id': conversationId,
        'image_url': imageUrl,
        if (caption != null && caption.trim().isNotEmpty) 'caption': caption,
        'media_type': mediaType,
      },
    );
  }

  Future<void> setResolved({
    required String conversationId,
    required bool value,
  }) async {
    await _sb
        .from('messenger_conversations')
        .update({'is_resolved': value})
        .eq('id', conversationId);
  }

  Future<void> setAutoReplyDisabled({
    required String conversationId,
    required bool value,
  }) async {
    await _sb
        .from('messenger_conversations')
        .update({'auto_reply_disabled': value})
        .eq('id', conversationId);
  }

  Future<void> markRead({
    required String conversationId,
  }) async {
    await _sb
        .from('messenger_conversations')
        .update({'is_read': true})
        .eq('id', conversationId);
  }

  Future<String> uploadChatImageToStorage({
    required String storeId,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    return uploadChatImageBytes(storeId: storeId, bytes: bytes);
  }

  Future<String> uploadChatImageBytes({
    required String storeId,
    required Uint8List bytes,
  }) async {
    final fileName =
        '$storeId/chat/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _sb.storage.from('product-images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return _sb.storage.from('product-images').getPublicUrl(fileName);
  }
}

