import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({required this.returnToProfile, super.key});

  final bool returnToProfile;

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = ref.read(appLanguageProvider).code;
  }

  @override
  Widget build(BuildContext context) {
    final languageState = ref.watch(appLanguageProvider);
    if (languageState.loaded && _selectedCode == AppLanguages.systemCode && languageState.code != AppLanguages.systemCode) {
      _selectedCode = languageState.code;
    }

    return Scaffold(
      appBar: widget.returnToProfile ? AppBar(title: Text(context.l10n.t('language'))) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.returnToProfile) ...[
                const SizedBox(height: 12),
                const Icon(Icons.translate, color: AgroColors.primaryGreen, size: 48),
                const SizedBox(height: 18),
              ],
              Text(context.l10n.t('languageTitle'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(context.l10n.t('languageSubtitle'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4)),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: AppLanguages.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = AppLanguages.options[index];
                    final selected = option.code == _selectedCode;
                    return AgroCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      onTap: () => _choose(option.code),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: selected ? AgroColors.primaryGreen : AgroColors.lightGreen.withOpacity(0.5),
                          child: Icon(option.isSystem ? Icons.settings_suggest_outlined : Icons.language, color: selected ? Colors.white : AgroColors.primaryGreen),
                        ),
                        title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${option.nativeName} - ${option.region}'),
                        trailing: Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? AgroColors.primaryGreen : Theme.of(context).colorScheme.outline),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AgroButton(label: context.l10n.t('continue'), icon: Icons.arrow_forward, onPressed: _continue),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _choose(String code) async {
    setState(() => _selectedCode = code);
    await ref.read(appLanguageProvider.notifier).setLanguage(code);
  }

  Future<void> _continue() async {
    await ref.read(appLanguageProvider.notifier).setLanguage(_selectedCode);
    if (!mounted) return;
    context.go(widget.returnToProfile ? '/profile' : '/onboarding');
  }
}
