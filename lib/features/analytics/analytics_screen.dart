import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final records = repo.yieldRecords.isEmpty ? _demoRecords : repo.yieldRecords;
    final revenue = records.fold<double>(0.0, (sum, record) => sum + record.grossRevenue);
    final expenses = records.fold<double>(0.0, (sum, record) => sum + record.totalExpenses);
    final profit = revenue - expenses;
    final margin = revenue == 0 ? 0.0 : profit / revenue * 100;
    final quantityKg = records.fold<double>(0.0, (sum, record) => sum + record.quantityKg);
    final averagePrice = quantityKg == 0 ? 0.0 : revenue / quantityKg;

    return ScreenScaffold(
      title: 'Analytics Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryGrid(revenue: revenue, expenses: expenses, profit: profit, margin: margin),
          const AgroSectionHeader(title: 'Price Trends'),
          _PriceTrend(prices: repo.marketPrices),
          const AgroSectionHeader(title: 'Sales Analytics'),
          _SalesAnalytics(records: records, quantityKg: quantityKg, averagePrice: averagePrice),
          const AgroSectionHeader(title: 'Profit & Loss Graphs'),
          _ProfitLoss(records: records),
          const AgroSectionHeader(title: 'Risk Dashboard'),
          _RiskDashboard(farmHealth: repo.farmHealthScore, margin: margin),
          const AgroSectionHeader(title: 'Demand Heatmaps'),
          const _DemandHeatmap(),
          const AgroSectionHeader(title: 'Buyer Analytics'),
          _BuyerAnalytics(buyers: repo.buyers, records: records),
          const AgroSectionHeader(title: 'Finance Summary'),
          _FinanceSummary(revenue: revenue, expenses: expenses, profit: profit, margin: margin),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.revenue, required this.expenses, required this.profit, required this.margin});

  final double revenue;
  final double expenses;
  final double profit;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0');
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        AgroMetricCard(label: 'Revenue', value: 'Rs ${money.format(revenue)}', icon: Icons.trending_up),
        AgroMetricCard(label: 'Expenses', value: 'Rs ${money.format(expenses)}', icon: Icons.trending_down, color: AgroColors.warning),
        AgroMetricCard(label: 'Profit', value: 'Rs ${money.format(profit)}', icon: Icons.savings_outlined, color: profit >= 0 ? AgroColors.primaryGreen : AgroColors.danger),
        AgroMetricCard(label: 'Margin', value: '${margin.toStringAsFixed(1)}%', icon: Icons.percent, color: AgroColors.warm),
      ],
    );
  }
}

class _PriceTrend extends StatelessWidget {
  const _PriceTrend({required this.prices});

  final List<MarketPrice> prices;

  @override
  Widget build(BuildContext context) {
    final maxPrice = prices.isEmpty ? 30.0 : prices.map((price) => price.price).reduce((a, b) => a > b ? a : b);
    return AgroCard(
      child: Column(
        children: [
          for (final price in prices)
            _ProgressRow(
              label: '${context.l10n.t(price.crop)} - ${price.market}',
              value: 'Rs ${price.price.toStringAsFixed(1)}/kg',
              progress: maxPrice == 0 ? 0 : price.price / maxPrice,
              color: price.changePercent >= 0 ? AgroColors.primaryGreen : AgroColors.danger,
            ),
        ],
      ),
    );
  }
}

class _SalesAnalytics extends StatelessWidget {
  const _SalesAnalytics({required this.records, required this.quantityKg, required this.averagePrice});

  final List<YieldRecord> records;
  final double quantityKg;
  final double averagePrice;

  @override
  Widget build(BuildContext context) {
    final topBuyer = _topBuyer(records);
    return AgroCard(
      child: Column(
        children: [
          _InfoRow('Total Sales Orders', '${records.length}'),
          _InfoRow('Quantity Sold', '${(quantityKg / 1000).toStringAsFixed(1)} ${context.l10n.t('tonnes')}'),
          _InfoRow('Average Selling Price', 'Rs ${averagePrice.toStringAsFixed(1)}/kg'),
          _InfoRow('Best Buyer', topBuyer),
        ],
      ),
    );
  }

  String _topBuyer(List<YieldRecord> records) {
    if (records.isEmpty) return 'FreshKart Foods';
    final totals = <String, double>{};
    for (final record in records) {
      totals[record.buyer] = (totals[record.buyer] ?? 0.0) + record.grossRevenue;
    }
    return totals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class _ProfitLoss extends StatelessWidget {
  const _ProfitLoss({required this.records});

  final List<YieldRecord> records;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0');
    final maxAmount = records
        .expand((record) => [record.grossRevenue, record.totalExpenses, record.netProfit.abs()])
        .fold<double>(1.0, (max, value) => value > max ? value : max);
    return AgroCard(
      child: Column(
        children: [
          for (final record in records) ...[
            Align(alignment: Alignment.centerLeft, child: Text('${context.l10n.t(record.crop)} - ${record.farm}', style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 8),
            _ProgressRow(label: 'Revenue', value: 'Rs ${money.format(record.grossRevenue)}', progress: record.grossRevenue / maxAmount, color: AgroColors.primaryGreen),
            _ProgressRow(label: 'Expenses', value: 'Rs ${money.format(record.totalExpenses)}', progress: record.totalExpenses / maxAmount, color: AgroColors.warm),
            _ProgressRow(label: 'Profit', value: 'Rs ${money.format(record.netProfit)}', progress: record.netProfit.abs() / maxAmount, color: record.netProfit >= 0 ? AgroColors.freshGreen : AgroColors.danger),
            if (record != records.last) const Divider(height: 26),
          ],
        ],
      ),
    );
  }
}

class _RiskDashboard extends StatelessWidget {
  const _RiskDashboard({required this.farmHealth, required this.margin});

  final int farmHealth;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final diseaseRisk = farmHealth >= 80 ? 0.25 : farmHealth >= 65 ? 0.55 : 0.85;
    final financeRisk = margin >= 35 ? 0.22 : margin >= 20 ? 0.48 : 0.75;
    return AgroCard(
      child: Column(
        children: [
          _RiskRow(label: 'Weather Risk', value: 'LOW', progress: 0.28, color: AgroColors.primaryGreen, icon: Icons.cloud_outlined),
          _RiskRow(label: 'Disease Risk', value: diseaseRisk > 0.7 ? 'HIGH' : diseaseRisk > 0.4 ? 'MEDIUM' : 'LOW', progress: diseaseRisk, color: diseaseRisk > 0.7 ? AgroColors.danger : diseaseRisk > 0.4 ? AgroColors.warning : AgroColors.primaryGreen, icon: Icons.biotech_outlined),
          _RiskRow(label: 'Market Risk', value: 'MEDIUM', progress: 0.52, color: AgroColors.warning, icon: Icons.storefront_outlined),
          _RiskRow(label: 'Finance Risk', value: financeRisk > 0.7 ? 'HIGH' : financeRisk > 0.4 ? 'MEDIUM' : 'LOW', progress: financeRisk, color: financeRisk > 0.7 ? AgroColors.danger : financeRisk > 0.4 ? AgroColors.warning : AgroColors.primaryGreen, icon: Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }
}

class _DemandHeatmap extends StatelessWidget {
  const _DemandHeatmap();

  @override
  Widget build(BuildContext context) {
    const cities = [
      ('Mumbai', 'VERY HIGH', 0.95, AgroColors.primaryGreen),
      ('Nashik', 'HIGH', 0.82, AgroColors.freshGreen),
      ('Pune', 'MEDIUM', 0.64, AgroColors.warning),
      ('Surat', 'MEDIUM', 0.58, AgroColors.warning),
      ('Ahmednagar', 'LOW', 0.42, AgroColors.earth),
      ('Indore', 'LOW', 0.38, AgroColors.earth),
    ];
    return AgroCard(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
        children: [
          for (final city in cities)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: city.$4.withOpacity(city.$3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(city.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  Text(context.l10n.t(city.$2), style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BuyerAnalytics extends StatelessWidget {
  const _BuyerAnalytics({required this.buyers, required this.records});

  final List<Buyer> buyers;
  final List<YieldRecord> records;

  @override
  Widget build(BuildContext context) {
    final soldBuyers = records.map((record) => record.buyer).toSet();
    return AgroCard(
      child: Column(
        children: [
          for (final buyer in buyers)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(buyer.verified ? Icons.verified : Icons.storefront_outlined, color: buyer.verified ? AgroColors.primaryGreen : AgroColors.warning),
              title: Text(buyer.name),
              subtitle: Text('${context.l10n.t(buyer.crop)} | ${buyer.quantityTonnes} T | ${buyer.distanceKm} km'),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs ${buyer.offerPerKg}/kg', style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(context.l10n.t(soldBuyers.contains(buyer.name) ? 'Sold' : buyer.status), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FinanceSummary extends StatelessWidget {
  const _FinanceSummary({required this.revenue, required this.expenses, required this.profit, required this.margin});

  final double revenue;
  final double expenses;
  final double profit;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0');
    final roi = expenses == 0 ? 0.0 : profit / expenses * 100;
    return AgroCard(
      child: Column(
        children: [
          _InfoRow('Available Balance', 'Rs ${money.format(profit * 0.62)}'),
          _InfoRow('Pending Payments', 'Rs ${money.format(revenue * 0.18)}'),
          _InfoRow('Expected Revenue', 'Rs ${money.format(revenue * 0.32)}'),
          _InfoRow('ROI', '${roi.toStringAsFixed(1)}%'),
          _InfoRow('Profit Margin', '${margin.toStringAsFixed(1)}%'),
          const _InfoRow('Insurance Status', 'Active'),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value, required this.progress, required this.color});

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(context.l10n.t(label), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 10, borderRadius: BorderRadius.circular(999), color: color),
        ],
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.label, required this.value, required this.progress, required this.color, required this.icon});

  final String label;
  final String value;
  final double progress;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(context.l10n.t(label)),
      subtitle: LinearProgressIndicator(value: progress, color: color, borderRadius: BorderRadius.circular(999)),
      trailing: AgroStatusBadge(label: value, color: color),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.l10n.t(label)),
      trailing: Text(context.l10n.t(value), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

final _demoRecords = [
  YieldRecord(
    crop: 'Tomato',
    farm: 'Green Valley Farm',
    harvestDate: DateTime(2026, 3, 23),
    quantityKg: 3000,
    sellingPricePerKg: 24,
    buyer: 'FreshKart Foods',
    transportationCost: 3000,
    labourCost: 8500,
    otherExpenses: 1200,
  ),
  YieldRecord(
    crop: 'Onion',
    farm: 'Sai Farm',
    harvestDate: DateTime(2026, 3, 25),
    quantityKg: 2600,
    sellingPricePerKg: 19,
    buyer: 'Green Basket Co.',
    transportationCost: 2600,
    labourCost: 7200,
    otherExpenses: 900,
  ),
  YieldRecord(
    crop: 'Tomato',
    farm: 'Green Valley Farm',
    harvestDate: DateTime(2026, 3, 29),
    quantityKg: 4200,
    sellingPricePerKg: 26,
    buyer: 'Sahyadri Retail',
    transportationCost: 3900,
    labourCost: 10300,
    otherExpenses: 1600,
  ),
];
