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
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE6ECF1), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          height: 64,
          indicatorColor: const Color(0xFFE7F1FB), // NeoPalette.skyBg
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              icon: Icon(LucideIcons.home, size: 20),
              selectedIcon: Icon(LucideIcons.home, size: 20, color: Color(0xFF0284C7)),
              label: 'Hub',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users, size: 20),
              selectedIcon: Icon(LucideIcons.users, size: 20, color: Color(0xFF0284C7)),
              label: 'Circle',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.pieChart, size: 20),
              selectedIcon: Icon(LucideIcons.pieChart, size: 20, color: Color(0xFF0284C7)),
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
