class Store {
  final String id;
  final String userId;
  final String? storeName;
  final String? phone;
  final String? address;
  final String? district;
  final Map<String, dynamic>? themeConfig;

  final String? whatsappNumber;
  final String? whatsappMessage;
  final bool? whatsappFloatingEnabled;

  final String? smsApiKey;
  final String? smsSenderId;
  final String? smsApiBaseUrl;
  final String? smsTemplate;

  Store({
    required this.id,
    required this.userId,
    this.storeName,
    this.phone,
    this.address,
    this.district,
    this.themeConfig,
    this.whatsappNumber,
    this.whatsappMessage,
    this.whatsappFloatingEnabled,
    this.smsApiKey,
    this.smsSenderId,
    this.smsApiBaseUrl,
    this.smsTemplate,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storeName: json['store_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      district: json['district'] as String?,
      themeConfig: (json['theme_config'] as Map?)?.cast<String, dynamic>(),
      whatsappNumber: json['whatsapp_number'] as String?,
      whatsappMessage: json['whatsapp_message'] as String?,
      whatsappFloatingEnabled: json['whatsapp_floating_enabled'] as bool?,
      smsApiKey: json['sms_api_key'] as String?,
      smsSenderId: json['sms_sender_id'] as String?,
      smsApiBaseUrl: json['sms_api_base_url'] as String?,
      smsTemplate: json['sms_template'] as String?,
    );
  }
}

