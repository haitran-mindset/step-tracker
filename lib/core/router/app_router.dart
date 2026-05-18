import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Riverpod provider for app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
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
