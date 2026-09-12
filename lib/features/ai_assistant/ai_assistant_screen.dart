import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/agro_widgets.dart';
import '../../models/entities.dart';
import '../../repositories/providers.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _input = TextEditingController();
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();
  bool _typing = false;
  bool _listening = false;
  bool _voiceReady = false;
  String _language = 'Marathi';

  static const _locales = {
    'English': 'en-IN',
    'Hindi': 'hi-IN',
    'Marathi': 'mr-IN',
    'Gujarati': 'gu-IN',
    'Tamil': 'ta-IN',
    'Telugu': 'te-IN',
    'Kannada': 'kn-IN',
    'Punjabi': 'pa-IN',
  };

  static const _languageCodes = {
    'en': 'English',
    'hi': 'Hindi',
    'mr': 'Marathi',
    'gu': 'Gujarati',
    'ta': 'Tamil',
    'te': 'Telugu',
    'kn': 'Kannada',
    'pa': 'Punjabi',
  };

  @override
  void initState() {
    super.initState();
    _setupVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = ref.read(demoRepositoryProvider);
      final appCode = ref.read(appLanguageProvider).code;
      _language = _languageCodes[appCode] ?? repo.farmer.language;
      if (repo.chat.isEmpty) {
        repo.addChat(ChatMessage(id: 'welcome', text: context.l10n.t('Namaste. How can I help with your farm today?'), isUser: false, createdAt: DateTime.now()));
      }
    });
  }

  Future<void> _setupVoice() async {
    final ready = await _speech.initialize(onStatus: _handleSpeechStatus);
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.setLanguage(_locales[_language] ?? 'en-IN');
    if (mounted) setState(() => _voiceReady = ready);
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_voiceReady) {
      final ready = await _speech.initialize(onStatus: _handleSpeechStatus);
      if (!mounted) return;
      setState(() => _voiceReady = ready);
      if (!ready) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.t('Microphone permission is needed for voice chat.'))));
        return;
      }
    }
    setState(() => _listening = true);
    await _speech.listen(
      localeId: _locales[_language] ?? 'en-IN',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onSoundLevelChange: (_) {},
      onResult: (result) {
        setState(() => _input.text = result.recognizedWords);
        if (result.finalResult) {
          setState(() => _listening = false);
          _sendMessage(result.recognizedWords, speak: true);
        }
      },
    );
  }

  void _handleSpeechStatus(String status) {
    if ((status == 'done' || status == 'notListening') && mounted) {
      setState(() => _listening = false);
    }
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage(_locales[_language] ?? 'en-IN');
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _send(String text) async {
    return _sendMessage(text, speak: false);
  }

  Future<void> _sendMessage(String text, {required bool speak}) async {
    if (text.trim().isEmpty) return;
    final repo = ref.read(demoRepositoryProvider);
    repo.addChat(ChatMessage(id: DateTime.now().microsecondsSinceEpoch.toString(), text: text.trim(), isUser: true, createdAt: DateTime.now()));
    _input.clear();
    setState(() => _typing = true);
    final response = await ref.read(aiServiceProvider).ask(
          text,
          farmer: repo.farmer,
          farms: repo.farms,
          marketPrices: repo.marketPrices,
          schemes: repo.schemes,
          language: _language,
        );
    repo.addChat(response);
    if (mounted) setState(() => _typing = false);
    if (speak) await _speak(response.text);
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(demoRepositoryProvider).chat;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.t('Agro AI')), Text(context.l10n.t('Your personal farming assistant'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]),
        actions: [
          IconButton(onPressed: _toggleListening, icon: Icon(_listening ? Icons.mic : Icons.mic_none)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            initialValue: _language,
            onSelected: (value) async {
              setState(() => _language = value);
              await _tts.setLanguage(_locales[value] ?? 'en-IN');
            },
            itemBuilder: (_) => _locales.keys.map((language) => PopupMenuItem(value: language, child: Text(context.l10n.t(language)))).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  'Which fertilizer should I use?',
                  'Why are my tomato leaves yellow?',
                  'When should I harvest?',
                  'Tell me government schemes.',
                  'Give crop advice for my farm.',
                ].map((prompt) => Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(context.l10n.t(prompt)), onPressed: () => _sendMessage(prompt, speak: true)))).toList(),
              ),
            ),
            if (_listening)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: AgroStatusBadge(label: 'Listening... speak now', color: AgroColors.ai),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chat.length + (_typing ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_typing && index == chat.length) return const _TypingBubble();
                  return _MessageBubble(message: chat[index], onSpeak: chat[index].isUser ? null : () => _speak(chat[index].text));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  IconButton.filledTonal(onPressed: _toggleListening, icon: Icon(_listening ? Icons.stop : Icons.keyboard_voice_outlined)),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(onPressed: () => context.push('/disease'), icon: const Icon(Icons.camera_alt_outlined)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _input, decoration: InputDecoration(hintText: context.l10n.t('Ask Agro AI...')), onSubmitted: _send)),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: () => _sendMessage(_input.text, speak: true), icon: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onSpeak});
  final ChatMessage message;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final align = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? AgroColors.primaryGreen : Theme.of(context).colorScheme.surface;
    return Align(
      alignment: align,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : null, fontWeight: FontWeight.w600))),
                if (onSpeak != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onSpeak,
                    icon: const Icon(Icons.volume_up_outlined, size: 20),
                  ),
                ],
              ],
            ),
            if (message.warning != null) ...[
              const SizedBox(height: 10),
              AgroStatusBadge(label: message.warning!, color: AgroColors.warning),
            ],
            if (message.cards.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...message.cards.map((card) => Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [const Icon(Icons.check_circle, size: 16, color: AgroColors.primaryGreen), const SizedBox(width: 6), Expanded(child: Text(context.l10n.t(card)))]))),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AgroCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(context.l10n.t('Agro AI is analysing farm context...')),
      ),
    );
  }
}
