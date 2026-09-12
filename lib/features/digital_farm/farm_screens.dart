import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/agro_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../features/auth/auth_screens.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class FarmDashboardScreen extends ConsumerWidget {
  const FarmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final averageSoilHealth = repo.farms.isEmpty ? 0 : (repo.farms.fold<int>(0, (sum, farm) => sum + farm.soilHealth) / repo.farms.length).round();
    return ScreenScaffold(
      title: 'Farm Digital Twin',
      actions: [AgroIconButton(icon: Icons.add, tooltip: 'Add Farm', onPressed: () => context.push('/farm/new'))],
      floatingActionButton: AiFloatingButton(onPressed: () => context.push('/ai')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.12,
            children: [
              AgroMetricCard(label: 'Total Farm Area', value: '${repo.farmer.totalLand} ac', icon: Icons.map_outlined),
              AgroMetricCard(label: 'Active Crops', value: '${repo.farms.length}', icon: Icons.grass_outlined),
              AgroMetricCard(label: 'Soil Health', value: '$averageSoilHealth%', icon: Icons.spa_outlined),
              AgroMetricCard(label: 'Predicted Yield', value: '${repo.farms.fold<double>(0.0, (s, f) => s + f.predictedYieldTonnes).toStringAsFixed(1)} T', icon: Icons.trending_up),
            ],
          ),
          const AgroSectionHeader(title: 'Farm Cards'),
          if (repo.farms.isEmpty)
            AgroEmptyState(title: 'No farms added yet', message: 'Add your first farm to start receiving personalised AI recommendations.', actionLabel: 'Add Farm', onAction: () => context.push('/farm/new'))
          else
            ...repo.farms.map((farm) => Padding(padding: const EdgeInsets.only(bottom: 12), child: FarmCard(farm: farm))),
          const AgroSectionHeader(title: 'Farm Modules'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(label: Text(context.l10n.t('Crop History')), avatar: const Icon(Icons.timeline), onPressed: () => context.push('/farm/history')),
              ActionChip(label: Text(context.l10n.t('Soil Information')), avatar: const Icon(Icons.science_outlined), onPressed: () => context.push('/farm/soil')),
              ActionChip(label: Text(context.l10n.t('Irrigation')), avatar: const Icon(Icons.water_drop_outlined), onPressed: () => context.push('/farm/irrigation')),
              ActionChip(label: Text(context.l10n.t('Yield Records')), avatar: const Icon(Icons.currency_rupee), onPressed: () => context.push('/farm/yield')),
            ],
          ),
        ],
      ),
    );
  }
}

class FarmCard extends ConsumerWidget {
  const FarmCard({required this.farm, super.key});
  final Farm farm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (farm.status) {
      FarmStatus.healthy => AgroColors.primaryGreen,
      FarmStatus.attention => AgroColors.warning,
      FarmStatus.critical => AgroColors.danger,
    };
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(farm.name, style: Theme.of(context).textTheme.titleLarge)),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') ref.read(demoRepositoryProvider).deleteFarm(farm.id);
                },
                itemBuilder: (_) => [PopupMenuItem(value: 'delete', child: Text(context.l10n.t('Delete Farm')))],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 8, children: [
            AgroStatusBadge(label: farm.currentCrop, color: color),
            Text('${farm.landSize} ${farm.unit}'),
            Text('${context.l10n.t('Soil')} ${farm.soilHealth}%'),
            Text('${context.l10n.t('Crop')} ${farm.cropHealth}%'),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: farm.progress, borderRadius: BorderRadius.circular(999)),
          const SizedBox(height: 10),
          Text('${context.l10n.t('Map-ready location')}: ${farm.location}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _land = TextEditingController();
  final _village = TextEditingController();
  final _location = TextEditingController(text: '20.0059, 73.7916');
  final _soil = TextEditingController(text: 'Black cotton soil');
  final _crop = TextEditingController();
  String _unit = 'acre';
  String _water = 'Borewell';
  String _irrigation = 'Drip';

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Add Farm',
      child: Form(
        key: _form,
        child: Column(
          children: [
            AgroTextField(controller: _name, label: 'Farm Name', icon: Icons.yard_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _land, label: 'Land Size', icon: Icons.straighten, keyboardType: TextInputType.number, validator: requiredText),
            const SizedBox(height: 12),
            DropdownButtonFormField(value: _unit, decoration: InputDecoration(labelText: context.l10n.t('Unit')), items: const ['acre', 'hectare'].map((e) => DropdownMenuItem(value: e, child: Text(context.l10n.t(e)))).toList(), onChanged: (v) => setState(() => _unit = v ?? _unit)),
            const SizedBox(height: 12),
            AgroTextField(controller: _village, label: 'Village', icon: Icons.location_city_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _location, label: 'Location', icon: Icons.pin_drop_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _soil, label: 'Soil Type', icon: Icons.science_outlined, validator: requiredText),
            const SizedBox(height: 12),
            DropdownButtonFormField(value: _water, decoration: InputDecoration(labelText: context.l10n.t('Water Source')), items: const ['Well', 'Borewell', 'Canal', 'River', 'Rainwater', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(context.l10n.t(e)))).toList(), onChanged: (v) => setState(() => _water = v ?? _water)),
            const SizedBox(height: 12),
            DropdownButtonFormField(value: _irrigation, decoration: InputDecoration(labelText: context.l10n.t('Irrigation Type')), items: const ['Drip', 'Sprinkler', 'Flood', 'Rain-fed', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(context.l10n.t(e)))).toList(), onChanged: (v) => setState(() => _irrigation = v ?? _irrigation)),
            const SizedBox(height: 12),
            AgroTextField(controller: _crop, label: 'Current Crop', icon: Icons.grass_outlined, validator: requiredText),
            const SizedBox(height: 18),
            AgroButton(
              label: 'Save Farm',
              icon: Icons.save_outlined,
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                final repo = ref.read(demoRepositoryProvider);
                repo.addFarm(Farm(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  userId: repo.farmer.id,
                  name: _name.text,
                  landSize: double.tryParse(_land.text) ?? 0,
                  unit: _unit,
                  village: _village.text,
                  location: _location.text,
                  soilType: _soil.text,
                  waterSource: _water,
                  irrigationType: _irrigation,
                  currentCrop: _crop.text,
                  plantingDate: DateTime.now().subtract(const Duration(days: 20)),
                  expectedHarvest: DateTime.now().add(const Duration(days: 85)),
                  soilHealth: 76,
                  cropHealth: 80,
                  predictedYieldTonnes: 12,
                  status: FarmStatus.healthy,
                ));
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CropHistoryScreen extends ConsumerStatefulWidget {
  const CropHistoryScreen({super.key});

  @override
  ConsumerState<CropHistoryScreen> createState() => _CropHistoryScreenState();
}

class _CropHistoryScreenState extends ConsumerState<CropHistoryScreen> {
  String _crop = 'All';

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(demoRepositoryProvider);
    final rows = repo.cropHistory.where((item) => _crop == 'All' || item.crop == _crop).toList();
    return ScreenScaffold(
      title: 'Crop History',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField(value: _crop, decoration: InputDecoration(labelText: context.l10n.t('Crop Filter')), items: ['All', ...repo.cropHistory.map((e) => e.crop).toSet()].map((e) => DropdownMenuItem(value: e, child: Text(context.l10n.t(e)))).toList(), onChanged: (v) => setState(() => _crop = v ?? 'All')),
          const SizedBox(height: 18),
          ...rows.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AgroCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${item.year}'.substring(2))),
                    title: Text('${item.crop} - ${item.farm}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${context.l10n.t(item.season)} | ${item.area} ${context.l10n.t('acres')} | ${context.l10n.t('Yield')}: ${item.yieldTonnes} ${context.l10n.t('tonnes')}'),
                    trailing: Text('Rs ${(item.revenue / 100000).toStringAsFixed(1)}L', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class SoilInfoScreen extends StatelessWidget {
  const SoilInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      SoilMetric('pH', 6.4, '', 'Optimal'),
      SoilMetric('Nitrogen', 42, 'kg/ac', 'Low'),
      SoilMetric('Phosphorus', 28, 'kg/ac', 'Optimal'),
      SoilMetric('Potassium', 31, 'kg/ac', 'Optimal'),
      SoilMetric('Moisture', 61, '%', 'Optimal'),
      SoilMetric('Organic Carbon', 0.48, '%', 'Low'),
    ];
    return ScreenScaffold(
      title: 'Soil Information',
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: metrics.map((m) => AgroMetricCard(label: '${m.name} ${m.status}', value: '${m.value}${m.unit}', icon: Icons.science_outlined, color: m.status == 'Low' ? AgroColors.warning : AgroColors.primaryGreen)).toList(),
          ),
          const SizedBox(height: 16),
          AgroCard(child: Text(context.l10n.t('AI Insight: Nitrogen levels are below the recommended range for your tomato crop.'))),
          const SizedBox(height: 16),
          AgroButton(label: 'Get Fertilizer Recommendation', icon: Icons.eco_outlined, onPressed: () => showModalBottomSheet(context: context, builder: (_) => const _FertilizerSheet())),
        ],
      ),
    );
  }
}

class _FertilizerSheet extends StatelessWidget {
  const _FertilizerSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t('Recommended Fertilizer'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(context.l10n.t('Urea: 18 kg/acre, DAP: 10 kg/acre, Potash: 12 kg/acre, Organic Compost: 600 kg/acre. Apply after light irrigation and avoid expected rainfall. Estimated cost: Rs 4,850.')),
        ],
      ),
    );
  }
}

class IrrigationScreen extends StatelessWidget {
  const IrrigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Irrigation',
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.18,
            children: const [
              AgroMetricCard(label: 'Last Irrigation', value: '2 days', icon: Icons.history),
              AgroMetricCard(label: 'Next Irrigation', value: 'Tomorrow', icon: Icons.schedule),
              AgroMetricCard(label: 'Water Used', value: '18k L', icon: Icons.water_drop),
              AgroMetricCard(label: 'Rain Forecast', value: '32%', icon: Icons.cloud),
            ],
          ),
          const SizedBox(height: 16),
          AgroButton(label: 'Log Irrigation', icon: Icons.add, onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t('Irrigation logged. Next recommendation updated.'))))),
        ],
      ),
    );
  }
}

class YieldRecordScreen extends ConsumerStatefulWidget {
  const YieldRecordScreen({super.key});

  @override
  ConsumerState<YieldRecordScreen> createState() => _YieldRecordScreenState();
}

class _YieldRecordScreenState extends ConsumerState<YieldRecordScreen> {
  final _qty = TextEditingController(text: '3000');
  final _price = TextEditingController(text: '24');
  final _transport = TextEditingController(text: '3000');
  final _labour = TextEditingController(text: '8500');
  final _other = TextEditingController(text: '1200');

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(_qty.text) ?? 0;
    final price = double.tryParse(_price.text) ?? 0;
    final record = const FinanceService().createYieldRecord(
      crop: 'Tomato',
      farm: 'Green Valley Farm',
      harvestDate: DateTime.now(),
      quantityKg: qty,
      sellingPricePerKg: price,
      buyer: 'FreshKart Foods',
      transportationCost: double.tryParse(_transport.text) ?? 0,
      labourCost: double.tryParse(_labour.text) ?? 0,
      otherExpenses: double.tryParse(_other.text) ?? 0,
    );
    return ScreenScaffold(
      title: 'Yield Records',
      child: Column(
        children: [
          ...[_qty, _price, _transport, _labour, _other].asMap().entries.map((entry) {
            final labels = ['Quantity kg', 'Selling Price per kg', 'Transportation Cost', 'Labour Cost', 'Other Expenses'];
            return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: entry.value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.l10n.t(labels[entry.key])), onChanged: (_) => setState(() {})));
          }),
          AgroCard(
            child: Column(
              children: [
                _CalcRow('Gross Revenue', record.grossRevenue),
                _CalcRow('Total Expenses', record.totalExpenses),
                _CalcRow('Net Profit', record.netProfit),
                Text('${context.l10n.t('Profit Margin')}: ${record.profitMargin.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AgroButton(label: 'Save Yield Record', icon: Icons.save_outlined, onPressed: () => ref.read(demoRepositoryProvider).addYield(record)),
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow(this.label, this.value);
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return ListTile(contentPadding: EdgeInsets.zero, title: Text(context.l10n.t(label)), trailing: Text('Rs ${NumberFormat('#,##0').format(value)}', style: const TextStyle(fontWeight: FontWeight.w800)));
  }
}
