import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  int get _index {
    if (location.startsWith('/farm')) return 1;
    if (location.startsWith('/ai') || location.startsWith('/disease')) return 2;
    if (location.startsWith('/market') || location.startsWith('/cooperative') || location.startsWith('/logistics') || location.startsWith('/harvest') || location.startsWith('/analytics')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 76,
        onDestinationSelected: (index) {
          final route = switch (index) {
            0 => '/home',
            1 => '/farm',
            2 => '/ai',
            3 => '/market',
            _ => '/profile',
          };
          context.go(route);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: context.l10n.t('home')),
          NavigationDestination(icon: const Icon(Icons.grass_outlined), selectedIcon: const Icon(Icons.grass), label: context.l10n.t('farm')),
          NavigationDestination(
            icon: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [AgroColors.primaryGreen, AgroColors.ai]),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.auto_awesome, color: Colors.white),
              ),
            ),
            label: context.l10n.t('ai'),
          ),
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), selectedIcon: const Icon(Icons.storefront), label: context.l10n.t('market')),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: context.l10n.t('profile')),
        ],
      ),
    );
  }
}
