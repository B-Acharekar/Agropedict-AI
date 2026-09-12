import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('Cooperative & Marketplace')),
        actions: [
          IconButton(onPressed: () => context.push('/cooperative'), icon: const Icon(Icons.groups_2_outlined)),
          IconButton(onPressed: () => context.push('/logistics'), icon: const Icon(Icons.local_shipping_outlined)),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [Tab(text: context.l10n.t('Sell')), Tab(text: context.l10n.t('Buyers')), Tab(text: context.l10n.t('Orders')), Tab(text: context.l10n.t('Prices')), Tab(text: context.l10n.t('Co-op'))],
        ),
      ),
      body: TabBarView(controller: _tabs, children: const [_SellTab(), _BuyersTab(), _OrdersTab(), _PricesTab(), _CooperativeTab()]),
    );
  }
}

class _SellTab extends ConsumerStatefulWidget {
  const _SellTab();

  @override
  ConsumerState<_SellTab> createState() => _SellTabState();
}

class _SellTabState extends ConsumerState<_SellTab> {
  final _crop = TextEditingController(text: 'Tomato');
  final _variety = TextEditingController(text: 'Hybrid');
  final _qty = TextEditingController(text: '3.4');
  final _price = TextEditingController(text: '24');
  final _grade = TextEditingController(text: 'A');

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(demoRepositoryProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        AgroCard(
          child: Column(
            children: [
              AgroTextField(controller: _crop, label: 'Crop', icon: Icons.grass_outlined),
              const SizedBox(height: 12),
              AgroTextField(controller: _variety, label: 'Variety', icon: Icons.eco_outlined),
              const SizedBox(height: 12),
              AgroTextField(controller: _qty, label: 'Quantity tonnes', icon: Icons.scale_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AgroTextField(controller: _price, label: 'Price per kg', icon: Icons.currency_rupee, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AgroTextField(controller: _grade, label: 'Quality Grade', icon: Icons.verified_outlined),
              const SizedBox(height: 14),
              AgroButton(
                label: 'Create Listing',
                icon: Icons.add_business_outlined,
                onPressed: () => ref.read(demoRepositoryProvider).createListing(MarketListing(id: DateTime.now().microsecondsSinceEpoch.toString(), crop: _crop.text, variety: _variety.text, quantityTonnes: double.tryParse(_qty.text) ?? 0, pricePerKg: double.tryParse(_price.text) ?? 0, grade: _grade.text, availableDate: DateTime.now().add(const Duration(days: 5)), farm: 'Green Valley Farm')),
              ),
            ],
          ),
        ),
        const AgroSectionHeader(title: 'Your Listings'),
        if (repo.listings.isEmpty)
          AgroEmptyState(title: 'No crop listings', message: 'Create a sale listing so verified buyers can discover your produce.', actionLabel: 'Create Above', onAction: () {})
        else
          ...repo.listings.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgroCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text('${context.l10n.t(item.crop)} ${context.l10n.t(item.variety)}'), subtitle: Text('${item.quantityTonnes} ${context.l10n.t('tonnes')} | ${context.l10n.t('Grade')} ${item.grade} | ${item.farm}'), trailing: Text('Rs ${item.pricePerKg}/kg'))))),
      ],
    );
  }
}

class _BuyersTab extends ConsumerWidget {
  const _BuyersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buyers = ref.watch(demoRepositoryProvider).buyers;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: buyers.map((buyer) => Padding(padding: const EdgeInsets.only(bottom: 12), child: BuyerCard(buyer: buyer))).toList(),
    );
  }
}

class BuyerCard extends StatelessWidget {
  const BuyerCard({required this.buyer, super.key});
  final Buyer buyer;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(buyer.name, style: Theme.of(context).textTheme.titleLarge)), if (buyer.verified) const AgroStatusBadge(label: 'Verified')]),
          const SizedBox(height: 8),
          Text('${context.l10n.t('Buying')}: ${context.l10n.t(buyer.crop)} | ${context.l10n.t('Quantity')}: ${buyer.quantityTonnes} ${context.l10n.t('tonnes')} | ${context.l10n.t('Distance')}: ${buyer.distanceKm} km'),
          const SizedBox(height: 8),
          Text('${context.l10n.t('Offer')}: Rs ${buyer.offerPerKg}/kg', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {}, child: Text(context.l10n.t('View')))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () {}, child: Text(context.l10n.t('Negotiate')))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${context.l10n.t('Offer accepted from')} ${buyer.name}.'))), child: Text(context.l10n.t('Accept')))),
          ]),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        AgroCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.receipt_long), title: Text('${context.l10n.t('FreshKart Foods')} - ${context.l10n.t('Tomato')}'), subtitle: Text('${context.l10n.t('Confirmed')} | 3 ${context.l10n.t('tonnes')} | ${context.l10n.t('Pickup')} 23 ${context.l10n.t('March')}'), trailing: const Text('Rs 72,000'))),
      ],
    );
  }
}

class _PricesTab extends ConsumerWidget {
  const _PricesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        SizedBox(
          height: 220,
          child: AgroCard(
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(1, 22), FlSpot(2, 23), FlSpot(3, 25), FlSpot(4, 24), FlSpot(5, 20)],
                  isCurved: true,
                  color: AgroColors.primaryGreen,
                  barWidth: 4,
                ),
              ],
            )),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: ['1D', '7D', '1M', '3M'].map((e) => ChoiceChip(label: Text(e), selected: e == '7D')).toList()),
        const AgroSectionHeader(title: 'Nearby Markets'),
        ...repo.marketPrices.map((price) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgroCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text('${price.crop} - ${price.market}'), trailing: AgroStatusBadge(label: '${price.changePercent >= 0 ? '+' : ''}${price.changePercent}%', color: price.changePercent >= 0 ? AgroColors.primaryGreen : AgroColors.danger), subtitle: Text('Rs ${price.price}/kg'))))),
      ],
    );
  }
}

class _CooperativeTab extends ConsumerWidget {
  const _CooperativeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final joined = repo.groups.where((group) => group.joined).firstOrNull;
    final group = joined ?? repo.groups.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
      children: [
        AgroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.t('Smart Farmer Cooperative'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('${group.name} | ${group.farmers} ${context.l10n.t('farmers')} | ${group.combinedTonnes} ${context.l10n.t('tonnes')}'),
              Text('${context.l10n.t('Shared transport to')} ${group.destination}'),
              Text('${context.l10n.t('Savings')}: Rs ${group.saving.toStringAsFixed(0)}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AgroStatusBadge(label: 'Automatic Grouping'),
                  AgroStatusBadge(label: 'Shared Transport', color: AgroColors.warm),
                  AgroStatusBadge(label: 'Joint Selling'),
                  AgroStatusBadge(label: 'Pickup Scheduling', color: AgroColors.warm),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(onPressed: () => context.push('/cooperative'), icon: const Icon(Icons.groups_2_outlined), label: Text(context.l10n.t('Open Co-op')))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/logistics'), icon: const Icon(Icons.local_shipping_outlined), label: Text(context.l10n.t('Transport')))),
                ],
              ),
            ],
          ),
        ),
        const AgroSectionHeader(title: 'Flow'),
        const AgroCard(
          child: Column(
            children: [
              _FlowTile(icon: Icons.price_check_outlined, title: 'Market Prices / Produce Listing'),
              Divider(),
              _FlowTile(icon: Icons.group_add_outlined, title: 'Join Cooperative'),
              Divider(),
              _FlowTile(icon: Icons.local_shipping_outlined, title: 'Shared Logistics & Truck Allocation'),
              Divider(),
              _FlowTile(icon: Icons.route_outlined, title: 'Route Optimization & Cost Splitting'),
              Divider(),
              _FlowTile(icon: Icons.event_available, title: 'Sell / Schedule Pickup'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowTile extends StatelessWidget {
  const _FlowTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AgroColors.primaryGreen),
      title: Text(context.l10n.t(title), style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.check_circle_outline, color: AgroColors.warm),
    );
  }
}
