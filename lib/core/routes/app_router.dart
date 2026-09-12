import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_assistant/ai_assistant_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/cooperative/cooperative_screen.dart';
import '../../features/digital_farm/farm_screens.dart';
import '../../features/disease_detection/disease_detection_screen.dart';
import '../../features/harvest_planner/harvest_planner_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/logistics/logistics_screen.dart';
import '../../features/language/language_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/schemes/schemes_screen.dart';
import '../../features/search/global_search_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/farmer_profile/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/language',
        builder: (context, state) => LanguageScreen(returnToProfile: state.uri.queryParameters['return'] == 'profile'),
      ),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (context, state) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/farm', builder: (context, state) => const FarmDashboardScreen()),
          GoRoute(path: '/farm/new', builder: (context, state) => const AddFarmScreen()),
          GoRoute(path: '/farm/history', builder: (context, state) => const CropHistoryScreen()),
          GoRoute(path: '/farm/soil', builder: (context, state) => const SoilInfoScreen()),
          GoRoute(path: '/farm/irrigation', builder: (context, state) => const IrrigationScreen()),
          GoRoute(path: '/farm/yield', builder: (context, state) => const YieldRecordScreen()),
          GoRoute(path: '/ai', builder: (context, state) => const AiAssistantScreen()),
          GoRoute(path: '/disease', builder: (context, state) => const DiseaseDetectionScreen()),
          GoRoute(path: '/market', builder: (context, state) => const MarketplaceScreen()),
          GoRoute(path: '/cooperative', builder: (context, state) => const CooperativeScreen()),
          GoRoute(path: '/logistics', builder: (context, state) => const LogisticsScreen()),
          GoRoute(path: '/harvest', builder: (context, state) => const HarvestPlannerScreen()),
          GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/schemes', builder: (context, state) => const SchemesScreen()),
          GoRoute(path: '/search', builder: (context, state) => const GlobalSearchScreen()),
        ],
      ),
    ],
  );
});
