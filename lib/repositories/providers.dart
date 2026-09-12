import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/agro_services.dart';
import 'demo_repository.dart';

final demoRepositoryProvider = ChangeNotifierProvider<DemoRepository>((ref) => DemoRepository());
final aiServiceProvider = Provider<AgroAiService>((ref) => AgroAiService());
final visionServiceProvider = Provider<VisionService>((ref) => const VisionService());
final logisticsServiceProvider = Provider<LogisticsService>((ref) => const LogisticsService());
final cooperativeServiceProvider = Provider<CooperativeService>((ref) => const CooperativeService());
final harvestServiceProvider = Provider<HarvestService>((ref) => const HarvestService());
