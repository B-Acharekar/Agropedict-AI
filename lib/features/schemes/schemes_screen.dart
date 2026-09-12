import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../repositories/providers.dart';

class SchemesScreen extends ConsumerStatefulWidget {
  const SchemesScreen({super.key});

  @override
  ConsumerState<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends ConsumerState<SchemesScreen> {
  String _category = 'All';
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final schemes = ref.watch(demoRepositoryProvider).schemes.where((scheme) {
      final matchesCategory = _category == 'All' || scheme.category == _category;
      final q = _search.text.toLowerCase();
      return matchesCategory && '${scheme.name} ${scheme.category} ${scheme.benefit}'.toLowerCase().contains(q);
    }).toList();
    return ScreenScaffold(
      title: 'Government Schemes',
      child: Column(
        children: [
          TextField(controller: _search, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: context.l10n.t('Search schemes')), onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: ['All', 'Central Government', 'State Government', 'Loans', 'Insurance', 'Equipment', 'Subsidies', 'Irrigation'].map((category) => FilterChip(label: Text(context.l10n.t(category)), selected: _category == category, onSelected: (_) => setState(() => _category = category))).toList()),
          const SizedBox(height: 16),
          ...schemes.map((scheme) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AgroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(scheme.name, style: Theme.of(context).textTheme.titleLarge)),
                          AgroStatusBadge(label: scheme.category, color: AgroColors.warm),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${context.l10n.t('Deadline')}: ${scheme.deadline}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('${context.l10n.t('Eligibility')}: ${context.l10n.t(scheme.eligibility)}'),
                      const SizedBox(height: 6),
                      Text('${context.l10n.t('Benefit')}: ${context.l10n.t(scheme.benefit)}'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: scheme.documents.map((doc) => Chip(label: Text(context.l10n.t(doc)), avatar: const Icon(Icons.description_outlined, size: 16))).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: ElevatedButton.icon(onPressed: () => _show(context, '${context.l10n.t('Application checklist opened for')} ${scheme.name}.'), icon: const Icon(Icons.checklist_outlined), label: Text(context.l10n.t('Check')))),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton.icon(onPressed: () => _show(context, '${scheme.name} ${context.l10n.t('saved for follow-up.')}'), icon: const Icon(Icons.bookmark_add_outlined), label: Text(context.l10n.t('Save')))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${context.l10n.t('Portal')}: ${scheme.website}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t(message))));
  }
}
