import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_prefs_provider.dart';
import '../../providers/store_provider.dart';
import '../../utils/constants.dart';
import '../bots/bot_list_screen.dart';
import '../chat/inbox_screen.dart';
import '../orders/order_list_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(myStoreProvider);
    final store = storeAsync.valueOrNull;
    final storeId = store?.id;

    final prefs = ref.watch(appPrefsProvider).valueOrNull;
    final enabled = prefs?.enabledModules ??
        {AppModule.chat, AppModule.bots, AppModule.orders, AppModule.settings};

    final destinations = <_NavDestination>[
      _NavDestination(
        module: AppModule.chat,
        label: 'চ্যাট',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        builder: () => InboxScreen(storeId: storeId),
      ),
      _NavDestination(
        module: AppModule.bots,
        label: 'বট',
        icon: Icons.smart_toy_outlined,
        activeIcon: Icons.smart_toy,
        builder: () => BotListScreen(storeId: storeId),
      ),
      _NavDestination(
        module: AppModule.orders,
        label: 'অর্ডার',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping,
        builder: () => OrderListScreen(storeId: storeId),
      ),
      _NavDestination(
        module: AppModule.settings,
        label: 'সেটিংস',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        builder: () => SettingsScreen(storeId: storeId),
      ),
    ].where((d) => enabled.contains(d.module)).toList();

    if (_index >= destinations.length) _index = 0;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final d in destinations) d.builder()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _NavDestination {
  final AppModule module;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget Function() builder;

  _NavDestination({
    required this.module,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.builder,
  });
}

