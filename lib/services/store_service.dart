import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/store.dart';

class StoreService {
  SupabaseClient get _sb => Supabase.instance.client;

  Future<Store?> fetchMyStore() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;

    final res = await _sb
        .from('stores')
        .select('*')
        .eq('user_id', uid)
        .maybeSingle();

    if (res == null) return null;
    return Store.fromJson(res);
  }

  Future<Store> createStore({
    required String storeName,
    required String category,
    required String language,
  }) async {
    final uid = _sb.auth.currentUser!.id;
    final inserted = await _sb
        .from('stores')
        .insert({
          'user_id': uid,
          'store_name': storeName,
          'category': category,
          'language': language,
        })
        .select('*')
        .single();

    return Store.fromJson(inserted);
  }

  Future<Store> updateStore(String storeId, Map<String, dynamic> patch) async {
    final updated = await _sb
        .from('stores')
        .update(patch)
        .eq('id', storeId)
        .select('*')
        .single();
    return Store.fromJson(updated);
  }
}

