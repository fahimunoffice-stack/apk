import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final inboxFilterProvider = StateProvider<String>((ref) => 'all'); // all|unread|resolved

final conversationsStreamProvider =
    StreamProvider.family<List<Conversation>, String>((ref, storeId) {
  final chat = ref.watch(chatServiceProvider);
  return chat.watchConversations(storeId: storeId);
});

final messagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  final chat = ref.watch(chatServiceProvider);
  return chat.watchMessages(conversationId: conversationId);
});

