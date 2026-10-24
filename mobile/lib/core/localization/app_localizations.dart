import 'locale_provider.dart';

/// Multilingual dictionary providing translations for English, Amharic, and Afaan Oromoo.
class AppLocalizations {
  final AppLanguage language;

  const AppLocalizations(this.language);

  static AppLocalizations get current =>
      AppLocalizations(LocaleProvider.instance.currentLanguage);

  static AppLocalizations of(AppLanguage lang) => AppLocalizations(lang);

  // ── Navigation ─────────────────────────────────────────────────────────────
  String get home => switch (language) {
    AppLanguage.amharic => 'መነሻ',
    AppLanguage.oromo => 'Fuula Duraa',
    AppLanguage.english => 'Home',
  };

  String get information => switch (language) {
    AppLanguage.amharic => 'መረጃና ምክሮች',
    AppLanguage.oromo => 'Oduu fi Gorsa',
    AppLanguage.english => 'Information',
  };

  String get market => switch (language) {
    AppLanguage.amharic => 'የገበያ ዋጋ',
    AppLanguage.oromo => 'Gabaa',
    AppLanguage.english => 'Market',
  };

  String get cropCalendar => switch (language) {
    AppLanguage.amharic => 'የሰብል የቀን መቁጠሪያ',
    AppLanguage.oromo => 'Kalaandarii Midhaanii',
    AppLanguage.english => 'Crop Calendar',
  };

  String get alerts => switch (language) {
    AppLanguage.amharic => 'ማስጠንቀቂያዎች',
    AppLanguage.oromo => 'Akeekkachiisa',
    AppLanguage.english => 'Alerts',
  };

  String get profile => switch (language) {
    AppLanguage.amharic => 'የግል መገለጫ',
    AppLanguage.oromo => 'Eenyummeessa',
    AppLanguage.english => 'Profile',
  };

  String get cases => switch (language) {
    AppLanguage.amharic => 'ጥያቄዎችና ኬዞች',
    AppLanguage.oromo => 'Gaaffilee fi Dhimmoota',
    AppLanguage.english => 'Cases & Inquiries',
  };

  String get offlineLibrary => switch (language) {
    AppLanguage.amharic => 'ያለ ኢንተርኔት የተሸመቱ ምክሮች',
    AppLanguage.oromo => 'Gorsawwan Toora Alaa',
    AppLanguage.english => 'Offline Library',
  };

  // ── Dashboard Headings & Greetings ──────────────────────────────────────────
  String welcomeBack(String name) => switch (language) {
    AppLanguage.amharic => 'እንኳን ደህና መጡ፣ $name',
    AppLanguage.oromo => 'Baga nagaan dhufte, $name',
    AppLanguage.english => 'Welcome back, $name',
  };

  String get farmerDashboard => switch (language) {
    AppLanguage.amharic => 'የአርሶ አደር ዳሽቦርድ',
    AppLanguage.oromo => 'Daashboordii Qonnaan Bulaa',
    AppLanguage.english => 'Farmer Dashboard',
  };

  String get syncData => switch (language) {
    AppLanguage.amharic => 'መረጃ አድስ (Sync)',
    AppLanguage.oromo => 'Odeeffannoo Haaromsi',
    AppLanguage.english => 'Sync Data',
  };

  String get quickActions => switch (language) {
    AppLanguage.amharic => 'ፈጣን አገልግሎቶች',
    AppLanguage.oromo => 'Tajaajila Ariifataa',
    AppLanguage.english => 'Quick Actions',
  };

  String get askExtensionWorker => switch (language) {
    AppLanguage.amharic => 'የግብርና ባለሙያ ይጠይቁ',
    AppLanguage.oromo => 'Ogeessa Qonnaa Gaafadhaa',
    AppLanguage.english => 'Ask an Extension Worker',
  };

  String get askWorkerDesc => switch (language) {
    AppLanguage.amharic => 'የሰብል በሽታ ወይም ችግር ፎቶ አንስተው ለባለሙያ ይላኩ',
    AppLanguage.oromo => 'Suuraa fi rakkoo midhaanii erguun gorsa argadhaa',
    AppLanguage.english => 'Submit field photos and get expert guidance for your crops.',
  };

  String get marketPricesTitle => switch (language) {
    AppLanguage.amharic => 'የአካባቢ ገበያ ዋጋዎች',
    AppLanguage.oromo => 'Gatiiwwan Gabaa Naannoo',
    AppLanguage.english => 'Local Market Prices',
  };

  String get marketPricesSubtitle => switch (language) {
    AppLanguage.amharic => 'የጤፍ፣ ስንዴ፣ በቆሎና ሌሎች ሰብሎች የቅርብ ጊዜ የገበያ ዋጋ',
    AppLanguage.oromo => 'Gatii dhihoo midhaan adda addaa gabaa irratti',
    AppLanguage.english => 'Latest commodity prices across major Ethiopian trading hubs.',
  };

  String get cropCalendarSubtitle => switch (language) {
    AppLanguage.amharic => 'ወቅታዊ የግብርና ተግባራት እና ማሳሰቢያዎች',
    AppLanguage.oromo => 'Hojiiwwan qonnaa fi yaadachiisa yeroo',
    AppLanguage.english => 'Seasonal agronomic schedule & stage-by-stage task reminders.',
  };

  String get publishedAdvisories => switch (language) {
    AppLanguage.amharic => 'የተረጋገጡ የግብርና ምክሮች',
    AppLanguage.oromo => 'Gorsa Qonnaa Mirkanaa’e',
    AppLanguage.english => 'Published Advisories',
  };

  String get registeredCrops => switch (language) {
    AppLanguage.amharic => 'የተመዘገቡ ሰብሎች',
    AppLanguage.oromo => 'Midhaan Galmaa’an',
    AppLanguage.english => 'Registered Crops',
  };

  String get voiceAssistant => switch (language) {
    AppLanguage.amharic => 'የድምፅ ረዳት (IVR)',
    AppLanguage.oromo => 'Tajaajila Sagalee (IVR)',
    AppLanguage.english => 'Voice Menu (IVR)',
  };

  String get voiceAssistantDesc => switch (language) {
    AppLanguage.amharic => 'የስልክ ጥሪ በማስመሰል ምክሮችን በድምፅ ያዳምጡ',
    AppLanguage.oromo => 'Sagaleen gorsa qonnaa dhaggeeffadhaa',
    AppLanguage.english => 'Simulate the automated phone voice menu for audio guidance.',
  };

  String get accessibilitySettings => switch (language) {
    AppLanguage.amharic => 'ተደራሽነት እና ድምፅ',
    AppLanguage.oromo => 'Dhaqqabummaa fi Sagalee',
    AppLanguage.english => 'Accessibility & Voice',
  };

  // ── Market Terminology ─────────────────────────────────────────────────────
  String get commodity => switch (language) {
    AppLanguage.amharic => 'የሰብል አይነት',
    AppLanguage.oromo => 'Gosa Midhaanii',
    AppLanguage.english => 'Commodity',
  };

  String get price => switch (language) {
    AppLanguage.amharic => 'ዋጋ',
    AppLanguage.oromo => 'Gatii',
    AppLanguage.english => 'Price',
  };

  String get perKg => switch (language) {
    AppLanguage.amharic => 'በኪሎ ግራም',
    AppLanguage.oromo => 'Kiiloodhaan',
    AppLanguage.english => 'per kg',
  };

  String get perQuintal => switch (language) {
    AppLanguage.amharic => 'በኩንታል',
    AppLanguage.oromo => 'Kuntaaliin',
    AppLanguage.english => 'per quintal',
  };

  String get observationDate => switch (language) {
    AppLanguage.amharic => 'የተመዘገበበት ቀን',
    AppLanguage.oromo => 'Guyyaa Galmaa’e',
    AppLanguage.english => 'Observation Date',
  };

  String get dataSource => switch (language) {
    AppLanguage.amharic => 'የመረጃ ምንጭ',
    AppLanguage.oromo => 'Madda Ragaa',
    AppLanguage.english => 'Data Source',
  };

  String get verifiedStatus => switch (language) {
    AppLanguage.amharic => 'የተረጋገጠ',
    AppLanguage.oromo => 'Mirkanaa’eera',
    AppLanguage.english => 'Verified Today',
  };

  String get sampleDataNotice => switch (language) {
    AppLanguage.amharic => 'ማሳሰቢያ፡ ይህ የገበያ መረጃ ለሙከራና ለማሳያ የቀረበ ነው',
    AppLanguage.oromo => 'Hubachiisa: Ragaan gabaa kun fakkeenyaaf kan dhiyaatedha',
    AppLanguage.english => 'Sample / Demo Market Data for Simulation',
  };

  // ── Crop Calendar & Seasons ────────────────────────────────────────────────
  String get seasonMeher => switch (language) {
    AppLanguage.amharic => 'መኸር (ዋናው የዝናብ ወቅት)',
    AppLanguage.oromo => 'Ganna (Bara Meher)',
    AppLanguage.english => 'Meher (Main Season)',
  };

  String get seasonBelg => switch (language) {
    AppLanguage.amharic => 'በልግ (አጭር የዝናብ ወቅት)',
    AppLanguage.oromo => 'Arfaasaa (Bara Belg)',
    AppLanguage.english => 'Belg (Short Rains)',
  };

  String get seasonBega => switch (language) {
    AppLanguage.amharic => 'በጋ (የመስኖ ወቅት)',
    AppLanguage.oromo => 'Bona (Jallisii)',
    AppLanguage.english => 'Bega (Irrigated/Dry)',
  };

  String get recommendedTask => switch (language) {
    AppLanguage.amharic => 'የሚመከር የግብርና ተግባር',
    AppLanguage.oromo => 'Hojii Qonnaa Gorfamu',
    AppLanguage.english => 'Recommended Task',
  };

  String get stageLandPrep => switch (language) {
    AppLanguage.amharic => 'የማሳ ዝግጅት',
    AppLanguage.oromo => 'Qophii Lafa Qonnaa',
    AppLanguage.english => 'Land Preparation',
  };

  String get stageSowing => switch (language) {
    AppLanguage.amharic => 'ዘር መዝራት',
    AppLanguage.oromo => 'Dallaa / Facaasaa',
    AppLanguage.english => 'Sowing / Planting',
  };

  String get stageWeeding => switch (language) {
    AppLanguage.amharic => 'አረም ማረም እና ማዳበሪያ',
    AppLanguage.oromo => 'Aramaa fi Xaa’oo',
    AppLanguage.english => 'Weeding & Fertilizing',
  };

  String get stagePestControl => switch (language) {
    AppLanguage.amharic => 'የተባይና በሽታ መከላከያ',
    AppLanguage.oromo => 'Ittisa Ilbiisotaa fi Dhukkubaa',
    AppLanguage.english => 'Pest & Disease Control',
  };

  String get stageHarvesting => switch (language) {
    AppLanguage.amharic => 'አዝመራ መሰብሰብ',
    AppLanguage.oromo => 'Haamuu fi Galfannaa',
    AppLanguage.english => 'Harvesting & Post-Harvest',
  };

  // ── Offline Library ────────────────────────────────────────────────────────
  String get savedOffline => switch (language) {
    AppLanguage.amharic => 'ያለ ኢንተርኔት ተቀምጧል',
    AppLanguage.oromo => 'Toora alatti kuufameera',
    AppLanguage.english => 'Saved Offline',
  };

  String get saveForOffline => switch (language) {
    AppLanguage.amharic => 'ያለ ኢንተርኔት አስቀምጥ',
    AppLanguage.oromo => 'Toora alatti kuusi',
    AppLanguage.english => 'Save for Offline',
  };

  String get removeFromOffline => switch (language) {
    AppLanguage.amharic => 'ከማከማቻ አውጣ',
    AppLanguage.oromo => 'Kuusaa keessaa baasi',
    AppLanguage.english => 'Remove Offline Copy',
  };

  String get staleContentNotice => switch (language) {
    AppLanguage.amharic => 'ይህ መረጃ ከተቀመጠ ቆይቷል፤ ኢንተርኔት ሲያገኙ ያድሱ',
    AppLanguage.oromo => 'Odeeffannoon kun erga kuufamee tureera, haaromsi',
    AppLanguage.english => 'Saved > 14 days ago. Reconnect to refresh.',
  };

  // ── Case Workflow Statuses ─────────────────────────────────────────────────
  String caseStatusLabel(String status) {
    final s = status.toUpperCase().replaceAll('-', '_');
    switch (s) {
      case 'OPEN':
        return switch (language) {
          AppLanguage.amharic => 'አዲስ የቀረበ',
          AppLanguage.oromo => 'Banamaa',
          AppLanguage.english => 'Open',
        };
      case 'ASSIGNED':
        return switch (language) {
          AppLanguage.amharic => 'ለባለሙያ ተመድቧል',
          AppLanguage.oromo => 'Ramadameera',
          AppLanguage.english => 'Assigned',
        };
      case 'IN_PROGRESS':
        return switch (language) {
          AppLanguage.amharic => 'በመታየት ላይ',
          AppLanguage.oromo => 'Adeemsa Irra Jira',
          AppLanguage.english => 'In Progress',
        };
      case 'WAITING_FOR_INFORMATION':
        return switch (language) {
          AppLanguage.amharic => 'ተጨማሪ መረጃ በመጠባበቅ ላይ',
          AppLanguage.oromo => 'Odeeffannoo Dabalataa Eegaa Jira',
          AppLanguage.english => 'Waiting for Information',
        };
      case 'ESCALATED':
        return switch (language) {
          AppLanguage.amharic => 'ለከፍተኛ ባለሙያ ተላልፏል',
          AppLanguage.oromo => 'Gara Ogeessa Ol’aanaatti Darbe',
          AppLanguage.english => 'Escalated',
        };
      case 'RESOLVED':
        return switch (language) {
          AppLanguage.amharic => 'መልስ ተሰጥቷል / ተፈትቷል',
          AppLanguage.oromo => 'Furmaata Argatee Jira',
          AppLanguage.english => 'Resolved',
        };
      case 'CLOSED':
        return switch (language) {
          AppLanguage.amharic => 'ተዘግቷል',
          AppLanguage.oromo => 'Cufameera',
          AppLanguage.english => 'Closed',
        };
      default:
        return status;
    }
  }

  // ── Common Actions & Form Validations ──────────────────────────────────────
  String get submit => switch (language) {
    AppLanguage.amharic => 'ላክ',
    AppLanguage.oromo => 'Ergi',
    AppLanguage.english => 'Submit',
  };

  String get cancel => switch (language) {
    AppLanguage.amharic => 'ሰርዝ',
    AppLanguage.oromo => 'Dhiisi',
    AppLanguage.english => 'Cancel',
  };

  String get retry => switch (language) {
    AppLanguage.amharic => 'እንደገና ሞክር',
    AppLanguage.oromo => 'Irra Deebi’ii Yaali',
    AppLanguage.english => 'Retry',
  };

  String get refresh => switch (language) {
    AppLanguage.amharic => 'አድስ',
    AppLanguage.oromo => 'Haaromsi',
    AppLanguage.english => 'Refresh',
  };

  String get search => switch (language) {
    AppLanguage.amharic => 'ፈልግ...',
    AppLanguage.oromo => 'Barbaadi...',
    AppLanguage.english => 'Search...',
  };

  String get viewAll => switch (language) {
    AppLanguage.amharic => 'ሁሉንም ይመልከቱ',
    AppLanguage.oromo => 'Hundumaa Ilaali',
    AppLanguage.english => 'View all',
  };

  String get readAloud => switch (language) {
    AppLanguage.amharic => 'በድምፅ አድምጥ',
    AppLanguage.oromo => 'Sagaleen Dhaggeeffadhu',
    AppLanguage.english => 'Read Aloud (Audio)',
  };

  String get fieldRequired => switch (language) {
    AppLanguage.amharic => 'ይህ ቦታ መሞላት አለበት',
    AppLanguage.oromo => 'Bakki kun guutamuu qaba',
    AppLanguage.english => 'This field is required',
  };
}
