class AutoReplyRule {
  final String id;
  final String storeId;
  final String triggerKeyword;
  final String replyText;
  final bool isActive;
  final String? platform;

  AutoReplyRule({
    required this.id,
    required this.storeId,
    required this.triggerKeyword,
    required this.replyText,
    required this.isActive,
    this.platform,
  });

  factory AutoReplyRule.fromJson(Map<String, dynamic> json) {
    return AutoReplyRule(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      triggerKeyword: (json['trigger_keyword'] as String?) ?? '',
      replyText: (json['reply_text'] as String?) ?? '',
      isActive: (json['is_active'] as bool?) ?? true,
      platform: json['platform'] as String?,
    );
  }
}

