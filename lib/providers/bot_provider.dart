import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auto_reply.dart';
import '../services/bot_service.dart';

final botServiceProvider = Provider<BotService>((ref) => BotService());

final botRulesStreamProvider =
    StreamProvider.family<List<AutoReplyRule>, String>((ref, storeId) {
  final bot = ref.watch(botServiceProvider);
  return bot.watchRules(storeId: storeId);
});

