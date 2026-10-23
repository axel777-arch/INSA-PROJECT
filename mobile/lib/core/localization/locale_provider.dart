import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

/// Supported language codes in Agri-Insight Beacon
enum AppLanguage {
  english('en', 'English', 'English'),
  amharic('am', 'Amharic', 'አማርኛ'),
  oromo('om', 'Afaan Oromoo', 'Afaan Oromoo');

  final String code;
  final String englishName;
  final String nativeName;

  const AppLanguage(this.code, this.englishName, this.nativeName);

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.english;
    final normalized = code.toLowerCase().trim();
    if (normalized == 'am') return AppLanguage.amharic;
    if (normalized == 'om' || normalized == 'or') return AppLanguage.oromo;
    return AppLanguage.english;
  }
}

/// Global reactive LocaleProvider
class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._internal();

  LocaleProvider._internal();

  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => Locale(_currentLanguage.code);

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(StorageKeys.language);
      if (code != null) {
        _currentLanguage = AppLanguage.fromCode(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.language, language.code);
    } catch (_) {}
  }
}
