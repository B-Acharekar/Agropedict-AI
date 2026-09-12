import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

String? requiredText(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'ramesh.patil@example.com');
  final _password = TextEditingController(text: 'demo123');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 52),
            Text(context.l10n.t('Welcome back'), style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(context.l10n.t('Manage your farm intelligence in demo mode.'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 28),
            Form(
              key: _form,
              child: Column(
                children: [
                  AgroTextField(controller: _email, label: 'Email', icon: Icons.email_outlined, validator: requiredText),
                  const SizedBox(height: 14),
                  AgroTextField(controller: _password, label: 'Password', icon: Icons.lock_outline, obscureText: true, validator: (value) => (value ?? '').length < 6 ? context.l10n.t('Minimum 6 characters') : null),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot'), child: Text(context.l10n.t('Forgot Password?')))),
                  AgroButton(
                    label: 'Login',
                    icon: Icons.login,
                    onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      ref.read(demoRepositoryProvider).login(_email.text, _password.text);
                      context.go('/home');
                    },
                  ),
                  const SizedBox(height: 14),
                  TextButton(onPressed: () => context.push('/register'), child: Text(context.l10n.t('Create Farmer Account'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _village = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController(text: 'Maharashtra');
  final _farmName = TextEditingController();
  final _landSize = TextEditingController();
  final _location = TextEditingController(text: '20.0059, 73.7916');
  final _soilType = TextEditingController(text: 'Black cotton soil');
  final _currentCrop = TextEditingController();
  final _previousCrop = TextEditingController();
  final _previousSeason = TextEditingController(text: 'Kharif');
  final _previousYield = TextEditingController();
  final _previousRevenue = TextEditingController();
  final _soilHealth = TextEditingController(text: '76');
  final _cropHealth = TextEditingController(text: '80');
  final _predictedYield = TextEditingController();
  final _yieldQuantity = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _buyer = TextEditingController();
  final _transportCost = TextEditingController(text: '0');
  final _labourCost = TextEditingController(text: '0');
  final _otherExpenses = TextEditingController(text: '0');
  String _language = 'Marathi';
  String _unit = 'acre';
  String _waterSource = 'Borewell';
  String _irrigationType = 'Drip';

  String? _requiredNumber(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed < 0) return 'Enter a valid number';
    return null;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _mobile,
      _email,
      _password,
      _village,
      _district,
      _state,
      _farmName,
      _landSize,
      _location,
      _soilType,
      _currentCrop,
      _previousCrop,
      _previousSeason,
      _previousYield,
      _previousRevenue,
      _soilHealth,
      _cropHealth,
      _predictedYield,
      _yieldQuantity,
      _sellingPrice,
      _buyer,
      _transportCost,
      _labourCost,
      _otherExpenses,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Farmer & Farm Setup',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RegisterSectionHeader('Farmer Profile'),
            AgroTextField(controller: _name, label: 'Full Name', icon: Icons.person_outline, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _mobile, label: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _email, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _password, label: 'Password', icon: Icons.lock_outline, obscureText: true, validator: (value) => (value ?? '').length < 6 ? context.l10n.t('Minimum 6 characters') : null),
            const SizedBox(height: 12),
            AgroTextField(controller: _village, label: 'Village', icon: Icons.location_city_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _district, label: 'District', icon: Icons.map_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _state, label: 'State', icon: Icons.public, validator: requiredText),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(labelText: context.l10n.t('Preferred Language'), prefixIcon: const Icon(Icons.translate)),
              items: const ['English', 'Hindi', 'Marathi', 'Gujarati', 'Tamil', 'Telugu', 'Kannada', 'Punjabi'].map((item) => DropdownMenuItem(value: item, child: Text(context.l10n.t(item)))).toList(),
              onChanged: (value) => setState(() => _language = value ?? _language),
            ),
            const _RegisterSectionHeader('Farm Details'),
            AgroTextField(controller: _farmName, label: 'Farm Name', icon: Icons.yard_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _landSize, label: 'Land Size', icon: Icons.straighten, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _unit,
              decoration: InputDecoration(labelText: context.l10n.t('Area Unit'), prefixIcon: const Icon(Icons.square_foot)),
              items: const ['acre', 'hectare'].map((item) => DropdownMenuItem(value: item, child: Text(context.l10n.t(item)))).toList(),
              onChanged: (value) => setState(() => _unit = value ?? _unit),
            ),
            const SizedBox(height: 12),
            AgroTextField(controller: _location, label: 'Farm Location / GPS', icon: Icons.pin_drop_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _currentCrop, label: 'Current Crop', icon: Icons.grass_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _predictedYield, label: 'Predicted Yield Tonnes', icon: Icons.trending_up, keyboardType: TextInputType.number, validator: _requiredNumber),
            const _RegisterSectionHeader('Soil Information'),
            AgroTextField(controller: _soilType, label: 'Soil Type', icon: Icons.science_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _soilHealth, label: 'Soil Health Score', icon: Icons.spa_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            AgroTextField(controller: _cropHealth, label: 'Crop Health Score', icon: Icons.health_and_safety_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const _RegisterSectionHeader('Irrigation Details'),
            DropdownButtonFormField<String>(
              value: _waterSource,
              decoration: InputDecoration(labelText: context.l10n.t('Water Source'), prefixIcon: const Icon(Icons.water)),
              items: const ['Well', 'Borewell', 'Canal', 'River', 'Rainwater', 'Other'].map((item) => DropdownMenuItem(value: item, child: Text(context.l10n.t(item)))).toList(),
              onChanged: (value) => setState(() => _waterSource = value ?? _waterSource),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _irrigationType,
              decoration: InputDecoration(labelText: context.l10n.t('Irrigation Type'), prefixIcon: const Icon(Icons.water_drop_outlined)),
              items: const ['Drip', 'Sprinkler', 'Flood', 'Rain-fed', 'Other'].map((item) => DropdownMenuItem(value: item, child: Text(context.l10n.t(item)))).toList(),
              onChanged: (value) => setState(() => _irrigationType = value ?? _irrigationType),
            ),
            const _RegisterSectionHeader('Crop History'),
            AgroTextField(controller: _previousCrop, label: 'Previous Crop', icon: Icons.timeline, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _previousSeason, label: 'Previous Season', icon: Icons.calendar_month_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _previousYield, label: 'Previous Yield Tonnes', icon: Icons.scale_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            AgroTextField(controller: _previousRevenue, label: 'Previous Revenue', icon: Icons.currency_rupee, keyboardType: TextInputType.number, validator: _requiredNumber),
            const _RegisterSectionHeader('Yield Records & Analytics'),
            AgroTextField(controller: _yieldQuantity, label: 'Latest Yield Quantity kg', icon: Icons.inventory_2_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            AgroTextField(controller: _sellingPrice, label: 'Selling Price per kg', icon: Icons.sell_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            AgroTextField(controller: _buyer, label: 'Buyer / Market Name', icon: Icons.storefront_outlined, validator: requiredText),
            const SizedBox(height: 12),
            AgroTextField(controller: _transportCost, label: 'Transportation Cost', icon: Icons.local_shipping_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            AgroTextField(controller: _labourCost, label: 'Labour Cost', icon: Icons.groups_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 12),
            AgroTextField(controller: _otherExpenses, label: 'Other Expenses', icon: Icons.receipt_long_outlined, keyboardType: TextInputType.number, validator: _requiredNumber),
            const SizedBox(height: 18),
            AgroButton(
              label: 'Create Digital Twin',
              icon: Icons.person_add_alt,
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                final farmerId = 'farmer_${DateTime.now().millisecondsSinceEpoch}';
                final farmId = 'farm_${DateTime.now().microsecondsSinceEpoch}';
                final landSize = double.parse(_landSize.text);
                final farmName = _farmName.text.trim();
                ref.read(demoRepositoryProvider).registerWithDigitalTwin(
                      nextFarmer: Farmer(
                        id: farmerId,
                        fullName: _name.text.trim(),
                        mobile: _mobile.text.trim(),
                        email: _email.text.trim(),
                        village: _village.text.trim(),
                        district: _district.text.trim(),
                        state: _state.text.trim(),
                        language: _language,
                        totalLand: landSize,
                        cooperativeStatus: 'Not joined',
                      ),
                      primaryFarm: Farm(
                        id: farmId,
                        userId: farmerId,
                        name: farmName,
                        landSize: landSize,
                        unit: _unit,
                        village: _village.text.trim(),
                        location: _location.text.trim(),
                        soilType: _soilType.text.trim(),
                        waterSource: _waterSource,
                        irrigationType: _irrigationType,
                        currentCrop: _currentCrop.text.trim(),
                        plantingDate: DateTime.now().subtract(const Duration(days: 20)),
                        expectedHarvest: DateTime.now().add(const Duration(days: 85)),
                        soilHealth: double.parse(_soilHealth.text).clamp(0, 100).round(),
                        cropHealth: double.parse(_cropHealth.text).clamp(0, 100).round(),
                        predictedYieldTonnes: double.parse(_predictedYield.text),
                        status: FarmStatus.healthy,
                      ),
                      firstCropHistory: CropHistory(
                        year: DateTime.now().year,
                        crop: _previousCrop.text.trim(),
                        farm: farmName,
                        season: _previousSeason.text.trim(),
                        area: landSize,
                        yieldTonnes: double.parse(_previousYield.text),
                        revenue: double.parse(_previousRevenue.text),
                      ),
                      firstYieldRecord: YieldRecord(
                        crop: _currentCrop.text.trim(),
                        farm: farmName,
                        harvestDate: DateTime.now(),
                        quantityKg: double.parse(_yieldQuantity.text),
                        sellingPricePerKg: double.parse(_sellingPrice.text),
                        buyer: _buyer.text.trim(),
                        transportationCost: double.parse(_transportCost.text),
                        labourCost: double.parse(_labourCost.text),
                        otherExpenses: double.parse(_otherExpenses.text),
                      ),
                    );
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterSectionHeader extends StatelessWidget {
  const _RegisterSectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(context.l10n.t(title), style: Theme.of(context).textTheme.titleLarge)),
          const Icon(Icons.check_circle_outline, size: 20),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    return ScreenScaffold(
      title: 'Reset Password',
      child: Column(
        children: [
          AgroTextField(controller: email, label: 'Email or Mobile Number', icon: Icons.mark_email_unread_outlined),
          const SizedBox(height: 18),
          AgroButton(
            label: 'Send OTP',
            icon: Icons.sms_outlined,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t('OTP-ready reset flow prepared for Firebase Authentication.')))),
          ),
        ],
      ),
    );
  }
}
