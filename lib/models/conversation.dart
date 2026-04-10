class Conversation {
  final String id;
  final String storeId;
  final String? senderId;
  final String? senderName;
  final String? senderProfilePic;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isRead;
  final bool isResolved;
  final bool autoReplyDisabled;
  final String? facebookPageId;
  final String? platform; // messenger|whatsapp|instagram (future)

  Conversation({
    required this.id,
    required this.storeId,
    this.senderId,
    this.senderName,
    this.senderProfilePic,
    this.lastMessage,
    this.lastMessageAt,
    required this.isRead,
    required this.isResolved,
    required this.autoReplyDisabled,
    this.facebookPageId,
    this.platform,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      senderId: json['sender_id'] as String?,
      senderName: json['sender_name'] as String?,
      senderProfilePic: json['sender_profile_pic'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      isRead: (json['is_read'] as bool?) ?? true,
      isResolved: (json['is_resolved'] as bool?) ?? false,
      autoReplyDisabled: (json['auto_reply_disabled'] as bool?) ?? false,
      facebookPageId: json['facebook_page_id'] as String?,
      platform: json['platform'] as String?,
    );
  }
}

