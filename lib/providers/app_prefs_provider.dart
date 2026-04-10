import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class AppPrefsState {
  final bool onboardingDone;
  final Set<AppModule> enabledModules;
  final ThemeMode themeMode;

  const AppPrefsState({
    required this.onboardingDone,
    required this.enabledModules,
    required this.themeMode,
  });
}

class AppPrefsNotifier extends AsyncNotifier<AppPrefsState> {
  @override
  Future<AppPrefsState> build() async {
    final sp = await SharedPreferences.getInstance();

    final onboardingDone = sp.getBool(PrefKeys.onboardingDone) ?? false;
    final modulesRaw = sp.getStringList(PrefKeys.enabledModules);
    final themeRaw = sp.getString(PrefKeys.themeMode) ?? 'dark';

    final modules = (modulesRaw ??
            const [
              'chat',
              'bots',
              'orders',
              'settings',
              'whatsapp',
              'instagram',
            ])
        .map(_moduleFromKey)
        .whereType<AppModule>()
        .toSet();

    return AppPrefsState(
      onboardingDone: onboardingDone,
      enabledModules: modules,
      themeMode: _themeFromKey(themeRaw),
    );
  }

  AppModule? _moduleFromKey(String k) {
    for (final m in AppModule.values) {
      if (m.key == k) return m;
    }
    return null;
  }

  ThemeMode _themeFromKey(String k) {
    switch (k) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  String _themeToKey(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  Future<void> setOnboardingDone(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(PrefKeys.onboardingDone, value);
    state = AsyncData(
      (await future).copyWith(onboardingDone: value),
    );
  }

  Future<void> setEnabledModules(Set<AppModule> modules) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(
        PrefKeys.enabledModules, modules.map((e) => e.key).toList());
    final current = await future;
    state = AsyncData(
      AppPrefsState(
        onboardingDone: current.onboardingDone,
        enabledModules: modules,
        themeMode: current.themeMode,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(PrefKeys.themeMode, _themeToKey(themeMode));
    final current = await future;
    state = AsyncData(
      AppPrefsState(
        onboardingDone: current.onboardingDone,
        enabledModules: current.enabledModules,
        themeMode: themeMode,
      ),
    );
  }
}

extension on AppPrefsState {
  AppPrefsState copyWith({
    bool? onboardingDone,
    Set<AppModule>? enabledModules,
    ThemeMode? themeMode,
  }) {
    return AppPrefsState(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      enabledModules: enabledModules ?? this.enabledModules,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

final appPrefsProvider =
    AsyncNotifierProvider<AppPrefsNotifier, AppPrefsState>(AppPrefsNotifier.new);

