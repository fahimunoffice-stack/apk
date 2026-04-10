class FacebookPage {
  final String id;
  final String storeId;
  final String pageId;
  final String pageName;
  final bool isActive;
  final String? webhookVerifyToken;

  FacebookPage({
    required this.id,
    required this.storeId,
    required this.pageId,
    required this.pageName,
    required this.isActive,
    required this.webhookVerifyToken,
  });

  factory FacebookPage.fromJson(Map<String, dynamic> json) {
    return FacebookPage(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      pageId: (json['page_id'] as String?) ?? '',
      pageName: (json['page_name'] as String?) ?? '',
      isActive: (json['is_active'] as bool?) ?? true,
      webhookVerifyToken: json['webhook_verify_token'] as String?,
    );
  }
}

