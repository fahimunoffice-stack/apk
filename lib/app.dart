import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/app_prefs_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/store_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/store/store_setup_screen.dart';
import 'utils/constants.dart';
import 'utils/go_router_refresh_stream.dart';

class SoftismBotManagerApp extends ConsumerStatefulWidget {
  const SoftismBotManagerApp({super.key});

  @override
  ConsumerState<SoftismBotManagerApp> createState() =>
      _SoftismBotManagerAppState();
}

class _SoftismBotManagerAppState extends ConsumerState<SoftismBotManagerApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(
        Supabase.instance.client.auth.onAuthStateChange,
      ),
      redirect: (context, state) async {
        final prefsAsync = ref.read(appPrefsProvider);
        final prefs = prefsAsync.valueOrNull;

        // While prefs are loading, keep splash.
        if (prefs == null) {
          return state.matchedLocation == '/splash' ? null : '/splash';
        }

        final session = Supabase.instance.client.auth.currentSession;
        final loggedIn = session != null;

        final isSplash = state.matchedLocation == '/splash';
        final isOnboarding = state.matchedLocation == '/onboarding';
        final isAuth = state.matchedLocation == '/auth';
        final isStoreSetup = state.matchedLocation == '/store-setup';

        if (!prefs.onboardingDone) {
          return isOnboarding ? null : '/onboarding';
        }

        if (!loggedIn) {
          return isAuth ? null : '/auth';
        }

        // Logged in: ensure store exists.
        final store = await ref.read(myStoreProvider.future);
        if (store == null) {
          return isStoreSetup ? null : '/store-setup';
        }

        // If already good, never stay on splash/auth/store-setup/onboarding.
        if (isSplash || isAuth || isStoreSetup || isOnboarding) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const _SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/store-setup',
          builder: (_, __) => const StoreSetupScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'chat/:conversationId',
              builder: (_, s) => ChatDetailScreen(
                conversationId: s.pathParameters['conversationId']!,
              ),
            ),
            GoRoute(
              path: 'orders/:orderId',
              builder: (_, s) => OrderDetailScreen(
                orderId: s.pathParameters['orderId']!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider).valueOrNull;
    final themeMode = prefs?.themeMode ?? ThemeMode.dark;

    final textTheme =
        GoogleFonts.hindSiliguriTextTheme(Theme.of(context).textTheme);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Softism Bot Manager',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: textTheme,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: textTheme,
      ),
      routerConfig: _router,
    );
  }
}

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPrefsProvider);
    ref.watch(authStateProvider);
    ref.watch(currentUserProvider);
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

