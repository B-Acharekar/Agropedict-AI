import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))..forward();
    Future<void>.delayed(const Duration(milliseconds: 1500), () async {
      final picked = await AppLanguageController.hasPickedLanguage();
      if (mounted) context.go(picked ? '/onboarding' : '/language');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AgroColors.forest, AgroColors.primaryGreen, AgroColors.freshGreen],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _controller,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.eco, color: Colors.white, size: 56),
                        Positioned(right: 28, top: 27, child: Icon(Icons.memory, color: AgroColors.lime, size: 24)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(AppConfig.appName, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      AppConfig.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
