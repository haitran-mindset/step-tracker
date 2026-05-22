import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/setup_profile_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Helper class to refresh GoRouter on auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Riverpod provider for app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuth = user != null;
      final loc = state.matchedLocation;
      final isAuthPage = loc == '/login' || loc == '/register' || loc == '/setup-profile';

      if (!isAuth && !isAuthPage) return '/login';
      if (isAuth && (loc == '/login' || loc == '/register')) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPage(
          const LoginPage(),
          state,
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildPage(
          const RegisterPage(),
          state,
        ),
      ),
      GoRoute(
        path: '/setup-profile',
        pageBuilder: (context, state) => _buildPage(
          const SetupProfilePage(),
          state,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _buildPage(
              const DashboardPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/statistics',
            pageBuilder: (context, state) => _buildPage(
              const StatisticsPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => _buildPage(
              const GoalsPage(),
              state,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _buildPage(
              const ProfilePage(),
              state,
            ),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
