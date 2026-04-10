import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auto_reply.dart';

class BotService {
  SupabaseClient get _sb => Supabase.instance.client;

  Future<List<AutoReplyRule>> listRules({required String storeId}) async {
    final res = await _sb
        .from('messenger_auto_replies')
        .select('*')
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .limit(200);

    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(AutoReplyRule.fromJson)
        .toList();
  }

  Stream<List<AutoReplyRule>> watchRules({required String storeId}) {
    return _sb
        .from('messenger_auto_replies')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(AutoReplyRule.fromJson).toList());
  }

  Future<AutoReplyRule> upsertRule({
    String? id,
    required String storeId,
    required String triggerKeyword,
    required String replyText,
    required bool isActive,
    String platform = 'messenger',
  }) async {
    final payload = <String, dynamic>{
      'store_id': storeId,
      'trigger_keyword': triggerKeyword,
      'reply_text': replyText,
      'is_active': isActive,
      'platform': platform,
    };

    final res = id == null
        ? await _sb.from('messenger_auto_replies').insert(payload).select('*').single()
        : await _sb
            .from('messenger_auto_replies')
            .update(payload)
            .eq('id', id)
            .select('*')
            .single();

    return AutoReplyRule.fromJson(res);
  }

  Future<void> deleteRule(String id) async {
    await _sb.from('messenger_auto_replies').delete().eq('id', id);
  }

  Future<void> toggleActive(String id, bool value) async {
    await _sb
        .from('messenger_auto_replies')
        .update({'is_active': value})
        .eq('id', id);
  }
}

