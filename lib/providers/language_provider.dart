import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../services/translation_service.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en');

  Future<void> init() async {
    try {
      final savedLang = await FirebaseService.instance.getLanguage();
      if (savedLang != null && savedLang.isNotEmpty) {
        state = savedLang;
      } else {
        state = 'en'; // Explicit default for new users
      }
    } catch (e) {
      state = 'en'; // Explicit fallback on error/timeout
    }
  }

  Future<void> setLanguage(String langCode) async {
    state = langCode;
    try {
      await FirebaseService.instance.saveLanguage(langCode);
    } catch (e) {
      // Fail silently
    }
  }
}

final translationProvider = Provider<Map<String, String>>((ref) {
  final langCode = ref.watch(languageProvider);
  return TranslationService.translations[langCode] ?? TranslationService.translations['en']!;
});
