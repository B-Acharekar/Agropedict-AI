import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../repositories/providers.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(demoRepositoryProvider).search(_controller.text);
    return ScreenScaffold(
      title: 'Global Search',
      child: Column(
        children: [
          TextField(controller: _controller, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l10n.t('Search farm, crop, buyer, scheme, order, AI, market')), onChanged: (_) => setState(() {})),
          const SizedBox(height: 16),
          if (results.isEmpty)
            AgroEmptyState(title: 'Search AgroPredict', message: 'Find farms, crops, buyers, schemes, orders, AI conversation and market data.', actionLabel: 'Try Tomato', onAction: () => setState(() => _controller.text = 'Tomato'))
          else
            ...results.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AgroCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.search), title: Text(context.l10n.t(item.runtimeType.toString())), subtitle: Text(context.l10n.t(item.toString())))))),
        ],
      ),
    );
  }
}
