import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/agro_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class CooperativeScreen extends ConsumerWidget {
  const CooperativeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final cooperative = ref.read(cooperativeServiceProvider);
    final logistics = ref.watch(logisticsServiceProvider);
    final currentFarm = repo.farms.isEmpty ? null : repo.farms.first;
    final crop = currentFarm?.currentCrop ?? 'Tomato';
    final joinedGroup = repo.groups.where((group) => group.joined).firstOrNull;
    final recommendedGroup = joinedGroup ?? repo.groups.first;
    final bestPrice = repo.marketPrices
        .where((price) => price.crop.toLowerCase() == crop.toLowerCase())
        .fold<MarketPrice?>(null, (best, price) => best == null || price.price > best.price ? price : best);
    final selectedBuyer = repo.buyers
        .where((buyer) => buyer.crop.toLowerCase() == crop.toLowerCase())
        .fold<Buyer?>(null, (best, buyer) => best == null || buyer.offerPerKg > best.offerPerKg ? buyer : best);
    final loads = [
      FarmerLoad(repo.farmer.fullName.split(' ').first, 3000),
      const FarmerLoad('Suresh', 2200),
      const FarmerLoad('Mahesh', 2800),
      const FarmerLoad('Anita', 1700),
    ];
    final shares = logistics.splitTransportCost(totalCost: 9800, loads: loads);
    final allocated = logistics.allocateTrucks(recommendedGroup.combinedTonnes, repo.trucks);
    final route = logistics.optimizeRoute(const [
      RouteStop('Depot', 20.00, 73.79),
      RouteStop('Green Valley', 20.05, 73.80),
      RouteStop('Sai Farm', 19.95, 73.85),
      RouteStop('APMC Gate', 20.01, 73.77),
    ]);
    final scores = {
      'Crop match': cooperative.compatibilityScore(
        crop: crop,
        otherCrop: recommendedGroup.crop,
        harvestDate: DateTime(2026, 3, 23),
        otherHarvestDate: DateTime(2026, 3, 24),
        distanceKm: 4,
        market: bestPrice?.market ?? recommendedGroup.destination,
        otherMarket: recommendedGroup.destination,
      ),
      'Harvest window': 88.0,
      'Route fit': 84.0,
      'Buyer demand': 91.0,
    };
    final individualOffer = (selectedBuyer?.offerPerKg ?? 24) - 2;
    final groupOffer = selectedBuyer?.offerPerKg ?? 24;
    final extraRevenue = recommendedGroup.combinedTonnes * 1000 * (groupOffer - individualOffer);

    return ScreenScaffold(
      title: 'Smart Farmer Cooperative',
      actions: [
        AgroIconButton(icon: Icons.storefront_outlined, tooltip: 'Marketplace', onPressed: () => context.push('/market')),
        AgroIconButton(icon: Icons.local_shipping_outlined, tooltip: 'Logistics', onPressed: () => context.push('/logistics')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FeatureChecklist(),
          const SizedBox(height: 14),
          _FlowTracker(joined: joinedGroup != null, hasListing: repo.listings.isNotEmpty),
          const SizedBox(height: 14),
          _MarketListingStage(crop: crop, bestPrice: bestPrice, listing: repo.listings.isEmpty ? null : repo.listings.last),
          const AgroSectionHeader(title: 'Join Cooperative'),
          _GroupingStage(groups: repo.groups, scores: scores),
          const AgroSectionHeader(title: 'Shared Logistics'),
          _SharedLogisticsStage(group: recommendedGroup, allocated: allocated, route: route, shares: shares),
          const AgroSectionHeader(title: 'Sell & Schedule Pickup'),
          _SellingStage(
            crop: crop,
            buyer: selectedBuyer,
            group: recommendedGroup,
            individualOffer: individualOffer,
            groupOffer: groupOffer,
            extraRevenue: extraRevenue,
          ),
          const AgroSectionHeader(title: 'Analytics'),
          _CooperativeAnalyticsStage(
            group: recommendedGroup,
            bestPrice: bestPrice,
            extraRevenue: extraRevenue,
            averageScore: scores.values.fold<double>(0.0, (sum, score) => sum + score) / scores.length,
          ),
        ],
      ),
    );
  }
}

class _FeatureChecklist extends StatelessWidget {
  const _FeatureChecklist();

  @override
  Widget build(BuildContext context) {
    const features = [
      'Automatic Farmer Grouping',
      'Shared Transportation',
      'Route Optimization',
      'Transportation Cost Splitting',
      'Joint Selling',
      'Truck Allocation',
      'Pickup Scheduling',
    ];
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t('Modules 16 + 17 Merged'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features.map((feature) => AgroStatusBadge(label: feature, color: feature.contains('Transport') || feature.contains('Truck') ? AgroColors.warm : AgroColors.primaryGreen)).toList(),
          ),
        ],
      ),
    );
  }
}

class _FlowTracker extends StatelessWidget {
  const _FlowTracker({required this.joined, required this.hasListing});

  final bool joined;
  final bool hasListing;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _FlowStep('Marketplace', hasListing),
      _FlowStep('Join Group', joined),
      const _FlowStep('Logistics', true),
      const _FlowStep('Pickup', true),
      const _FlowStep('Analytics', true),
    ];
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t('Cooperative Flow'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: steps
                .map(
                  (step) => Chip(
                    avatar: Icon(step.done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18),
                    label: Text(context.l10n.t(step.label)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MarketListingStage extends StatelessWidget {
  const _MarketListingStage({required this.crop, required this.bestPrice, required this.listing});

  final String crop;
  final MarketPrice? bestPrice;
  final MarketListing? listing;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.price_check_outlined, color: AgroColors.primaryGreen),
              const SizedBox(width: 10),
              Expanded(child: Text(context.l10n.t('Market Prices & Produce Listing'), style: Theme.of(context).textTheme.titleLarge)),
            ],
          ),
          const SizedBox(height: 10),
          Text(bestPrice == null ? '${context.l10n.t('No live price found for')} ${context.l10n.t(crop)}.' : '${context.l10n.t(crop)} ${context.l10n.t('best nearby price')}: Rs ${bestPrice!.price}/kg ${context.l10n.t('at')} ${bestPrice!.market}.'),
          const SizedBox(height: 8),
          Text(listing == null ? context.l10n.t('Create a produce listing before cooperative matching.') : '${context.l10n.t('Listed')}: ${listing!.quantityTonnes} ${context.l10n.t('tonnes')} ${context.l10n.t(listing!.crop)} ${context.l10n.t('at')} Rs ${listing!.pricePerKg}/kg.'),
          const SizedBox(height: 12),
          AgroButton(label: listing == null ? 'Create Listing' : 'Open Marketplace', icon: Icons.add_business_outlined, onPressed: () => context.push('/market')),
        ],
      ),
    );
  }
}

class _GroupingStage extends ConsumerWidget {
  const _GroupingStage({required this.groups, required this.scores});

  final List<CooperativeGroup> groups;
  final Map<String, double> scores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ...groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AgroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(group.name, style: Theme.of(context).textTheme.titleLarge)),
                      AgroStatusBadge(label: group.joined ? 'Joined' : 'Recommended', color: group.joined ? AgroColors.primaryGreen : AgroColors.ai),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${group.farmers} ${context.l10n.t('farmers')} | ${group.combinedTonnes} ${context.l10n.t('tonnes')} | ${context.l10n.t(group.crop)}'),
                  Text('${context.l10n.t('Window')}: ${group.harvestWindow} | ${context.l10n.t('Market')}: ${group.destination}'),
                  Text('${context.l10n.t('Transport saving')}: Rs ${group.saving.toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/market'), icon: const Icon(Icons.storefront_outlined), label: Text(context.l10n.t('Prices')))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: group.joined ? null : () => ref.read(demoRepositoryProvider).joinGroup(group.id),
                          icon: Icon(group.joined ? Icons.check : Icons.group_add_outlined),
                          label: Text(context.l10n.t(group.joined ? 'Joined' : 'Join')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        AgroCard(
          child: Column(
            children: scores.entries
                .map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.t(entry.key)),
                    subtitle: LinearProgressIndicator(value: entry.value / 100, borderRadius: BorderRadius.circular(999)),
                    trailing: Text('${entry.value.round()}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SharedLogisticsStage extends StatelessWidget {
  const _SharedLogisticsStage({required this.group, required this.allocated, required this.route, required this.shares});

  final CooperativeGroup group;
  final List<Truck> allocated;
  final List<RouteStop> route;
  final List<CostShare> shares;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.l10n.t('Shared load')}: ${group.combinedTonnes} ${context.l10n.t('tonnes')} ${context.l10n.t('to')} ${group.destination}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text('${context.l10n.t('Optimized route')}: ${route.map((stop) => stop.name).join(' -> ')}'),
          const SizedBox(height: 10),
          Text(context.l10n.t('Truck allocation'), style: Theme.of(context).textTheme.titleMedium),
          ...allocated.map((truck) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.local_shipping_outlined), title: Text(truck.name), subtitle: Text('${truck.capacityTonnes} T | ${truck.status}'), trailing: Text('Rs ${truck.price.toStringAsFixed(0)}'))),
          const Divider(),
          Text(context.l10n.t('Cost splitting'), style: Theme.of(context).textTheme.titleMedium),
          ...shares.map((share) => ListTile(contentPadding: EdgeInsets.zero, title: Text(share.name), subtitle: Text('${share.loadKg.toStringAsFixed(0)} kg'), trailing: Text('Rs ${share.cost.toStringAsFixed(0)}'))),
          const SizedBox(height: 8),
          AgroButton(label: 'Open Logistics Plan', icon: Icons.route_outlined, onPressed: () => context.push('/logistics')),
        ],
      ),
    );
  }
}

class _SellingStage extends StatelessWidget {
  const _SellingStage({
    required this.crop,
    required this.buyer,
    required this.group,
    required this.individualOffer,
    required this.groupOffer,
    required this.extraRevenue,
  });

  final String crop;
  final Buyer? buyer;
  final CooperativeGroup group;
  final double individualOffer;
  final double groupOffer;
  final double extraRevenue;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(buyer?.name ?? context.l10n.t('Verified buyer pool'), style: Theme.of(context).textTheme.titleLarge),
          Text('${context.l10n.t('Joint selling crop')}: ${context.l10n.t(crop)} | ${context.l10n.t('Quantity')}: ${group.combinedTonnes} ${context.l10n.t('tonnes')}'),
          Text('${context.l10n.t('Individual offer')}: Rs ${individualOffer.toStringAsFixed(1)}/kg'),
          Text('${context.l10n.t('Group negotiated offer')}: Rs ${groupOffer.toStringAsFixed(1)}/kg'),
          Text('${context.l10n.t('Extra revenue')}: Rs ${extraRevenue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule), title: Text('${context.l10n.t('Pickup')} 1'), subtitle: const Text('Green Valley Farm'), trailing: const Text('06:30 AM')),
                const Divider(),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule), title: Text('${context.l10n.t('Pickup')} 2'), subtitle: const Text('Sai Farm'), trailing: const Text('07:10 AM')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => _show(context, context.l10n.t('Joint selling offer accepted.')), icon: const Icon(Icons.handshake_outlined), label: Text(context.l10n.t('Accept')))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => _show(context, context.l10n.t('Pickup schedule confirmed.')), icon: const Icon(Icons.event_available), label: Text(context.l10n.t('Schedule')))),
            ],
          ),
        ],
      ),
    );
  }

  void _show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t(message))));
  }
}

class _CooperativeAnalyticsStage extends StatelessWidget {
  const _CooperativeAnalyticsStage({required this.group, required this.bestPrice, required this.extraRevenue, required this.averageScore});

  final CooperativeGroup group;
  final MarketPrice? bestPrice;
  final double extraRevenue;
  final double averageScore;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        AgroMetricCard(label: 'Grouping Score', value: '${averageScore.round()}%', icon: Icons.groups_2),
        AgroMetricCard(label: 'Transport Saving', value: 'Rs ${group.saving.toStringAsFixed(0)}', icon: Icons.savings_outlined, color: AgroColors.warm),
        AgroMetricCard(label: 'Extra Revenue', value: 'Rs ${extraRevenue.toStringAsFixed(0)}', icon: Icons.trending_up),
        AgroMetricCard(label: 'Market Risk', value: bestPrice == null ? 'MEDIUM' : 'LOW', icon: Icons.warning_amber_outlined, color: bestPrice == null ? AgroColors.warning : AgroColors.primaryGreen),
      ],
    );
  }
}

class _FlowStep {
  const _FlowStep(this.label, this.done);

  final String label;
  final bool done;
}
