import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    return ScreenScaffold(
      title: 'Notifications',
      child: Column(
        children: [
          if (repo.notifications.isEmpty)
            AgroEmptyState(title: 'No notifications', message: 'AI, weather, market, harvest, transport, payment, cooperative, and scheme alerts will appear here.', actionLabel: 'Refresh', onAction: () {})
          else
            ...repo.notifications.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AgroCard(
                    onTap: () => ref.read(demoRepositoryProvider).markNotificationRead(item.id),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_icon(item.category)),
                      title: Text(context.l10n.t(item.title), style: TextStyle(fontWeight: item.read ? FontWeight.w600 : FontWeight.w900)),
                      subtitle: Text(context.l10n.t(item.body)),
                      trailing: item.read ? null : const Icon(Icons.circle, size: 10),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  IconData _icon(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.ai => Icons.auto_awesome,
      NotificationCategory.weather => Icons.cloud_outlined,
      NotificationCategory.market => Icons.storefront_outlined,
      NotificationCategory.harvest => Icons.event_available,
      NotificationCategory.transport => Icons.local_shipping_outlined,
      NotificationCategory.payment => Icons.payments_outlined,
      NotificationCategory.cooperative => Icons.groups_2,
      NotificationCategory.scheme => Icons.account_balance_outlined,
    };
  }
}
