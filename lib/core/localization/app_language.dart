import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languagePrefKey = 'agropredict_language_code';

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.region,
    this.locale,
  });

  final String code;
  final String name;
  final String nativeName;
  final String region;
  final Locale? locale;

  bool get isSystem => locale == null;
}

class AppLanguageState {
  const AppLanguageState({required this.code, required this.loaded});

  final String code;
  final bool loaded;

  Locale? get locale => AppLanguages.optionFor(code).locale;
}

class AppLanguages {
  static const systemCode = 'system';

  static const options = [
    LanguageOption(code: systemCode, name: 'System default', nativeName: 'Use phone language', region: 'Recommended'),
    LanguageOption(code: 'en', name: 'English', nativeName: 'English', region: 'India / Global', locale: Locale('en')),
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', region: 'India', locale: Locale('hi')),
    LanguageOption(code: 'mr', name: 'Marathi', nativeName: 'मराठी', region: 'India', locale: Locale('mr')),
    LanguageOption(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', region: 'India', locale: Locale('gu')),
    LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', region: 'India', locale: Locale('ta')),
    LanguageOption(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', region: 'India', locale: Locale('te')),
    LanguageOption(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', region: 'India', locale: Locale('kn')),
    LanguageOption(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', region: 'India', locale: Locale('pa')),
    LanguageOption(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', region: 'India', locale: Locale('bn')),
    LanguageOption(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', region: 'India', locale: Locale('ml')),
    LanguageOption(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', region: 'India', locale: Locale('or')),
    LanguageOption(code: 'es', name: 'Spanish', nativeName: 'Español', region: 'World', locale: Locale('es')),
    LanguageOption(code: 'fr', name: 'French', nativeName: 'Français', region: 'World', locale: Locale('fr')),
    LanguageOption(code: 'ar', name: 'Arabic', nativeName: 'العربية', region: 'World', locale: Locale('ar')),
    LanguageOption(code: 'pt', name: 'Portuguese', nativeName: 'Português', region: 'World', locale: Locale('pt')),
    LanguageOption(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', region: 'World', locale: Locale('id')),
    LanguageOption(code: 'de', name: 'German', nativeName: 'Deutsch', region: 'World', locale: Locale('de')),
    LanguageOption(code: 'ja', name: 'Japanese', nativeName: '日本語', region: 'World', locale: Locale('ja')),
  ];

  static List<Locale> get supportedLocales => options.where((option) => !option.isSystem).map((option) => option.locale!).toList();

  static LanguageOption optionFor(String code) {
    return options.firstWhere((option) => option.code == code, orElse: () => options.first);
  }
}

final appLanguageProvider = StateNotifierProvider<AppLanguageController, AppLanguageState>((ref) {
  return AppLanguageController();
});

class AppLanguageController extends StateNotifier<AppLanguageState> {
  AppLanguageController() : super(const AppLanguageState(code: AppLanguages.systemCode, loaded: false)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languagePrefKey) ?? AppLanguages.systemCode;
    state = AppLanguageState(code: code, loaded: true);
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefKey, code);
    state = AppLanguageState(code: code, loaded: true);
  }

  static Future<bool> hasPickedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_languagePrefKey);
  }
}
