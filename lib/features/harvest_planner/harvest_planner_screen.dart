import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/agro_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class HarvestPlannerScreen extends ConsumerStatefulWidget {
  const HarvestPlannerScreen({super.key});

  @override
  ConsumerState<HarvestPlannerScreen> createState() => _HarvestPlannerScreenState();
}

class _HarvestPlannerScreenState extends ConsumerState<HarvestPlannerScreen> {
  bool _labourAvailable = true;
  bool _truckAvailable = true;
  bool _buyerAvailable = true;
  DateTime? _selectedDate;
  final _scheduledPlans = <String>[];

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(demoRepositoryProvider);
    final service = ref.read(harvestServiceProvider);
    final farm = repo.farms.isEmpty ? null : repo.farms.first;
    final crop = farm?.currentCrop ?? 'Tomato';
    final weather = _weatherWindow(farm?.expectedHarvest ?? DateTime.now().add(const Duration(days: 5)));
    final prices = _marketWindow(repo.marketPrices, crop, weather);
    final rec = service.recommend(
      weather: weather,
      prices: prices,
      labourAvailable: _labourAvailable,
      truckAvailable: _truckAvailable,
      buyerAvailable: _buyerAvailable,
    );
    final planDate = _selectedDate ?? rec.date;
    final bestPrice = prices.fold<MarketForecast?>(null, (best, item) => best == null || item.pricePerKg > best.pricePerKg ? item : best);
    final buyer = repo.buyers.where((item) => item.crop.toLowerCase() == crop.toLowerCase()).firstOrNull;
    final trucks = ref.watch(logisticsServiceProvider).allocateTrucks(farm?.predictedYieldTonnes ?? 8, repo.trucks);

    return ScreenScaffold(
      title: 'Smart Harvest Planner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FlowBanner(),
          const SizedBox(height: 14),
          _BestWindowCard(recommendation: rec, bestPrice: bestPrice),
          const AgroSectionHeader(title: 'Harvest Calendar'),
          _HarvestCalendar(
            weather: weather,
            prices: prices,
            selectedDate: planDate,
            recommendedDate: rec.date,
            onSelected: (date) => setState(() => _selectedDate = date),
          ),
          const AgroSectionHeader(title: 'Crop Status'),
          _CropStatusCard(farm: farm, crop: crop),
          const AgroSectionHeader(title: 'Weather Data'),
          _WeatherStage(weather: weather, recommendedDate: planDate),
          const AgroSectionHeader(title: 'Market Data'),
          _MarketStage(prices: prices, recommendedDate: planDate),
          const AgroSectionHeader(title: 'Harvest Analysis'),
          _ResourcePlanningStage(
            labourAvailable: _labourAvailable,
            truckAvailable: _truckAvailable,
            buyerAvailable: _buyerAvailable,
            workerCount: _workersFor(farm),
            trucks: trucks,
            buyer: buyer,
            onLabourChanged: (value) => setState(() => _labourAvailable = value),
            onTruckChanged: (value) => setState(() => _truckAvailable = value),
            onBuyerChanged: (value) => setState(() => _buyerAvailable = value),
          ),
          const AgroSectionHeader(title: 'Best Harvest Window'),
          _ScheduleStage(
            recommendation: rec,
            selectedDate: planDate,
            crop: crop,
            farmName: farm?.name ?? 'Primary Farm',
            buyer: buyer,
            scheduledPlans: _scheduledPlans,
            onSchedule: (plan) => setState(() => _scheduledPlans.insert(0, plan)),
          ),
        ],
      ),
    );
  }

  List<WeatherDay> _weatherWindow(DateTime center) {
    final start = DateTime(center.year, center.month, center.day).subtract(const Duration(days: 2));
    return [
      WeatherDay(start, 'Clear', 'Best'),
      WeatherDay(start.add(const Duration(days: 1)), 'Partly Cloudy', 'Good'),
      WeatherDay(start.add(const Duration(days: 2)), 'Light Rain', 'Good'),
      WeatherDay(start.add(const Duration(days: 3)), 'Heavy Rain', 'Avoid'),
      WeatherDay(start.add(const Duration(days: 4)), 'Cloudy', 'Good'),
    ];
  }

  List<MarketForecast> _marketWindow(List<MarketPrice> marketPrices, String crop, List<WeatherDay> weather) {
    final cropPrices = marketPrices.where((price) => price.crop.toLowerCase() == crop.toLowerCase()).toList();
    final basePrice = cropPrices.isEmpty ? 22.0 : cropPrices.map((price) => price.price).reduce((a, b) => a > b ? a : b);
    return [
      for (var i = 0; i < weather.length; i++)
        MarketForecast(weather[i].date, (basePrice + [0.0, 1.5, 2.0, -1.0, -2.0][i]).clamp(10, 80).toDouble()),
    ];
  }

  int _workersFor(Farm? farm) {
    final area = farm?.landSize ?? 3.0;
    return (area * 3).ceil().clamp(4, 20);
  }
}

class _HarvestCalendar extends StatelessWidget {
  const _HarvestCalendar({
    required this.weather,
    required this.prices,
    required this.selectedDate,
    required this.recommendedDate,
    required this.onSelected,
  });

  final List<WeatherDay> weather;
  final List<MarketForecast> prices;
  final DateTime selectedDate;
  final DateTime recommendedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: [
        for (final day in weather)
          _CalendarDay(
            day: day,
            price: prices.firstWhere((price) => _sameDay(price.date, day.date), orElse: () => MarketForecast(day.date, 22)),
            selected: _sameDay(day.date, selectedDate),
            recommended: _sameDay(day.date, recommendedDate),
            onTap: () => onSelected(day.date),
          ),
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.day, required this.price, required this.selected, required this.recommended, required this.onTap});

  final WeatherDay day;
  final MarketForecast price;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = day.risk == 'Avoid' ? AgroColors.danger : selected ? AgroColors.warm : AgroColors.primaryGreen;
    return AgroCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('EEE').format(day.date), style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(DateFormat('dd').format(day.date), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
          Text('Rs ${price.pricePerKg.toStringAsFixed(0)}/kg', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          AgroStatusBadge(label: recommended ? 'AI Pick' : day.risk, color: color),
        ],
      ),
    );
  }
}

class _FlowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      ('Crop Status', Icons.grass_outlined),
      ('Weather Data', Icons.cloud_outlined),
      ('Market Data', Icons.storefront_outlined),
      ('Analysis', Icons.analytics_outlined),
      ('Best Window', Icons.event_available),
    ];
    return AgroCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final step in steps)
            Chip(
              avatar: Icon(step.$2, color: AgroColors.primaryGreen, size: 18),
              label: Text(step.$1),
              side: const BorderSide(color: AgroColors.lime),
              backgroundColor: Colors.white,
            ),
        ],
      ),
    );
  }
}

class _BestWindowCard extends StatelessWidget {
  const _BestWindowCard({required this.recommendation, required this.bestPrice});

  final HarvestRecommendation recommendation;
  final MarketForecast? bestPrice;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: AgroColors.warm, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd MMM yyyy').format(recommendation.date), style: Theme.of(context).textTheme.headlineMedium),
          Text(context.l10n.t('AI best harvest window'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              AgroStatusBadge(label: '${recommendation.confidence}%', color: AgroColors.warm),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: recommendation.confidence / 100, minHeight: 10, borderRadius: BorderRadius.circular(999), color: AgroColors.warm),
          const SizedBox(height: 10),
          Text(recommendation.reason),
          if (bestPrice != null) ...[
            const SizedBox(height: 8),
            Text('${context.l10n.t('Highest forecast price')}: Rs ${bestPrice!.pricePerKg.toStringAsFixed(1)}/kg ${context.l10n.t('on')} ${DateFormat('dd MMM').format(bestPrice!.date)}.'),
          ],
        ],
      ),
    );
  }
}

class _CropStatusCard extends StatelessWidget {
  const _CropStatusCard({required this.farm, required this.crop});

  final Farm? farm;
  final String crop;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t(crop), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: farm?.progress ?? 0.78, minHeight: 10, borderRadius: BorderRadius.circular(999)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _MiniMetric('Farm', farm?.name ?? 'Primary Farm'),
              _MiniMetric('Crop Health', '${farm?.cropHealth ?? 82}%'),
              _MiniMetric('Expected Yield', '${farm?.predictedYieldTonnes.toStringAsFixed(1) ?? '12.0'} T'),
              _MiniMetric('Expected Harvest', farm == null ? 'Soon' : DateFormat('dd MMM').format(farm!.expectedHarvest)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherStage extends StatelessWidget {
  const _WeatherStage({required this.weather, required this.recommendedDate});

  final List<WeatherDay> weather;
  final DateTime recommendedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final day in weather)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AgroCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(day.risk == 'Avoid' ? Icons.thunderstorm_outlined : Icons.wb_sunny_outlined, color: day.risk == 'Avoid' ? AgroColors.danger : AgroColors.primaryGreen),
                title: Text(DateFormat('EEE, dd MMM').format(day.date)),
                subtitle: Text(context.l10n.t(day.condition)),
                trailing: AgroStatusBadge(label: _sameDay(day.date, recommendedDate) ? 'Selected' : day.risk, color: day.risk == 'Avoid' ? AgroColors.danger : AgroColors.primaryGreen),
              ),
            ),
          ),
      ],
    );
  }
}

class _MarketStage extends StatelessWidget {
  const _MarketStage({required this.prices, required this.recommendedDate});

  final List<MarketForecast> prices;
  final DateTime recommendedDate;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        children: [
          for (final price in prices)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.currency_rupee, color: AgroColors.warm),
              title: Text(DateFormat('dd MMM').format(price.date)),
              subtitle: LinearProgressIndicator(value: price.pricePerKg / 80, borderRadius: BorderRadius.circular(999), color: AgroColors.warm),
              trailing: Text('Rs ${price.pricePerKg.toStringAsFixed(1)}/kg', style: TextStyle(fontWeight: FontWeight.w800, color: _sameDay(price.date, recommendedDate) ? AgroColors.warm : null)),
            ),
        ],
      ),
    );
  }
}

class _ResourcePlanningStage extends StatelessWidget {
  const _ResourcePlanningStage({
    required this.labourAvailable,
    required this.truckAvailable,
    required this.buyerAvailable,
    required this.workerCount,
    required this.trucks,
    required this.buyer,
    required this.onLabourChanged,
    required this.onTruckChanged,
    required this.onBuyerChanged,
  });

  final bool labourAvailable;
  final bool truckAvailable;
  final bool buyerAvailable;
  final int workerCount;
  final List<Truck> trucks;
  final Buyer? buyer;
  final ValueChanged<bool> onLabourChanged;
  final ValueChanged<bool> onTruckChanged;
  final ValueChanged<bool> onBuyerChanged;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: labourAvailable,
            onChanged: onLabourChanged,
            title: Text(context.l10n.t('Labour Planning')),
            subtitle: Text('$workerCount ${context.l10n.t('workers')} | 7.5 ${context.l10n.t('hours')} | Rs ${(workerCount * 1400).toStringAsFixed(0)} ${context.l10n.t('estimated')}'),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: truckAvailable,
            onChanged: onTruckChanged,
            title: Text(context.l10n.t('Truck Availability')),
            subtitle: Text(trucks.isEmpty ? context.l10n.t('No truck available') : trucks.map((truck) => '${truck.name} ${truck.capacityTonnes}T').join(', ')),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: buyerAvailable,
            onChanged: onBuyerChanged,
            title: Text(context.l10n.t('Buyer Schedule Management')),
            subtitle: Text(buyer == null ? context.l10n.t('Buyer pool open') : '${buyer!.name} | ${buyer!.quantityTonnes} ${context.l10n.t('tonnes')} | Rs ${buyer!.offerPerKg}/kg'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleStage extends StatelessWidget {
  const _ScheduleStage({
    required this.recommendation,
    required this.selectedDate,
    required this.crop,
    required this.farmName,
    required this.buyer,
    required this.scheduledPlans,
    required this.onSchedule,
  });

  final HarvestRecommendation recommendation;
  final DateTime selectedDate;
  final String crop;
  final String farmName;
  final Buyer? buyer;
  final List<String> scheduledPlans;
  final ValueChanged<String> onSchedule;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(selectedDate);
    final aiDate = DateFormat('dd MMM yyyy').format(recommendation.date);
    final plan = '$crop | $farmName | $date | ${buyer?.name ?? 'Cooperative buyer pool'} | 06:30 AM';
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${context.l10n.t(crop)} ${context.l10n.t('harvest plan')}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('${context.l10n.t('Farm')}: $farmName'),
          Text('${context.l10n.t('Harvest date')}: $date'),
          Text('${context.l10n.t('AI suggested')}: $aiDate'),
          Text('${context.l10n.t('Buyer pickup')}: ${buyer?.name ?? context.l10n.t('Cooperative buyer pool')} ${context.l10n.t('at')} 06:30 AM'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => onSchedule(plan), icon: const Icon(Icons.event_available), label: Text(context.l10n.t('Schedule')))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => _show(context, context.l10n.t('Buyer pickup slot confirmed.')), icon: const Icon(Icons.handshake_outlined), label: Text(context.l10n.t('Confirm Buyer')))),
            ],
          ),
          if (scheduledPlans.isNotEmpty) ...[
            const Divider(height: 28),
            Text(context.l10n.t('Scheduled Plans'), style: Theme.of(context).textTheme.titleMedium),
            ...scheduledPlans.map((item) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle, color: AgroColors.primaryGreen), title: Text(item))),
          ],
        ],
      ),
    );
  }

  void _show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t(message))));
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
        Text(context.l10n.t(label), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        Text(context.l10n.t(value), style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
