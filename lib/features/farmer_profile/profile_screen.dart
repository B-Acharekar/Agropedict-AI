import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../features/auth/auth_screens.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(demoRepositoryProvider);
    final farmer = repo.farmer;
    return ScreenScaffold(
      title: context.l10n.t('profileSettings'),
      actions: [AgroIconButton(icon: Icons.edit_outlined, tooltip: context.l10n.t('editProfile'), onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => _EditProfileSheet(farmer: farmer)))],
      child: Column(
        children: [
          AgroCard(
            child: Column(
              children: [
                const CircleAvatar(radius: 42, backgroundColor: AgroColors.primaryGreen, child: Icon(Icons.person, size: 44, color: Colors.white)),
                const SizedBox(height: 12),
                Text(farmer.fullName, style: Theme.of(context).textTheme.headlineMedium),
                Text('${context.l10n.t('Farmer ID')}: ${farmer.id}'),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  AgroStatusBadge(label: farmer.language),
                  AgroStatusBadge(label: farmer.cooperativeStatus, color: AgroColors.ai),
                ]),
              ],
            ),
          ),
          AgroSectionHeader(title: context.l10n.t('farmerDetails')),
          AgroCard(child: Column(children: [
            _InfoTile('Phone', farmer.mobile),
            _InfoTile('Email', farmer.email),
            _InfoTile('Village', farmer.village),
            _InfoTile('District', farmer.district),
            _InfoTile('State', farmer.state),
          ])),
          AgroSectionHeader(title: context.l10n.t('farmSummary')),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              AgroMetricCard(label: 'Total Land', value: '${farmer.totalLand} ac', icon: Icons.map),
              AgroMetricCard(label: 'Active Crops', value: '${repo.farms.length}', icon: Icons.grass),
              AgroMetricCard(label: 'Total Farms', value: '${repo.farms.length}', icon: Icons.yard),
              const AgroMetricCard(label: 'Current Season', value: 'Kharif', icon: Icons.calendar_month),
            ],
          ),
          AgroSectionHeader(title: context.l10n.t('settings')),
          AgroCard(
            child: Column(
              children: [
                _SettingsTile(context.l10n.t('myFarms'), Icons.yard_outlined, () => context.push('/farm')),
                _SettingsTile(context.l10n.t('smartCooperative'), Icons.groups_2_outlined, () => context.push('/cooperative')),
                _SettingsTile(context.l10n.t('sharedTransportation'), Icons.local_shipping_outlined, () => context.push('/logistics')),
                _SettingsTile(context.l10n.t('language'), Icons.translate, () => context.push('/language?return=profile')),
                _SettingsTile(context.l10n.t('notifications'), Icons.notifications_outlined, () => context.push('/notifications')),
                _SettingsTile(context.l10n.t('governmentSchemes'), Icons.account_balance_outlined, () => context.push('/schemes')),
                _SettingsTile(context.l10n.t('analytics'), Icons.analytics_outlined, () => context.push('/analytics')),
                _SettingsTile('Help & Support', Icons.support_agent_outlined, () {}),
                _SettingsTile('About AgroPredict', Icons.info_outline, () {}),
                _SettingsTile('Logout', Icons.logout, () => context.go('/login')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.farmer});
  final Farmer farmer;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final _name = TextEditingController(text: widget.farmer.fullName);
  late final _mobile = TextEditingController(text: widget.farmer.mobile);
  late final _email = TextEditingController(text: widget.farmer.email);
  late final _village = TextEditingController(text: widget.farmer.village);
  late final _district = TextEditingController(text: widget.farmer.district);
  late final _state = TextEditingController(text: widget.farmer.state);
  late String _language = widget.farmer.language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: MediaQuery.of(context).viewInsets.bottom + 18),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(context.l10n.t('Edit Profile'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AgroTextField(controller: _name, label: 'Full Name', validator: requiredText),
          const SizedBox(height: 10),
          AgroTextField(controller: _mobile, label: 'Phone', validator: requiredText),
          const SizedBox(height: 10),
          AgroTextField(controller: _email, label: 'Email', validator: requiredText),
          const SizedBox(height: 10),
          AgroTextField(controller: _village, label: 'Village', validator: requiredText),
          const SizedBox(height: 10),
          AgroTextField(controller: _district, label: 'District', validator: requiredText),
          const SizedBox(height: 10),
          AgroTextField(controller: _state, label: 'State', validator: requiredText),
          const SizedBox(height: 10),
          DropdownButtonFormField(value: _language, decoration: InputDecoration(labelText: context.l10n.t('Language')), items: const ['English', 'Hindi', 'Marathi', 'Gujarati', 'Tamil', 'Telugu', 'Kannada', 'Punjabi'].map((e) => DropdownMenuItem(value: e, child: Text(context.l10n.t(e)))).toList(), onChanged: (v) => setState(() => _language = v ?? _language)),
          const SizedBox(height: 14),
          AgroButton(
            label: 'Save Changes',
            icon: Icons.save_outlined,
            onPressed: () {
              ref.read(demoRepositoryProvider).updateFarmer(widget.farmer.copyWith(fullName: _name.text, mobile: _mobile.text, email: _email.text, village: _village.text, district: _district.text, state: _state.text, language: _language));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, title: Text(context.l10n.t(label)), trailing: Text(context.l10n.t(value), style: const TextStyle(fontWeight: FontWeight.w700)));
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: AgroColors.primaryGreen), title: Text(context.l10n.t(label)), trailing: const Icon(Icons.chevron_right), onTap: onTap);
}
