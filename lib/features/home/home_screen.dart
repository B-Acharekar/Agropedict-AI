import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../repositories/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final farm = repo.farms.isEmpty ? null : repo.farms.first;
    return ScreenScaffold(
      title: 'AgroPredict AI',
      actions: [
        AgroIconButton(icon: Icons.search, tooltip: context.l10n.t('search'), onPressed: () => context.push('/search')),
        AgroIconButton(icon: Icons.notifications_outlined, tooltip: context.l10n.t('notifications'), onPressed: () => context.push('/notifications')),
      ],
      floatingActionButton: AiFloatingButton(onPressed: () => context.push('/ai')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.l10n.t('goodMorning')}, ${repo.farmer.fullName.split(' ').first}', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('${context.l10n.t('village')}: ${repo.farmer.village}, ${repo.farmer.state}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          const WeatherCard(),
          AgroSectionHeader(title: context.l10n.t('farmHealth')),
          FarmHealthCard(score: repo.farmHealthScore),
          AgroSectionHeader(title: context.l10n.t('quickActions')),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _QuickAction(icon: Icons.auto_awesome, label: context.l10n.t('askAi'), onTap: () => context.push('/ai')),
              _QuickAction(icon: Icons.camera_alt_outlined, label: context.l10n.t('scan'), onTap: () => context.push('/disease')),
              _QuickAction(icon: Icons.event_available, label: context.l10n.t('harvest'), onTap: () => context.push('/harvest')),
              _QuickAction(icon: Icons.sell_outlined, label: context.l10n.t('sell'), onTap: () => context.push('/market')),
              _QuickAction(icon: Icons.groups_2_outlined, label: context.l10n.t('coop'), onTap: () => context.push('/cooperative')),
              _QuickAction(icon: Icons.local_shipping_outlined, label: context.l10n.t('truck'), onTap: () => context.push('/logistics')),
              _QuickAction(icon: Icons.account_balance_outlined, label: context.l10n.t('schemes'), onTap: () => context.push('/schemes')),
              _QuickAction(icon: Icons.analytics_outlined, label: context.l10n.t('reports'), onTap: () => context.push('/analytics')),
            ],
          ),
          AgroSectionHeader(title: context.l10n.t('currentCrop')),
          if (farm == null)
            AgroEmptyState(title: 'No active crop', message: 'Add a farm digital twin to track crop progress.', actionLabel: 'Add Farm', onAction: () => context.push('/farm/new'))
          else
            CropProgressCard(farm: farm),
          AgroSectionHeader(title: context.l10n.t('smartInsights')),
          SizedBox(
            height: 158,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _InsightCard(title: 'Fertilizer Alert', body: 'Tomato crop may require nitrogen supplementation this week.', color: AgroColors.warm),
                _InsightCard(title: 'Weather Alert', body: 'Rain is expected within 48 hours. Delay irrigation.', color: AgroColors.ai),
                _InsightCard(title: 'Market Alert', body: 'Tomato prices increased 8.4% in your nearby market.', color: AgroColors.primaryGreen),
                _InsightCard(title: 'Harvest Alert', body: 'Expected harvest window starts in approximately 12 days.', color: AgroColors.earth),
              ],
            ),
          ),
          AgroSectionHeader(title: context.l10n.t('marketPrices')),
          ...repo.marketPrices.take(3).map(
                (price) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AgroCard(
                    onTap: () => context.push('/market'),
                    child: Row(
                      children: [
                        Expanded(child: Text('${price.crop}\n${price.market}', style: const TextStyle(fontWeight: FontWeight.w700))),
                        Text('Rs ${price.price.toStringAsFixed(2)}/kg', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 8),
                        AgroStatusBadge(label: '${price.changePercent >= 0 ? '+' : ''}${price.changePercent}%', color: price.changePercent >= 0 ? AgroColors.primaryGreen : AgroColors.danger),
                      ],
                    ),
                  ),
                ),
              ),
          AgroSectionHeader(title: context.l10n.t('upcomingTasks')),
          const AgroCard(
            child: Column(
              children: [
                _TaskTile(icon: Icons.water_drop_outlined, title: 'Irrigation', subtitle: 'Tomorrow morning, 45 minutes'),
                Divider(),
                _TaskTile(icon: Icons.local_shipping_outlined, title: 'Cooperative pickup', subtitle: '23 March, 06:30 AM'),
                Divider(),
                _TaskTile(icon: Icons.biotech_outlined, title: 'Disease prevention spray', subtitle: 'After rainfall clears'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Row(
        children: [
          const Icon(Icons.wb_cloudy_outlined, size: 52, color: AgroColors.ai),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('28°C', style: Theme.of(context).textTheme.headlineMedium),
                Text(context.l10n.t('Partly Cloudy')),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: const [
                    _MiniMetric('Humidity', '68%'),
                    _MiniMetric('Rain Chance', '32%'),
                    _MiniMetric('Wind', '12 km/h'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FarmHealthCard extends StatelessWidget {
  const FarmHealthCard({required this.score, super.key});
  final int score;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(value: score / 100, strokeWidth: 9, color: AgroColors.primaryGreen, backgroundColor: AgroColors.lightGreen.withOpacity(0.25)),
                Center(child: Text('$score', style: Theme.of(context).textTheme.titleLarge)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('82 / 100', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 6),
                const AgroStatusBadge(label: 'GOOD'),
                const SizedBox(height: 8),
                Text(context.l10n.t('Soil and crop signals are stable. Keep watching nitrogen and rain timing.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CropProgressCard extends StatelessWidget {
  const CropProgressCard({required this.farm, super.key});
  final dynamic farm;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(context.l10n.t(farm.currentCrop), style: Theme.of(context).textTheme.headlineMedium)),
              const AgroStatusBadge(label: 'Flowering'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: farm.progress, minHeight: 10, borderRadius: BorderRadius.circular(999)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _MiniMetric('Day', '${farm.cropDay} / ${farm.cropDuration}'),
              _MiniMetric('Farm', farm.name),
              _MiniMetric('Area', '${farm.landSize} ${farm.unit}'),
              _MiniMetric('Yield', '${farm.predictedYieldTonnes} ${context.l10n.t('tonnes')}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      padding: const EdgeInsets.all(8),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AgroColors.primaryGreen),
          const SizedBox(height: 6),
          FittedBox(child: Text(context.l10n.t(label), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.body, required this.color});
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      child: AgroCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AgroStatusBadge(label: 'AI', color: color),
            const SizedBox(height: 12),
            Text(context.l10n.t(title), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(context.l10n.t(body), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.t(label), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(context.l10n.t(value), style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AgroColors.primaryGreen),
      title: Text(context.l10n.t(title), style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(context.l10n.t(subtitle)),
    );
  }
}
