import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/graph/graph_screen.dart';
import '../../features/people/people_screen.dart';
import '../../features/people/add_person_screen.dart';
import '../../features/person_detail/person_detail_screen.dart';
import '../../features/interactions/log_interaction_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
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
                builder: (context, state) {
                  final linkToPersonIdStr =
                      state.uri.queryParameters['linkToPersonId'];
                  final linkToPersonId = linkToPersonIdStr != null
                      ? int.tryParse(linkToPersonIdStr)
                      : null;
                  return AddPersonScreen(linkToPersonId: linkToPersonId);
                },
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
            path: '/graph',
            builder: (context, state) => const GraphScreen(),
          ),
        ],
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
                context.go('/graph');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard),
              selectedIcon: Icon(LucideIcons.layoutDashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              selectedIcon: Icon(LucideIcons.users),
              label: 'People',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.network),
              selectedIcon: Icon(LucideIcons.network),
              label: 'Network',
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
    if (location.startsWith('/graph')) {
      return 2;
    }
    return 0;
  }
}
