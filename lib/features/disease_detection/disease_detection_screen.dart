import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class DiseaseDetectionScreen extends ConsumerStatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  ConsumerState<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends ConsumerState<DiseaseDetectionScreen> {
  final _picker = ImagePicker();
  bool _scanning = false;
  DiseaseReport? _report;
  XFile? _image;

  Future<void> _pickAndScan(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 82, maxWidth: 1400);
    if (image == null) return;
    setState(() {
      _image = image;
      _scanning = true;
      _report = null;
    });
    final result = await ref.read(visionServiceProvider).scanMock();
    if (mounted) {
      setState(() {
        _scanning = false;
        _report = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Scan Crop',
      child: Column(
        children: [
          AgroCard(
            child: Column(
              children: [
                Container(
                  height: 210,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: AgroColors.lightGreen.withOpacity(0.16), borderRadius: BorderRadius.circular(8)),
                  child: _image == null
                      ? Icon(_report == null ? Icons.add_a_photo_outlined : Icons.image_search, size: 72, color: AgroColors.primaryGreen)
                      : Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: AgroButton(label: 'Take Photo', icon: Icons.camera_alt_outlined, onPressed: () => _pickAndScan(ImageSource.camera))),
                    const SizedBox(width: 12),
                    Expanded(child: AgroButton(label: 'Gallery', icon: Icons.photo_library_outlined, onPressed: () => _pickAndScan(ImageSource.gallery))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_scanning)
            AgroCard(child: Column(children: [const LinearProgressIndicator(), const SizedBox(height: 12), Text(context.l10n.t('Analysing crop...'))]))
          else if (_report != null)
            DiseaseResultCard(report: _report!)
          else
            AgroEmptyState(title: 'No scan yet', message: 'Take or upload a crop photo to get disease guidance.', actionLabel: 'Start Scan', onAction: () => _pickAndScan(ImageSource.gallery)),
        ],
      ),
    );
  }
}

class DiseaseResultCard extends StatelessWidget {
  const DiseaseResultCard({required this.report, super.key});
  final DiseaseReport report;

  @override
  Widget build(BuildContext context) {
    return AgroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t('Detected Disease'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(report.disease, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 10, children: [
            AgroStatusBadge(label: '${context.l10n.t('Confidence')} ${(report.confidence * 100).round()}%', color: AgroColors.primaryGreen),
            AgroStatusBadge(label: report.severity, color: AgroColors.warning),
          ]),
          const SizedBox(height: 14),
          _Section('Symptoms', report.symptoms.join('\n')),
          _Section('Possible Cause', report.cause),
          _Section('Recommended Action', report.actions.join('\n')),
          _Section('Treatment', report.treatment),
          _Section('Prevention', report.prevention),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: AgroButton(label: 'Ask Agro AI', icon: Icons.auto_awesome, onPressed: () => context.push('/ai'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t('Disease report saved in demo reports.')))), icon: const Icon(Icons.save_outlined), label: Text(context.l10n.t('Save Report')))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.t(title), style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(context.l10n.t(body))]),
    );
  }
}
