class ChatMessage {
  final String id;
  final String conversationId;
  final String storeId;
  final String? messageText;
  final String senderType; // customer|store|bot
  final String? attachmentUrl;
  final String messageType; // text|image|video|file
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.storeId,
    required this.messageText,
    required this.senderType,
    required this.attachmentUrl,
    required this.messageType,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachmentUrl = json['attachment_url'] as String?;
    final messageType = (json['message_type'] as String?) ??
        (attachmentUrl == null ? 'text' : 'image');

    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      storeId: json['store_id'] as String,
      messageText: json['message_text'] as String?,
      senderType: (json['sender_type'] as String?) ?? 'customer',
      attachmentUrl: attachmentUrl,
      messageType: messageType,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

