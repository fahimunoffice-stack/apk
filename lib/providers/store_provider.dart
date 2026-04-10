import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store.dart';
import '../services/store_service.dart';
import '../utils/constants.dart';

final storeServiceProvider = Provider<StoreService>((ref) => StoreService());

final myStoreProvider = FutureProvider<Store?>((ref) async {
  final storeService = ref.watch(storeServiceProvider);
  final store = await storeService.fetchMyStore();
  if (store != null) {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(PrefKeys.storeId, store.id);
  }
  return store;
});

