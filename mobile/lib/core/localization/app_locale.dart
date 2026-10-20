import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppLocale provides reactive language management and localized string lookup
/// between English ('en') and Amharic ('am').
class AppLocale extends ChangeNotifier {
  static final AppLocale instance = AppLocale._internal();
  AppLocale._internal();

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;
  Locale get currentLocale => Locale(_currentLanguage);

  bool get isAmharic => _currentLanguage == 'am';

  static const String _prefKey = 'selected_language';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && (saved == 'en' || saved == 'am')) {
      _currentLanguage = saved;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'am') code = 'en';
    if (_currentLanguage == code) return;
    _currentLanguage = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  /// Look up localized string by key with English fallback
  String tr(String key) {
    if (_currentLanguage == 'am') {
      return _amharicStrings[key] ?? _englishStrings[key] ?? key;
    }
    return _englishStrings[key] ?? key;
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
    // App & Auth
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
    'password': 'የይለፍ ቃል',
    'current_password': 'የአሁኑ የይለፍ ቃል',
    'new_password': 'አዲስ የይለፍ ቃል',
    'confirm_password': 'አዲሱን የይለፍ ቃል ያረጋግጡ',
    'change_password': 'የይለፍ ቃል ቀይር',
    'security_settings': 'ደህንነት እና የይለፍ ቃል',

    // Roles
    'role_admin': 'የስርዓት አስተዳዳሪ',
    'role_expert': 'የግብርና ባለሙያ',
    'role_worker': 'የልማት ጣቢያ ሰራተኛ',
    'role_farmer': 'አርሶ አደር',

    // Dashboards & Navigation
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

    // Statuses
    'status_open': 'ክፍት',
    'status_in_review': 'በግምገማ ላይ',
    'status_resolved': 'የተፈታ',
    'status_approved': 'የፀደቀ',
    'status_pending': 'በመጠባበቅ ላይ',
    'status_rejected': 'ውድቅ የተደረገ',

    // Ethiopia Geography & Crops
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

    // Simulators
    'sms_simulator': 'የኤስ.ኤም.ኤስ ማስመሰያ',
    'ivr_simulator': 'የድምፅ ምላሽ (IVR) ማስመሰያ',
    'dtmf_dialpad': 'የመደወያ ቁልፎች',
  };
}

/// Helper extension for quick translation
extension StringLocalization on String {
  String get tr => AppLocale.instance.tr(this);
}
