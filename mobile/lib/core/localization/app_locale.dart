import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppLocale provides reactive language management and localized string lookup.
class AppLocale extends ChangeNotifier {
  static final AppLocale instance = AppLocale._internal();
  AppLocale._internal();

  static const List<String> supportedLanguageCodes = ['en', 'am', 'or', 'ti'];

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;
  Locale get currentLocale => Locale(_currentLanguage);

  bool get isAmharic => _currentLanguage == 'am';

  static const String _prefKey = 'selected_language';

  String get currentLanguageName => languageName(_currentLanguage);

  static String languageName(String code) => switch (code) {
    'am' => 'Amharic (አማርኛ)',
    'or' => 'Afaan Oromoo',
    'ti' => 'Tigrinya (ትግርኛ)',
    _ => 'English',
  };

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _currentLanguage = _supportedCode(saved) ? saved! : 'en';
    notifyListeners();
  }

  Future<void> initializeForUser({
    required String userId,
    required String preferredLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_userPrefKey(userId));
    final code = _supportedCode(saved)
        ? saved!
        : _supportedCode(preferredLanguage)
        ? preferredLanguage
        : 'en';
    await _saveLanguage(code, prefs, userId);
  }

  Future<void> setLanguage(String code, {String? userId}) async {
    final normalizedCode = _supportedCode(code) ? code : 'en';
    final prefs = await SharedPreferences.getInstance();
    await _saveLanguage(normalizedCode, prefs, userId);
  }

  bool _supportedCode(String? code) =>
      code != null && supportedLanguageCodes.contains(code);

  String _userPrefKey(String userId) => '${_prefKey}_$userId';

  Future<void> _saveLanguage(
    String code,
    SharedPreferences prefs,
    String? userId,
  ) async {
    if (_currentLanguage != code) {
      _currentLanguage = code;
      notifyListeners();
    }
    await prefs.setString(_prefKey, code);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_userPrefKey(userId), code);
    }
  }

  /// Look up localized string by key with English fallback
  String tr(String key) {
    final translations = switch (_currentLanguage) {
      'am' => _amharicStrings,
      'or' => _oromoStrings,
      'ti' => _tigrinyaStrings,
      _ => _englishStrings,
    };
    return translations[key] ?? _englishStrings[key] ?? key;
  }

  static final Map<String, String> _englishStrings = {
    // App & Auth
    'app_title': 'Agri-Insight Beacon',
    'login': 'Log In',
    'register': 'Register',
    'logout': 'Log Out',
    'confirm_logout': 'Confirm Log Out',
    'logout_prompt': 'Are you sure you want to end your current session?',
    'cancel': 'Cancel',
    'save': 'Save',
    'submit': 'Submit',
    'continue': 'Continue',
    'select_language': 'Select Language',
    'choose_language_desc': 'Choose your preferred language to continue.',
    'change_language': 'Change language',
    'password': 'Password',
    'current_password': 'Current Password',
    'new_password': 'New Password',
    'confirm_password': 'Confirm New Password',
    'change_password': 'Change Password',
    'security_settings': 'Security & Password',

    // Roles
    'role_admin': 'System Administrator',
    'role_expert': 'Agricultural Expert',
    'role_worker': 'Extension Worker',
    'role_farmer': 'Farmer',

    // Dashboards & Navigation
    'dashboard': 'Dashboard',
    'notifications': 'Notifications',
    'view_all': 'View All',
    'pending_approvals': 'Pending Approvals',
    'registered_farmers': 'Registered Farmers',
    'field_cases': 'Field Cases',
    'advisories': 'Crop Advisories',
    'audit_logs': 'System Audit Logs',
    'settings': 'Settings',
    'analytics': 'Analytics',
    'nav_home': 'Home',
    'nav_information': 'Information',
    'nav_alerts': 'Alerts',
    'nav_profile': 'Profile',
    'nav_directory': 'Directory',
    'nav_review': 'Review',
    'nav_cases': 'Cases',
    'nav_approvals': 'Approvals',
    'nav_users': 'Users',
    'nav_audit_logs': 'Audit Logs',
    'nav_settings': 'Settings',

    // Statuses
    'status_open': 'Open',
    'status_in_review': 'In Review',
    'status_resolved': 'Resolved',
    'status_approved': 'Approved',
    'status_pending': 'Pending',
    'status_rejected': 'Rejected',

    // Ethiopia Geography & Crops
    'region': 'Region',
    'zone': 'Zone',
    'woreda': 'Woreda',
    'kebele': 'Kebele',
    'crop_teff': 'Teff',
    'crop_maize': 'Maize',
    'crop_wheat': 'Wheat',
    'crop_coffee': 'Coffee',
    'crop_barley': 'Barley',
    'crop_sorghum': 'Sorghum',
    'crop_sesame': 'Sesame',

    // Simulators
    'sms_simulator': 'SMS Query Simulator',
    'ivr_simulator': 'IVR Voice Simulator',
    'dtmf_dialpad': 'DTMF Dialpad',
  };

  static final Map<String, String> _amharicStrings = {
    'app_title': 'አግሪ-ኢንሳይት ቢከን',
    'login': 'ግባ',
    'register': 'ይመዝገቡ',
    'logout': 'ውጣ',
    'confirm_logout': 'መውጣትን አረጋግጥ',
    'logout_prompt': 'እርግጠኛ ነዎት ከአካውንትዎ መውጣት ይፈልጋሉ?',
    'cancel': 'ይቅር',
    'save': 'አስቀምጥ',
    'submit': 'አስገባ',
    'continue': 'ቀጥል',
    'select_language': 'ቋንቋ ይምረጡ',
    'choose_language_desc': 'ለመቀጠል ተመራጭ ቋንቋዎን ይምረጡ።',
    'change_language': 'ቋንቋ ቀይር',
    'password': 'የይለፍ ቃል',
    'current_password': 'የአሁኑ የይለፍ ቃል',
    'new_password': 'አዲስ የይለፍ ቃል',
    'confirm_password': 'አዲሱን የይለፍ ቃል ያረጋግጡ',
    'change_password': 'የይለፍ ቃል ቀይር',
    'security_settings': 'ደህንነት እና የይለፍ ቃል',
    'role_admin': 'የስርዓት አስተዳዳሪ',
    'role_expert': 'የግብርና ባለሙያ',
    'role_worker': 'የልማት ጣቢያ ሰራተኛ',
    'role_farmer': 'አርሶ አደር',
    'dashboard': 'ዳሽቦርድ',
    'notifications': 'ማሳወቂያዎች',
    'view_all': 'ሁሉንም እይ',
    'pending_approvals': 'ማረጋገጫ የሚጠብቁ',
    'registered_farmers': 'የተመዘገቡ አርሶ አደሮች',
    'field_cases': 'የመስክ ጉዳዮች',
    'advisories': 'የሰብል ምክረ-ሀሳቦች',
    'audit_logs': 'የስርዓት ክትትል ምዝግብ',
    'settings': 'ቅንብሮች',
    'analytics': 'ትንታኔ',
    'nav_home': 'መነሻ',
    'nav_information': 'መረጃ',
    'nav_alerts': 'ማንቂያዎች',
    'nav_profile': 'መገለጫ',
    'nav_directory': 'ማውጫ',
    'nav_review': 'ግምገማ',
    'nav_cases': 'ጉዳዮች',
    'nav_approvals': 'ማጽደቂያዎች',
    'nav_users': 'ተጠቃሚዎች',
    'nav_audit_logs': 'የክትትል ምዝግብ',
    'nav_settings': 'ቅንብሮች',
    'status_open': 'ክፍት',
    'status_in_review': 'በግምገማ ላይ',
    'status_resolved': 'የተፈታ',
    'status_approved': 'የፀደቀ',
    'status_pending': 'በመጠባበቅ ላይ',
    'status_rejected': 'ውድቅ የተደረገ',
    'region': 'ክልል',
    'zone': 'ዞን',
    'woreda': 'ወረዳ',
    'kebele': 'ቀበሌ',
    'crop_teff': 'ጤፍ',
    'crop_maize': 'በቆሎ',
    'crop_wheat': 'ስንዴ',
    'crop_coffee': 'ቡና',
    'crop_barley': 'ገብስ',
    'crop_sorghum': 'ማሽላ',
    'crop_sesame': 'ሰሊጥ',
    'sms_simulator': 'የኤስ.ኤም.ኤስ ማስመሰያ',
    'ivr_simulator': 'የድምፅ ምላሽ (IVR) ማስመሰያ',
    'dtmf_dialpad': 'የመደወያ ቁልፎች',
  };

  static final Map<String, String> _oromoStrings = {
    'login': 'Seeni',
    'register': 'Galmaa’i',
    'logout': 'Ba’i',
    'cancel': 'Dhiisi',
    'save': 'Olkaa’i',
    'submit': 'Ergi',
    'continue': 'Itti fufi',
    'select_language': 'Afaan filadhu',
    'choose_language_desc': 'Itti fufuuf afaan ati filattu filadhu.',
    'change_language': 'Afaan jijjiiri',
    'password': 'Jecha darbii',
    'role_admin': 'Bulchaa sirnaa',
    'role_expert': 'Ogeessa qonnaa',
    'role_worker': 'Hojjetaa ekisteenshinii',
    'role_farmer': 'Qonnaan bulaa',
    'dashboard': 'Gabatee hojii',
    'notifications': 'Beeksisawwan',
    'view_all': 'Hunda ilaali',
    'pending_approvals': 'Mirkaneessa eegaa jiran',
    'registered_farmers': 'Qonnaan bultoota galmaa’an',
    'field_cases': 'Dhimmoota dirree',
    'advisories': 'Gorsa midhaanii',
    'settings': 'Qindaa’ina',
    'analytics': 'Xiinxala',
    'nav_home': 'Mana',
    'nav_information': 'Odeeffannoo',
    'nav_alerts': 'Akeekkachiisa',
    'nav_profile': 'Seenaa dhuunfaa',
    'nav_directory': 'Galmee',
    'nav_review': 'Qorannoo',
    'nav_cases': 'Dhimmoota',
    'nav_approvals': 'Mirkaneessawwan',
    'nav_users': 'Fayyadamtoota',
    'nav_audit_logs': 'Galmee hordoffii',
    'nav_settings': 'Qindaa’ina',
    'status_open': 'Banamaa',
    'status_resolved': 'Furame',
    'status_pending': 'Eegaa jira',
    'region': 'Naannoo',
    'zone': 'Godina',
    'woreda': 'Aanaa',
    'kebele': 'Ganda',
    'crop_teff': 'Xaafii',
    'crop_maize': 'Boqqolloo',
    'crop_wheat': 'Qamadii',
    'crop_coffee': 'Buna',
    'crop_barley': 'Garbuu',
    'crop_sorghum': 'Mishingaa',
    'crop_sesame': 'Saliixa',
    'sms_simulator': 'Simuleetara gaaffii SMS',
    'ivr_simulator': 'Simuleetara sagalee IVR',
    'dtmf_dialpad': 'Gabatee lakkoofsaa DTMF',
  };

  static final Map<String, String> _tigrinyaStrings = {
    'login': 'እቶ',
    'register': 'ተመዝገብ',
    'logout': 'ውጻእ',
    'cancel': 'ሰርዝ',
    'save': 'ኣቐምጥ',
    'submit': 'ኣረክብ',
    'continue': 'ቀጽል',
    'select_language': 'ቋንቋ ምረጽ',
    'choose_language_desc': 'ንምቕጻል ዝመረጽካዮ ቋንቋ ምረጽ።',
    'change_language': 'ቋንቋ ቀይር',
    'password': 'መሕለፊ ቃል',
    'role_admin': 'ሓላፊ ስርዓት',
    'role_expert': 'ክኢላ ሕርሻ',
    'role_worker': 'ናይ ሕርሻ ኤክስቴንሽን ሰራሕተኛ',
    'role_farmer': 'ሓረስታይ',
    'dashboard': 'ዳሽቦርድ',
    'notifications': 'ምልክታታት',
    'view_all': 'ኩሉ ርአ',
    'pending_approvals': 'ምጽዳቕ ዝጽበዩ',
    'registered_farmers': 'ዝተመዝገቡ ሓረስቶት',
    'field_cases': 'ጉዳያት መስክ',
    'advisories': 'ምኽሪ ዝራእቲ',
    'settings': 'ቅጥዕታት',
    'analytics': 'ትንተና',
    'nav_home': 'መበገሲ',
    'nav_information': 'ሓበሬታ',
    'nav_alerts': 'መጠንቀቕታ',
    'nav_profile': 'መግለጺ መንነት',
    'nav_directory': 'ዝርዝር',
    'nav_review': 'ገምጋም',
    'nav_cases': 'ጉዳያት',
    'nav_approvals': 'ምጽዳቕ',
    'nav_users': 'ተጠቀምቲ',
    'nav_audit_logs': 'መዝገብ ክትትል',
    'nav_settings': 'ቅጥዕታት',
    'status_open': 'ክፉት',
    'status_resolved': 'ተፈቲሑ',
    'status_pending': 'ይጽበ ኣሎ',
    'region': 'ክልል',
    'zone': 'ዞባ',
    'woreda': 'ወረዳ',
    'kebele': 'ቀበሌ',
    'crop_teff': 'ጣፍ',
    'crop_maize': 'በቆሎ',
    'crop_wheat': 'ስርናይ',
    'crop_coffee': 'ቡን',
    'crop_barley': 'ስገም',
    'crop_sorghum': 'ማሽላ',
    'crop_sesame': 'ሰሊጥ',
    'sms_simulator': 'ናይ SMS ሕቶ ሲሙሌተር',
    'ivr_simulator': 'ናይ IVR ድምጺ ሲሙሌተር',
    'dtmf_dialpad': 'DTMF መደወያ',
  };
}

/// Helper extension for quick translation
extension StringLocalization on String {
  String get tr => AppLocale.instance.tr(this);
}
