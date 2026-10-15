import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/user_session.dart';
import '../constants/storage_keys.dart';

class LanguageService {
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'am', 'name': 'Amharic', 'nativeName': 'አማርኛ (Amharic)'},
    {'code': 'or', 'name': 'Afaan Oromoo', 'nativeName': 'Afaan Oromoo'},
    {'code': 'ti', 'name': 'Tigrinya', 'nativeName': 'ትግርኛ (Tigrinya)'},
  ];

  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  static String get currentLanguage => languageNotifier.value;

  static String get currentLanguageName {
    final match = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageNotifier.value,
      orElse: () => {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    );
    return match['nativeName'] ?? match['name'] ?? 'English';
  }

  /// Initialize language setting from SharedPreferences or UserSession.
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(StorageKeys.language);
      if (savedLang != null && _isSupported(savedLang)) {
        languageNotifier.value = savedLang;
        return;
      }

      final user = await UserSession.get();
      if (user != null && _isSupported(user.preferredLanguage)) {
        languageNotifier.value = user.preferredLanguage;
        await prefs.setString(StorageKeys.language, user.preferredLanguage);
      }
    } catch (e) {
      debugPrint('[LanguageService] initialize error: $e');
    }
  }

  /// Change and persist language selection.
  static Future<void> setLanguage(String code) async {
    final normalized = code.toLowerCase().trim();
    if (!_isSupported(normalized)) return;

    languageNotifier.value = normalized;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.language, normalized);

      final user = await UserSession.get();
      if (user != null) {
        final updatedUser = user.copyWith(preferredLanguage: normalized);
        UserSession.set(updatedUser);
        await prefs.setString('user', jsonEncode(updatedUser.toJson()));
      }
    } catch (e) {
      debugPrint('[LanguageService] setLanguage save error: $e');
    }
  }

  static bool _isSupported(String code) {
    return supportedLanguages.any((lang) => lang['code'] == code);
  }

  /// Dictionary-based UI translations
  static const Map<String, Map<String, String>> _translations = {
    'select_language': {
      'en': 'Select Language',
      'am': 'ቋንቋ ይምረጡ',
      'or': 'Afaan Filadhu',
      'ti': 'ቋንቋ ምረጽ',
    },
    'choose_language_desc': {
      'en': 'Choose your preferred language to continue.',
      'am': 'ለመቀጠል የመረጡትን ቋንቋ ይምረጡ።',
      'or': 'Itti fufuuf afaan barbaaddan filadhaa.',
      'ti': 'ንቕድሚት ንምቕጻል ዝመረጽኩምዎ ቋንቋ ምረጹ።',
    },
    'continue': {
      'en': 'Continue',
      'am': 'ቀጥል',
      'or': 'Itti Fufi',
      'ti': 'ቀጽል',
    },
    'login': {
      'en': 'Login',
      'am': 'ግባ',
      'or': 'Seensa',
      'ti': 'እቶ',
    },
    'register': {
      'en': 'Register',
      'am': 'ተመዝገብ',
      'or': 'Galmaa\'i',
      'ti': 'ተመዝገብ',
    },
    'phone_or_email': {
      'en': 'Phone or Email',
      'am': 'ስልክ ወይም ኢሜይል',
      'or': 'Bilbila ykn Imeelii',
      'ti': 'ስልኪ ወይ ኢመይል',
    },
    'password': {
      'en': 'Password',
      'am': 'የይለፍ ቃል',
      'or': 'Jecha Darbii',
      'ti': 'መሕለፊ ቃል',
    },
    'remember_me': {
      'en': 'Remember me',
      'am': 'አስታውሰኝ',
      'or': 'Na yaadadhu',
      'ti': 'ዘክረኒ',
    },
    'change_language': {
      'en': 'Change Language',
      'am': 'ቋንቋ ቀይር',
      'or': 'Afaan Jijjiiri',
      'ti': 'ቋንቋ ቐይር',
    },
    'app_language': {
      'en': 'App Language',
      'am': 'የመተግበሪያ ቋንቋ',
      'or': 'Afaan Appii',
      'ti': 'ናይ ኣፕ ቋንቋ',
    },
    'logout': {
      'en': 'Logout',
      'am': 'ውጣ',
      'or': 'Ba\'i',
      'ti': 'ውጻእ',
    },
    'settings': {
      'en': 'Settings',
      'am': 'ቅንብሮች',
      'or': 'Qindaa\'inoota',
      'ti': 'ቅጥዕታት',
    },
    'language_updated': {
      'en': 'Language successfully updated',
      'am': 'ቋንቋ በተሳካ ሁኔታ ተቀይሯል',
      'or': 'Afaan milkaa\'inaan jijjiirameera',
      'ti': 'ቋንቋ ብዕዉት መንገዲ ተቐዪሩ',
    },
    'welcome_back': {
      'en': 'Welcome back',
      'am': 'እንኳን ደህና መጡ',
      'or': 'Baga nagaan dhufte',
      'ti': 'እንቋዕ ደሓን መጻእካ',
    },
    'farmer_dashboard': {
      'en': 'Farmer Dashboard',
      'am': 'የገበሬ ዳሽቦርድ',
      'or': 'Daashboordii Qotee Bulaa',
      'ti': 'ዳሽቦርድ ሓረስታይ',
    },
    'current_conditions': {
      'en': 'Current Conditions',
      'am': 'የአሁኑ ሁኔታ',
      'or': 'Haala Ammaa',
      'ti': 'ናይ ሕጂ ኩነታት',
    },
    'agricultural_info': {
      'en': 'Agricultural Information',
      'am': 'የግብርና መረጃ',
      'or': 'Odeeffannoo Qonnaa',
      'ti': 'ሓበሬታ ሕርሻ',
    },
    'agricultural_info_desc': {
      'en': 'Best practices, guides and crop advisories.',
      'am': 'ምርጥ ተሞክሮዎች፣ መመሪያዎች እና የሰብል ምክሮች።',
      'or': 'Shaakala gaarii, qajeelfamaafi gorsa midhaanii.',
      'ti': 'ዝበለጸ ተመኩሮታት፣ መምርሒታትን ምኽሪ እኽሊን።',
    },
    'alerts': {
      'en': 'Alerts',
      'am': 'ማስጠንቀቂያዎች',
      'or': 'Akeekkachiisota',
      'ti': 'መጠንቀቕታታት',
    },
    'alerts_desc': {
      'en': 'Pest, weather and disease warnings near you.',
      'am': 'በአቅራቢያዎ ያሉ ተባይ፣ የአየር ሁኔታ እና የበሽታ ማስጠንቀቂያዎች።',
      'or': 'Akeekkachiisa ilbiisota, qilleensaafi dhibee naannoo keessan.',
      'ti': 'ኣብ ጥቓኻ ዘለዉ ተባራዕቲ፣ ኩነታት ኣየርን ሕማማትን መጠንቀቕታታት።',
    },
    'messages': {
      'en': 'Messages',
      'am': 'መልእክቶች',
      'or': 'Ergaalee',
      'ti': 'መልእኽትታት',
    },
    'voice_info': {
      'en': 'Voice Information',
      'am': 'የድምጽ መረጃ',
      'or': 'Odeeffannoo Sagalee',
      'ti': 'ሓበሬታ ድምጺ',
    },
    'recent_activity': {
      'en': 'Recent Activity',
      'am': 'የቅርብ ጊዜ እንቅስቃሴ',
      'or': 'Hojii Dhiyoo',
      'ti': 'ናይ ቀረባ ግዜ ንጥፈት',
    },
    'view_all': {
      'en': 'View all',
      'am': 'ሁሉንም ይመልከቱ',
      'or': 'Hunda Ilaali',
      'ti': 'ኩሉ ርአ',
    },
    'my_profile': {
      'en': 'My Profile',
      'am': 'የእኔ መገለጫ',
      'or': 'Profaayilii Koo',
      'ti': 'ፕሮፋይለይ',
    },
    'farm_details': {
      'en': 'Farm Details',
      'am': 'የእርሻ ዝርዝሮች',
      'or': 'Ibsa Qonnaa',
      'ti': 'ዝርዝር ሕርሻ',
    },
    'registered_crops': {
      'en': 'Registered Crops',
      'am': 'የተመዘገቡ ሰብሎች',
      'or': 'Midhaanota Galmaa\'an',
      'ti': 'ዝተመዝገቡ ዘራእቲ',
    },
    'settings_preferences': {
      'en': 'Settings & Preferences',
      'am': 'ቅንብሮች እና ምርጫዎች',
      'or': 'Qindaa\'inaafi Filannoo',
      'ti': 'ቅጥዕታትን ምርጫታትን',
    },
    'enable_alerts': {
      'en': 'Enable Alerts',
      'am': 'ማስጠንቀቂያዎችን አንቃ',
      'or': 'Akeekkachiisa Banaa',
      'ti': 'መጠንቀቕታታት ኣንቅሕ',
    },
    'receive_sms': {
      'en': 'Receive SMS warnings',
      'am': 'የኤስኤምኤስ ማስጠንቀቂያዎችን ተቀበል',
      'or': 'Akeekkachiisa SMS fudhachuu',
      'ti': 'ናይ ኤስኤምኤስ መጠንቀቕታታት ተቐበል',
    },
    'farm_location': {
      'en': 'Farm Location',
      'am': 'የእርሻ ቦታ',
      'or': 'Iddoo Qonnaa',
      'ti': 'ቦታ ሕርሻ',
    },
    'data_synced': {
      'en': 'Data synced successfully.',
      'am': 'ውሂብ በተሳካ ሁኔታ ተመሳስሏል።',
      'or': 'Daataan milkaa\'inaan walsimame.',
      'ti': 'ዳታ ብዕዉት ተመሳሲሉ።',
    },
    'save': {
      'en': 'Save Configuration',
      'am': 'ውቅር አስቀምጥ',
      'or': 'Qindaa\'ina Kuusuu',
      'ti': 'ውቅረት ዓቅብ',
    },
    'admin_settings': {
      'en': 'Admin Settings',
      'am': 'የአስተዳዳሪ ቅንብሮች',
      'or': 'Qindaa\'ina Bulchiinsaa',
      'ti': 'ቅጥዕታት ኣመሓዳሪ',
    },
    'no_account': {
      'en': "Don't have an account? Register",
      'am': 'መለያ የለዎትም? ተመዝገቡ',
      'or': 'Herrega hin qabduu? Galmaa\'i',
      'ti': 'ኣካውንት የብልካን? ተመዝገብ',
    },
  };

  static String tr(String key) {
    final lang = currentLanguage;
    final dict = _translations[key];
    if (dict == null) return key;
    return dict[lang] ?? dict['en'] ?? key;
  }
}
