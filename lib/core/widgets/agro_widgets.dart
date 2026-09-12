import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';

class AgroCard extends StatelessWidget {
  const AgroCard({required this.child, this.padding = const EdgeInsets.all(18), this.onTap, super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dark ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.45) : AgroColors.lime),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withOpacity(0.18) : AgroColors.primaryGreen.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AgroButton extends StatelessWidget {
  const AgroButton({required this.label, required this.onPressed, this.icon, super.key});

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AgroColors.primaryGreen, AgroColors.warm]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(context.l10n.t(label)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      ),
    );
  }
}

class AgroIconButton extends StatelessWidget {
  const AgroIconButton({required this.icon, required this.tooltip, required this.onPressed, super.key});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.t(tooltip),
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

class AgroTextField extends StatelessWidget {
  const AgroTextField({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: context.l10n.t(label), prefixIcon: icon == null ? null : Icon(icon)),
    );
  }
}

class AgroMetricCard extends StatelessWidget {
  const AgroMetricCard({required this.label, required this.value, required this.icon, this.color, super.key});

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return AgroCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 4),
          Text(context.l10n.t(label), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class AgroSectionHeader extends StatelessWidget {
  const AgroSectionHeader({required this.title, this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
      child: Row(
        children: [
          Expanded(child: Text(context.l10n.t(title), style: Theme.of(context).textTheme.titleLarge)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class AgroStatusBadge extends StatelessWidget {
  const AgroStatusBadge({required this.label, this.color = AgroColors.primaryGreen, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(context.l10n.t(label), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class AgroEmptyState extends StatelessWidget {
  const AgroEmptyState({required this.title, required this.message, required this.actionLabel, required this.onAction, super.key});

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        children: [
          const Icon(Icons.eco_outlined, size: 48, color: AgroColors.primaryGreen),
          const SizedBox(height: 12),
          Text(context.l10n.t(title), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(context.l10n.t(message), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          AgroButton(label: actionLabel, icon: Icons.add, onPressed: onAction),
        ],
      ),
    );
  }
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({required this.title, required this.child, this.actions, this.floatingActionButton, super.key});

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t(title)), actions: actions),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
          children: [child],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class AiFloatingButton extends StatelessWidget {
  const AiFloatingButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.auto_awesome),
      label: Text(context.l10n.t('Agro AI')),
      backgroundColor: AgroColors.ai,
      foregroundColor: Colors.white,
    );
  }
}
