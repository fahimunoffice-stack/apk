import 'package:flutter/material.dart';

class AppColors {
  static const indigo = Color(0xFF6366F1);

  static const pending = Color(0xFFF59E0B); // amber
  static const confirmed = Color(0xFF3B82F6); // blue
  static const shipped = Color(0xFF6366F1); // indigo
  static const delivered = Color(0xFF22C55E); // green
  static const cancelled = Color(0xFFEF4444); // red
}

class PrefKeys {
  static const onboardingDone = 'onboarding_done';
  static const enabledModules = 'enabled_modules';
  static const themeMode = 'theme_mode'; // system|dark|light
  static const storeId = 'store_id_cache';
}

enum AppModule {
  chat,
  bots,
  orders,
  settings,
  analytics,
  products,
  whatsapp,
  instagram,
}

extension AppModuleX on AppModule {
  String get key => name;
}

