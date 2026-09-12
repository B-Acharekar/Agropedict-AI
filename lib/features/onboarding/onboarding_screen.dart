import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _items = const [
    _OnboardItem(Icons.dashboard_customize, 'onboardFarmTitle', 'onboardFarmBody'),
    _OnboardItem(Icons.auto_awesome, 'onboardAiTitle', 'onboardAiBody'),
    _OnboardItem(Icons.groups_2, 'onboardCoopTitle', 'onboardCoopBody'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => context.go('/login'), child: Text(context.l10n.t('onboardingSkip'))),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 210,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: LinearGradient(colors: [AgroColors.primaryGreen.withOpacity(0.16), AgroColors.ai.withOpacity(0.18)]),
                          ),
                          child: Icon(item.icon, size: 96, color: AgroColors.primaryGreen),
                        ),
                        const SizedBox(height: 36),
                        Text(context.l10n.t(item.title), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 14),
                        Text(context.l10n.t(item.body), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: _page == index ? 28 : 9,
                    height: 9,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: _page == index ? AgroColors.primaryGreen : AgroColors.lightGreen, borderRadius: BorderRadius.circular(999)),
                  );
                }),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () {
                  if (_page == _items.length - 1) {
                    context.go('/login');
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  }
                },
                child: Text(_page == _items.length - 1 ? context.l10n.t('onboardingStart') : context.l10n.t('onboardingNext')),
              ),
              const SizedBox(height: 10),
              Text(context.l10n.t(AppConfig.tagline), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardItem {
  const _OnboardItem(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}
