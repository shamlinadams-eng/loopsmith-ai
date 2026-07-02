import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/browser_provider.dart';
import '../providers/generator_provider.dart';
import '../screens/account_screen.dart';
import '../screens/assistant_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/browser_screen.dart';
import '../screens/community_screen.dart';
import '../screens/generator_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/subscribe_screen.dart';
import '../services/audio_player_service.dart';
import '../services/loop_service.dart';
import '../widgets/common/app_shell.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // ── Pre-auth flow ────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/subscribe',
        builder: (context, state) => const SubscribeScreen(),
      ),

      // ── Main shell (bottom nav) ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/generate',
                builder: (context, state) {
                  final service = context.read<LoopService>();
                  final audio = context.read<AudioPlayerService>();
                  return ChangeNotifierProvider(
                    create: (_) => GeneratorProvider(service: service, audio: audio),
                    child: const GeneratorScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browser',
                builder: (context, state) {
                  final service = context.read<LoopService>();
                  final audio = context.read<AudioPlayerService>();
                  return ChangeNotifierProvider(
                    create: (_) => BrowserProvider(service: service, audio: audio),
                    child: const BrowserScreen(),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
