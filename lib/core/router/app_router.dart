import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/people/people_screen.dart';
import '../../features/people/add_person_screen.dart';
import '../../features/person_detail/person_detail_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/interactions/log_interaction_screen.dart';
import '../../features/settings/settings_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final initialLocationProvider = StateProvider<String>((ref) => '/dashboard');

@riverpod
GoRouter goRouter(Ref ref) {
  final initialLocation = ref.watch(initialLocationProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/people',
            builder: (context, state) => const PeopleScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddPersonScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return PersonDetailScreen(personId: id);
                },
                routes: [
                  GoRoute(
                    path: 'log',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return LogInteractionScreen(personId: id);
                    },
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return AddPersonScreen(personId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _calculateSelectedIndex(context),
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/people');
                break;
              case 2:
                context.go('/analytics');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.bell),
              selectedIcon: Icon(LucideIcons.bellRing),
              label: 'Reminders',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              selectedIcon: Icon(LucideIcons.users),
              label: 'Contacts',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.barChart2),
              selectedIcon: Icon(LucideIcons.barChart2),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) {
      return 0;
    }
    if (location.startsWith('/people')) {
      return 1;
    }
    if (location.startsWith('/analytics')) {
      return 2;
    }
    return 0;
  }
}
