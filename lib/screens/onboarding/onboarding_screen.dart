import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_prefs_provider.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late Set<AppModule> _enabled;
  bool _initializedFromPrefs = false;

  @override
  void initState() {
    super.initState();
    _enabled = {
      AppModule.chat,
      AppModule.bots,
      AppModule.orders,
      AppModule.settings,
      AppModule.whatsapp,
      AppModule.instagram,
    };
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider).valueOrNull;
    if (!_initializedFromPrefs && prefs != null) {
      _enabled = {...prefs.enabledModules};
      _initializedFromPrefs = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('স্বাগতম'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Softism Bot Manager',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Messenger, WhatsApp, Instagram — সবকিছুর জন্য একটাই কন্ট্রোল সেন্টার।',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 18),
          const Text(
            'আপনি কোন কোন মডিউল চালু রাখতে চান?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _moduleTile(
            module: AppModule.chat,
            title: 'Messenger Bot & Chat',
            subtitle: 'ইউনিফাইড ইনবক্স, লাইভ চ্যাট',
            forcedOn: true,
          ),
          _moduleTile(
            module: AppModule.whatsapp,
            title: 'WhatsApp Automation',
            subtitle: 'Phase 2 (UI প্রস্তুত)',
          ),
          _moduleTile(
            module: AppModule.instagram,
            title: 'Instagram DM',
            subtitle: 'Phase 2 (UI প্রস্তুত)',
          ),
          _moduleTile(
            module: AppModule.orders,
            title: 'Order Management',
            subtitle: 'অর্ডার তালিকা, স্ট্যাটাস আপডেট',
            forcedOn: true,
          ),
          _moduleTile(
            module: AppModule.analytics,
            title: 'Analytics',
            subtitle: 'Phase 2',
          ),
          _moduleTile(
            module: AppModule.products,
            title: 'Product Management',
            subtitle: 'Phase 2',
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () async {
              final notifier = ref.read(appPrefsProvider.notifier);
              await notifier.setEnabledModules(_enabled);
              await notifier.setOnboardingDone(true);
              if (context.mounted) context.go('/auth');
            },
            child: const Text('শুরু করি'),
          ),
          const SizedBox(height: 10),
          Text(
            'নোট: Chat/Bots/Orders/Settings সবসময় থাকবে — আপনি পরে Settings থেকে পরিবর্তন করতে পারবেন।',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _moduleTile({
    required AppModule module,
    required String title,
    String? subtitle,
    bool forcedOn = false,
  }) {
    final checked = _enabled.contains(module) || forcedOn;
    return Card(
      child: CheckboxListTile(
        value: checked,
        onChanged: forcedOn
            ? null
            : (v) {
                setState(() {
                  if (v == true) {
                    _enabled.add(module);
                  } else {
                    _enabled.remove(module);
                  }
                  // Core tabs always enabled in MVP.
                  _enabled.addAll(
                      {AppModule.chat, AppModule.bots, AppModule.orders, AppModule.settings});
                });
              },
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
      ),
    );
  }
}

