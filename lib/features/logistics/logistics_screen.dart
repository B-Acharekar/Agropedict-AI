import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/agro_services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class LogisticsScreen extends ConsumerWidget {
  const LogisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final service = ref.watch(logisticsServiceProvider);
    final shares = service.splitTransportCost(totalCost: 9000, loads: const [FarmerLoad('Ramesh', 3000), FarmerLoad('Suresh', 2000), FarmerLoad('Mahesh', 4000)]);
    final allocated = service.allocateTrucks(8.7, repo.trucks);
    final route = service.optimizeRoute(const [
      RouteStop('Depot', 20.00, 73.79),
      RouteStop('Farm A', 20.05, 73.80),
      RouteStop('Farm B', 19.95, 73.85),
      RouteStop('Farm C', 20.03, 73.72),
    ]);
    return ScreenScaffold(
      title: 'Shared Transportation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AgroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.t('Upcoming Pickup'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                Text('${context.l10n.t('Truck')} MH-15-AB-2481 | ${context.l10n.t('Capacity')}: 8 ${context.l10n.t('tonnes')} | ${context.l10n.t('Used')}: 6.4 ${context.l10n.t('tonnes')}'),
                Text('${context.l10n.t('Pickup Date')}: 23 ${context.l10n.t('March')} | ${context.l10n.t('Driver')}: Rajesh Patil'),
                Text('${context.l10n.t('Destination')}: Nashik APMC'),
              ],
            ),
          ),
          const AgroSectionHeader(title: 'Pickup Scheduling'),
          const AgroCard(
            child: Column(
              children: [
                ListTile(contentPadding: EdgeInsets.zero, title: Text('Farm A'), trailing: Text('06:30 AM')),
                Divider(),
                ListTile(contentPadding: EdgeInsets.zero, title: Text('Farm B'), trailing: Text('07:10 AM')),
                Divider(),
                ListTile(contentPadding: EdgeInsets.zero, title: Text('Farm C'), trailing: Text('08:00 AM')),
              ],
            ),
          ),
          const AgroSectionHeader(title: 'Route Optimization'),
          AgroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${context.l10n.t('Pickup Route')}: ${route.map((e) => e.name).join(' -> ')}'),
                const SizedBox(height: 8),
                Text('${context.l10n.t('Total Distance')}: 42 km | ${context.l10n.t('Duration')}: 2h 15m | ${context.l10n.t('Fuel')}: 7.2 L | ${context.l10n.t('Farms')}: 3'),
              ],
            ),
          ),
          const AgroSectionHeader(title: 'Cost Splitting'),
          AgroCard(
            child: Column(
              children: shares.map((share) => ListTile(contentPadding: EdgeInsets.zero, title: Text(share.name), subtitle: Text('${share.loadKg.toStringAsFixed(0)} kg'), trailing: Text('Rs ${share.cost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)))).toList(),
            ),
          ),
          const AgroSectionHeader(title: 'Truck Allocation'),
          AgroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${context.l10n.t('Recommended for')} 8.7 ${context.l10n.t('tonnes')}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...allocated.map((truck) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.local_shipping_outlined, color: AgroColors.primaryGreen), title: Text(truck.name), subtitle: Text('${truck.capacityTonnes} T | ${truck.status}'), trailing: Text('Rs ${truck.price.toStringAsFixed(0)}'))),
              ],
            ),
          ),
          const AgroSectionHeader(title: 'Joint Selling'),
          AgroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.t('Tomato'), style: Theme.of(context).textTheme.titleLarge),
                Text('${context.l10n.t('Combined Quantity')}: 18.7 ${context.l10n.t('tonnes')}'),
                Text('${context.l10n.t('Individual Average Offer')}: Rs 21/kg'),
                Text('${context.l10n.t('Group Negotiated Offer')}: Rs 24/kg'),
                Text('${context.l10n.t('Potential Extra Revenue')}: Rs 56,100'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: ElevatedButton(onPressed: () {}, child: Text(context.l10n.t('Accept')))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: Text(context.l10n.t('Reject')))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: Text(context.l10n.t('Counter')))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
