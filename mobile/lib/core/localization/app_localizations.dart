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

  String get farmer => switch (language) {
    AppLanguage.amharic => 'አርሶ አደር',
    AppLanguage.oromo => 'Qonnaan bulaa',
    AppLanguage.english => 'Farmer',
  };

  String get location => switch (language) {
    AppLanguage.amharic => 'ቦታ',
    AppLanguage.oromo => 'Bakka',
    AppLanguage.english => 'Location',
  };

  String get close => switch (language) {
    AppLanguage.amharic => 'ዝጋ',
    AppLanguage.oromo => 'Cufi',
    AppLanguage.english => 'Close',
  };

  String get noCases => switch (language) {
    AppLanguage.amharic => 'ለማየት ምንም ጉዳይ የለም።',
    AppLanguage.oromo => 'Dhimmootni ilaalamu hin jiran.',
    AppLanguage.english => 'There are no cases or inquiries to show.',
  };

  String get casesDescription => switch (language) {
    AppLanguage.amharic => 'የአርሶ አደሮችን ጉዳዮችና ጥያቄዎች ይመልከቱ።',
    AppLanguage.oromo => 'Dhimmootaa fi gaaffilee qonnaan bultootaa ilaali.',
    AppLanguage.english => 'Review farmer cases and inquiries.',
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
    AppLanguage.english =>
      'Submit field photos and get expert guidance for your crops.',
  };

  String get marketPricesTitle => switch (language) {
    AppLanguage.amharic => 'የአካባቢ ገበያ ዋጋዎች',
    AppLanguage.oromo => 'Gatiiwwan Gabaa Naannoo',
    AppLanguage.english => 'Local Market Prices',
  };

  String get marketPricesSubtitle => switch (language) {
    AppLanguage.amharic => 'የጤፍ፣ ስንዴ፣ በቆሎና ሌሎች ሰብሎች የቅርብ ጊዜ የገበያ ዋጋ',
    AppLanguage.oromo => 'Gatii dhihoo midhaan adda addaa gabaa irratti',
    AppLanguage.english =>
      'Latest commodity prices across major Ethiopian trading hubs.',
  };

  String get cropCalendarSubtitle => switch (language) {
    AppLanguage.amharic => 'ወቅታዊ የግብርና ተግባራት እና ማሳሰቢያዎች',
    AppLanguage.oromo => 'Hojiiwwan qonnaa fi yaadachiisa yeroo',
    AppLanguage.english =>
      'Seasonal agronomic schedule & stage-by-stage task reminders.',
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
    AppLanguage.english =>
      'Simulate the automated phone voice menu for audio guidance.',
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
    AppLanguage.oromo =>
      'Hubachiisa: Ragaan gabaa kun fakkeenyaaf kan dhiyaatedha',
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

  String get dashboard => switch (language) {
    AppLanguage.amharic => 'ዳሽቦርድ',
    AppLanguage.oromo => 'Daashboordii',
    AppLanguage.english => 'Dashboard',
  };

  String get approvals => switch (language) {
    AppLanguage.amharic => 'ማጽደቂያዎች',
    AppLanguage.oromo => 'Mirkaneessawwan',
    AppLanguage.english => 'Approvals',
  };

  String get users => switch (language) {
    AppLanguage.amharic => 'ተጠቃሚዎች',
    AppLanguage.oromo => 'Fayyadamtoota',
    AppLanguage.english => 'Users',
  };

  String get auditLogs => switch (language) {
    AppLanguage.amharic => 'የኦዲት መዝገቦች',
    AppLanguage.oromo => 'Galmee Odiitii',
    AppLanguage.english => 'Audit Logs',
  };

  String get settings => switch (language) {
    AppLanguage.amharic => 'ቅንብሮች',
    AppLanguage.oromo => 'Qindaa’inoota',
    AppLanguage.english => 'Settings',
  };

  String get systemOverview => switch (language) {
    AppLanguage.amharic => 'የስርዓት አጠቃላይ እይታ',
    AppLanguage.oromo => 'Cuunfaa Sirnaa',
    AppLanguage.english => 'System Overview',
  };

  String get platformActivitySubtitle => switch (language) {
    AppLanguage.amharic => 'የመድረኩ እንቅስቃሴና የጤና ሁኔታ።',
    AppLanguage.oromo => 'Sochii fi haala fayyaa waltajjichaa.',
    AppLanguage.english => 'Platform-wide activity and health metrics.',
  };

  String get keyMetrics => switch (language) {
    AppLanguage.amharic => 'ዋና መለኪያዎች',
    AppLanguage.oromo => 'Safartuuwwan Ijoo',
    AppLanguage.english => 'Key Metrics',
  };

  String get totalFarmers => switch (language) {
    AppLanguage.amharic => 'ጠቅላላ አርሶ አደሮች',
    AppLanguage.oromo => 'Qonnaan bultoota waliigalaa',
    AppLanguage.english => 'Total Farmers',
  };

  String get extensionWorkers => switch (language) {
    AppLanguage.amharic => 'የማሳ ሰራተኞች',
    AppLanguage.oromo => 'Hojjettoota Eksteenshinii',
    AppLanguage.english => 'Extension Workers',
  };

  String get agronomyExperts => switch (language) {
    AppLanguage.amharic => 'የአግሮኖሚ ባለሙያዎች',
    AppLanguage.oromo => 'Ogeessota Agronomii',
    AppLanguage.english => 'Agronomy Experts',
  };

  String get publishedBulletins => switch (language) {
    AppLanguage.amharic => 'የታተሙ ማስታወቂያዎች',
    AppLanguage.oromo => 'Beeksisawwan maxxanfaman',
    AppLanguage.english => 'Published Bulletins',
  };

  String get messagesSent => switch (language) {
    AppLanguage.amharic => 'የተላኩ መልዕክቶች',
    AppLanguage.oromo => 'Ergaawwan ergaman',
    AppLanguage.english => 'Messages Sent',
  };

  String get deliveryRate => switch (language) {
    AppLanguage.amharic => 'የደረሱ መልዕክቶች መጠን',
    AppLanguage.oromo => 'Sadarkaa geejjibaa',
    AppLanguage.english => 'Delivery Rate',
  };

  String get farmersByRegion => switch (language) {
    AppLanguage.amharic => 'አርሶ አደሮች በክልል',
    AppLanguage.oromo => 'Qonnaan bultoota naannoodhaan',
    AppLanguage.english => 'Farmers by Region',
  };

  String get contentReviewStatus => switch (language) {
    AppLanguage.amharic => 'የይዘት ግምገማ ሁኔታ',
    AppLanguage.oromo => 'Haala gamaaggama qabiyyee',
    AppLanguage.english => 'Content Review Status',
  };

  String get published => switch (language) {
    AppLanguage.amharic => 'የታተመ',
    AppLanguage.oromo => 'Maxxanfame',
    AppLanguage.english => 'Published',
  };

  String get inReview => switch (language) {
    AppLanguage.amharic => 'በግምገማ ላይ',
    AppLanguage.oromo => 'Gamaaggama irra',
    AppLanguage.english => 'In Review',
  };

  String get drafts => switch (language) {
    AppLanguage.amharic => 'ረቂቆች',
    AppLanguage.oromo => 'Waraqaalee yaadaa',
    AppLanguage.english => 'Drafts',
  };

  String get systemActivityLog => switch (language) {
    AppLanguage.amharic => 'የስርዓት እንቅስቃሴ መዝገብ',
    AppLanguage.oromo => 'Galmee sochii sirnaa',
    AppLanguage.english => 'System Activity Log',
  };

  String get adminSettings => switch (language) {
    AppLanguage.amharic => 'የአስተዳዳሪ ቅንብሮች',
    AppLanguage.oromo => 'Qindaa’inoota Bulchaa',
    AppLanguage.english => 'Admin Settings',
  };

  String get generalConfiguration => switch (language) {
    AppLanguage.amharic => 'አጠቃላይ ውቅር',
    AppLanguage.oromo => 'Qindaa’ina waliigalaa',
    AppLanguage.english => 'General Configuration',
  };

  String get platformInstanceName => switch (language) {
    AppLanguage.amharic => 'የመድረኩ ስም',
    AppLanguage.oromo => 'Maqaa Waltajjii',
    AppLanguage.english => 'Platform Instance Name',
  };

  String get defaultLanguage => switch (language) {
    AppLanguage.amharic => 'ነባሪ ቋንቋ',
    AppLanguage.oromo => 'Afaan durtii',
    AppLanguage.english => 'Default Language',
  };

  String get supportContacts => switch (language) {
    AppLanguage.amharic => 'የድጋፍ አድራሻዎች',
    AppLanguage.oromo => 'Quunnamtii Deeggarsaa',
    AppLanguage.english => 'Support & Contacts',
  };

  String get supportEscalationEmail => switch (language) {
    AppLanguage.amharic => 'የድጋፍ ማሳወቂያ ኢሜይል',
    AppLanguage.oromo => 'Imeelii deeggarsa ol dabarsuuf',
    AppLanguage.english => 'Support Escalation Email Address',
  };

  String get platformBehavior => switch (language) {
    AppLanguage.amharic => 'የመድረክ አሠራር',
    AppLanguage.oromo => 'Hojii Waltajjii',
    AppLanguage.english => 'Platform Behavior',
  };

  String get smsBroadcastAlerts => switch (language) {
    AppLanguage.amharic => 'የኤስኤምኤስ ማስታወቂያዎች',
    AppLanguage.oromo => 'Akeekkachiisa SMS',
    AppLanguage.english => 'SMS Broadcast Alerts',
  };

  String get smsBroadcastDescription => switch (language) {
    AppLanguage.amharic => 'ለአርሶ አደሮች የምክር ማስታወቂያዎችን በኤስኤምኤስ ይላኩ።',
    AppLanguage.oromo => 'Beeksisa gorsaa qonnaan bultootaaf SMS’n ergi.',
    AppLanguage.english => 'Send advisory broadcasts to farmers over SMS.',
  };

  String get maintenanceMode => switch (language) {
    AppLanguage.amharic => 'የጥገና ሁነታ',
    AppLanguage.oromo => 'Haala suphaa',
    AppLanguage.english => 'Maintenance Mode',
  };

  String get maintenanceDescription => switch (language) {
    AppLanguage.amharic => 'ለሁሉም ሚናዎች አዲስ መግቢያዎችን ለጊዜው ያግዱ።',
    AppLanguage.oromo =>
      'Seensa haaraa yeroo muraasaaf gosoota hundaaf ugguri.',
    AppLanguage.english => 'Temporarily block new sign-ins for all roles.',
  };

  String get autoEscalationThreshold => switch (language) {
    AppLanguage.amharic => 'የራስ-ሰር ማሳወቂያ ገደብ',
    AppLanguage.oromo => 'Daangaa ol-dabarsuu ofumaan',
    AppLanguage.english => 'Auto-Escalation Threshold',
  };

  String get autoEscalationDescription => switch (language) {
    AppLanguage.amharic => 'ያልተፈቱ የመስክ ጉዳዮች ከዚህ ሰዓት በኋላ ለከፍተኛ ባለሙያ ይላካሉ።',
    AppLanguage.oromo =>
      'Dhimmootni dirree hin furamne yeroo kana booda ogeessa olaanaatti darbu.',
    AppLanguage.english =>
      'Unresolved field cases auto-escalate to a senior expert after this many hours.',
  };

  String get saveConfiguration => switch (language) {
    AppLanguage.amharic => 'ውቅሩን አስቀምጥ',
    AppLanguage.oromo => 'Qindaa’ina olkaa’i',
    AppLanguage.english => 'Save Configuration',
  };

  String get logoutFromSystem => switch (language) {
    AppLanguage.amharic => 'ከስርዓቱ ውጣ',
    AppLanguage.oromo => 'Sirna keessaa ba’i',
    AppLanguage.english => 'Logout from System',
  };

  String get settingsSaved => switch (language) {
    AppLanguage.amharic => 'ቅንብሮች በተሳካ ሁኔታ ተቀምጠዋል።',
    AppLanguage.oromo => 'Qindaa’inoonni milkaa’inaan olkaa’amaniiru.',
    AppLanguage.english => 'Settings saved successfully!',
  };

  String get systemAuditLogs => switch (language) {
    AppLanguage.amharic => 'የስርዓት ኦዲት መዝገቦች',
    AppLanguage.oromo => 'Galmee Odiitii Sirnaa',
    AppLanguage.english => 'System Audit Logs',
  };

  String get dateRange => switch (language) {
    AppLanguage.amharic => 'የቀን ክልል',
    AppLanguage.oromo => 'Daangaa guyyaa',
    AppLanguage.english => 'Date Range',
  };

  String get last7Days => switch (language) {
    AppLanguage.amharic => 'ያለፉት 7 ቀናት',
    AppLanguage.oromo => 'Guyyoota 7 darban',
    AppLanguage.english => 'Last 7 Days',
  };

  String get last30Days => switch (language) {
    AppLanguage.amharic => 'ያለፉት 30 ቀናት',
    AppLanguage.oromo => 'Guyyoota 30 darban',
    AppLanguage.english => 'Last 30 Days',
  };

  String get allTime => switch (language) {
    AppLanguage.amharic => 'ሁሉም ጊዜ',
    AppLanguage.oromo => 'Yeroo hunda',
    AppLanguage.english => 'All Time',
  };

  String get role => switch (language) {
    AppLanguage.amharic => 'ሚና',
    AppLanguage.oromo => 'Gahee',
    AppLanguage.english => 'Role',
  };

  String get allRoles => switch (language) {
    AppLanguage.amharic => 'ሁሉም ሚናዎች',
    AppLanguage.oromo => 'Gahee hunda',
    AppLanguage.english => 'All Roles',
  };

  String get adminRole => switch (language) {
    AppLanguage.amharic => 'አስተዳዳሪ',
    AppLanguage.oromo => 'Bulchaa',
    AppLanguage.english => 'Admin',
  };

  String get expertRole => switch (language) {
    AppLanguage.amharic => 'ባለሙያ',
    AppLanguage.oromo => 'Ogeessa',
    AppLanguage.english => 'Expert',
  };

  String get extensionWorkerRole => switch (language) {
    AppLanguage.amharic => 'የማሳ ሰራተኛ',
    AppLanguage.oromo => 'Hojjetaa Eksteenshinii',
    AppLanguage.english => 'Extension Worker',
  };

  String get noAuditEntries => switch (language) {
    AppLanguage.amharic => 'ለዚህ ማጣሪያ የኦዲት መዝገብ የለም።',
    AppLanguage.oromo => 'Galmeen odiitii filannoo kanaaf hin jiru.',
    AppLanguage.english => 'No audit entries match your filters.',
  };

  String get target => switch (language) {
    AppLanguage.amharic => 'ዒላማ',
    AppLanguage.oromo => 'Kaayyoo',
    AppLanguage.english => 'Target',
  };

  String get noRecentActivity => switch (language) {
    AppLanguage.amharic => 'የቅርብ ጊዜ እንቅስቃሴ የለም።',
    AppLanguage.oromo => 'Sochiin dhiheenyaa hin jiru.',
    AppLanguage.english => 'No recent activity yet.',
  };

  String get approved => switch (language) {
    AppLanguage.amharic => 'ጸድቋል',
    AppLanguage.oromo => 'Mirkanaa’eera',
    AppLanguage.english => 'Approved',
  };

  String get rejected => switch (language) {
    AppLanguage.amharic => 'ውድቅ ተደርጓል',
    AppLanguage.oromo => 'Kufameera',
    AppLanguage.english => 'Rejected',
  };

  String get newLabel => switch (language) {
    AppLanguage.amharic => 'አዲስ',
    AppLanguage.oromo => 'Haaraa',
    AppLanguage.english => 'New',
  };

  String get systemLabel => switch (language) {
    AppLanguage.amharic => 'ስርዓት',
    AppLanguage.oromo => 'Sirna',
    AppLanguage.english => 'System',
  };

  String get changeTheme => switch (language) {
    AppLanguage.amharic => 'ገጽታ ቀይር',
    AppLanguage.oromo => 'Bifa jijjiiri',
    AppLanguage.english => 'Change theme',
  };

  static const Map<String, (String, String)> _screenTranslations = {
    'Language Settings': ('የቋንቋ ቅንብሮች', 'Qindaa’inoota Afaanii'),
    'Expert Agricultural Advisory System': (
      'የግብርና ባለሙያ ምክር ስርዓት',
      'Sirna Gorsa Qonnaa Ogeessaa',
    ),
    'Switch to light mode': ('ወደ ብርሃን ሁነታ ቀይር', 'Gara haala ifaatti jijjiiri'),
    'Switch to dark mode': (
      'ወደ ጨለማ ሁነታ ቀይር',
      'Gara haala dukkanaa’aatti jijjiiri',
    ),
    'Status: ': ('ሁኔታ: ', 'Haala: '),
    'Active': ('ንቁ', 'Hojii irra'),
    'Active — Approved': ('ንቁ — ጸድቋል', 'Hojii irra — Mirkanaa’eera'),
    'Disabled': ('ተሰናክሏል', 'Hojii irraa dhaabbate'),
    'Pending': ('በመጠባበቅ ላይ', 'Eegaa jira'),
    'Approve': ('አጽድቅ', 'Mirkaneessi'),
    'Reject': ('ውድቅ አድርግ', 'Kufi'),
    'Edit': ('አርትዕ', 'Gulaali'),
    'View': ('ይመልከቱ', 'Ilaali'),
    'Back': ('ተመለስ', 'Deebi’i'),
    'Open': ('ክፍት', 'Banaa'),
    'Account Settings': ('የመለያ ቅንብሮች', 'Qindaa’inoota Herregaa'),
    'Settings & Preferences': ('ቅንብሮች እና ምርጫዎች', 'Qindaa’inootaa fi Filannoo'),
    'Create Account': ('መለያ ፍጠር', 'Herrega Uumi'),
    'Choose your role': ('ሚናዎን ይምረጡ', 'Gahee keessan filadhaa'),
    'Please check your internet connection and try again.': (
      'እባክዎ የኢንተርኔት ግንኙነትዎን ያረጋግጡና እንደገና ይሞክሩ።',
      'Maaloo walqunnamtii interneetii keessanii mirkaneessaa, irra deebi’aatii yaalaa.',
    ),
    'Please select an assigned farmer.': (
      'እባክዎ የተመደበ አርሶ አደር ይምረጡ።',
      'Maaloo qonnaan bulaa ramadame filadhaa.',
    ),
    'Please select both Woreda and Kebele.': (
      'እባክዎ ወረዳና ቀበሌ ሁለቱንም ይምረጡ።',
      'Maaloo aanaa fi ganda lamaan filadhaa.',
    ),
    'Please confirm your password': (
      'እባክዎ የይለፍ ቃልዎን ያረጋግጡ',
      'Maaloo jecha darbii keessan mirkaneessaa',
    ),
    'Passwords do not match': (
      'የይለፍ ቃሎቹ አይዛመዱም',
      'Jechoonni darbii wal hin siman',
    ),
    'Full name is required.': (
      'ሙሉ ስም ያስፈልጋል።',
      'Maqaan guutuun barbaachisaadha.',
    ),
    'Enter at least 3 characters.': (
      'ቢያንስ 3 ቁምፊዎችን ያስገቡ።',
      'Yoo xiqqaate arfii 3 galchaa.',
    ),
    'Phone number is required.': (
      'የስልክ ቁጥር ያስፈልጋል።',
      'Lakkoofsi bilbilaa barbaachisaadha.',
    ),
    'Use 09+8 digits or +251+9 digits': (
      '09 ከ8 አሃዞች ወይም +251 ከ9 አሃዞች ጋር ይጠቀሙ',
      '09 fi dijiitii 8 yookaan +251 fi dijiitii 9 fayyadamaa',
    ),
    'Enter name': ('ስም ያስገቡ', 'Maqaa galchaa'),
    'Enter phone number': ('የስልክ ቁጥር ያስገቡ', 'Lakkoofsa bilbilaa galchaa'),
    'Enter email': ('ኢሜይል ያስገቡ', 'Imeelii galchaa'),
    'Crop name is required.': (
      'የሰብል ስም ያስፈልጋል።',
      'Maqaan midhaanii barbaachisaadha.',
    ),
    'Planting date is required.': (
      'የመዝራት ቀን ያስፈልጋል።',
      'Guyyaan facaasa barbaachisaadha.',
    ),
    'Use MM/DD/YYYY format.': (
      'የወር/ቀን/ዓመት ቅርጸት ይጠቀሙ።',
      'Bifa MM/DD/YYYY fayyadamaa.',
    ),
    'Planted area is required.': (
      'የተዘራበት ስፋት ያስፈልጋል።',
      'Bal’inni facaafame barbaachisaadha.',
    ),
    'Enter a valid number.': ('ትክክለኛ ቁጥር ያስገቡ።', 'Lakkoofsa sirrii galchaa.'),
    'Area must be greater than 0.': (
      'ስፋቱ ከ0 መብለጥ አለበት።',
      'Bal’inni 0 caaluu qaba.',
    ),
    'Title must be at least 3 characters.': (
      'ርዕሱ ቢያንስ 3 ቁምፊዎች መሆን አለበት።',
      'Mata-dureen yoo xiqqaate arfii 3 ta’uu qaba.',
    ),
    'Description must be at least 10 characters.': (
      'መግለጫው ቢያንስ 10 ቁምፊዎች መሆን አለበት።',
      'Ibsi yoo xiqqaate arfii 10 ta’uu qaba.',
    ),
    'Diagnosis is required.': ('ምርመራ ያስፈልጋል።', 'Qorannoon barbaachisaadha.'),
    'Recommendation is required.': ('ምክር ያስፈልጋል።', 'Gorsi barbaachisaadha.'),
    'Please enter a subject': ('እባክዎ ርዕስ ያስገቡ', 'Maaloo mata-duree galchaa'),
    'Please enter a description': ('እባክዎ መግለጫ ያስገቡ', 'Maaloo ibsa galchaa'),
    'Crop Name *': ('የሰብል ስም *', 'Maqaa Midhaanii *'),
    'Phone Number *': ('የስልክ ቁጥር *', 'Lakkoofsa Bilbilaa *'),
    'Gender': ('ጾታ', 'Saala'),
    'Region *': ('ክልል *', 'Naannoo *'),
    'Zone *': ('ዞን *', 'Godina *'),
    'Farm Location': ('የእርሻ ቦታ', 'Bakka Qonnaa'),
    'Farm Details': ('የእርሻ ዝርዝሮች', 'Bal’ina Qonnaa'),
    'Employee Details': ('የሰራተኛ ዝርዝሮች', 'Bal’ina Hojjetaa'),
    'Enter Custom Region *': ('ብጁ ክልል ያስገቡ *', 'Naannoo addaa galchaa *'),
    'Enter Custom Zone *': ('ብጁ ዞን ያስገቡ *', 'Godina addaa galchaa *'),
    'Enter Custom Woreda *': ('ብጁ ወረዳ ያስገቡ *', 'Aanaa addaa galchaa *'),
    'Enter Custom Kebele *': ('ብጁ ቀበሌ ያስገቡ *', 'Ganda addaa galchaa *'),
    'Type custom region name': (
      'የብጁ ክልል ስም ያስገቡ',
      'Maqaa naannoo addaa galchaa',
    ),
    'Type custom zone name': ('የብጁ ዞን ስም ያስገቡ', 'Maqaa godina addaa galchaa'),
    'Type custom woreda name': ('የብጁ ወረዳ ስም ያስገቡ', 'Maqaa aanaa addaa galchaa'),
    'Type custom kebele name or number': (
      'የብጁ ቀበሌ ስም ወይም ቁጥር ያስገቡ',
      'Maqaa yookaan lakkoofsa ganda addaa galchaa',
    ),
    'Ethiopian Administrative Location': (
      'የኢትዮጵያ አስተዳደራዊ አካባቢ',
      'Bakka Bulchiinsaa Itoophiyaa',
    ),
    'Verify Registration Details': (
      'የምዝገባ ዝርዝሮችን ያረጋግጡ',
      'Bal’ina Galmee Mirkaneessaa',
    ),
    'Select Crops to register': (
      'ለመመዝገብ ሰብሎችን ይምረጡ',
      'Midhaan galmeessuuf filadhaa',
    ),
    'Crops Selected': ('የተመረጡ ሰብሎች', 'Midhaan Filataman'),
    'No farmers match your search or filters.': (
      'ከፍለጋዎ ወይም ማጣሪያዎችዎ ጋር የሚዛመድ አርሶ አደር የለም።',
      'Qonnaan bulaan barbaacha yookaan filannoo keessan waliin walsimu hin jiru.',
    ),
    'No attachments yet — photos help experts diagnose faster.': (
      'እስካሁን ምንም አባሪ የለም — ፎቶዎች ባለሙያዎች በፍጥነት እንዲመረምሩ ይረዳሉ።',
      'Hanga ammaatti maxxansi hin jiru — suuraan ogeeyyiin saffisaan akka qoratan gargaara.',
    ),
    'No images yet — tap Add to attach field photos.': (
      'እስካሁን ምስል የለም — የማሳ ፎቶዎችን ለማያያዝ ጨምርን ይጫኑ።',
      'Hanga ammaatti suuraan hin jiru — suuraa dirree maxxansuuf Dabaluu tuqaa.',
    ),
    'Allowed: JPG, PNG, PDF (Max 10MB per file)': (
      'የሚፈቀዱ፦ JPG፣ PNG፣ PDF (በእያንዳንዱ ፋይል ከፍተኛ 10MB)',
      'Kan hayyamaman: JPG, PNG, PDF (faayila tokkoof hanga 10MB)',
    ),
    'No Saved Advisories': ('የተቀመጠ ምክር የለም', 'Gorsi kuufame hin jiru'),
    'You are Offline': ('ከመስመር ውጭ ነዎት', 'Toora alaa jirtu'),
    'You can save published advisories for offline reading when you have an internet connection. Only expert-approved published content can be saved.': (
      'የኢንተርኔት ግንኙነት ሲኖርዎት የታተሙ ምክሮችን ከመስመር ውጭ ለማንበብ ማስቀመጥ ይችላሉ። በባለሙያ የጸደቀ የታተመ ይዘት ብቻ ሊቀመጥ ይችላል።',
      'Yeroo interneetii qabdaniitti gorsawwan maxxanfaman toora alatti dubbisuuf kuusuu dandeessu. Qabiyyeen maxxanfame ogeessaan mirkanaa’e qofa kuufamuu danda’a.',
    ),
    'Reading Saved Offline Copy': (
      'ከመስመር ውጭ የተቀመጠ ቅጂ በማንበብ ላይ',
      'Garagalcha toora alatti kuufame dubbisaa jira',
    ),
    'Stale (>14d)': ('ያረጀ (>14 ቀናት)', 'Yeroo darbe (>14g)'),
    'Seasonal planting & weeding schedule': (
      'ወቅታዊ የመዝራትና አረም የማረም መርሃ ግብር',
      'Sagantaa facaasaafi aramaa yeroo',
    ),
    'Browse commodity prices (Kg/Quintal)': (
      'የሰብል ዋጋዎችን አስስ (ኪ.ግ/ኩንታል)',
      'Gatii midhaanii sakatta’i (Kg/Kuntaala)',
    ),
    'Submit field photos & get advice': (
      'የማሳ ፎቶዎችን ላክና ምክር አግኝ',
      'Suuraalee dirree ergiitii gorsa argadhaa',
    ),
    'Read saved advice with no internet': (
      'የተቀመጠ ምክርን ኢንተርኔት ሳይኖር አንብብ',
      'Gorsa kuufame interneetii malee dubbisi',
    ),
    'Designed for easy readability in outdoor daylight and voice-assisted interaction for rural farmers.': (
      'በውጭ የቀን ብርሃን በቀላሉ እንዲነበብና ለገጠር አርሶ አደሮች በድምፅ እንዲረዳ ተዘጋጅቷል።',
      'Guyyaa ifa alaa keessatti salphaatti dubbisuufi qonnaan bultoota baadiyyaaf sagaleedhaan gargaaruuf qophaa’e.',
    ),
    'Display & Contrast Settings': (
      'የማሳያ እና ንፅፅር ቅንብሮች',
      'Qindaa’ina Agarsiisaa fi Faallaa',
    ),
    'Audio Readout Simulation': ('የድምፅ ንባብ አስመሳይ', 'Simulaata Dubbisa Sagalee'),
    'Simulating Spoken Audio': (
      'የተነገረ ድምፅን በማስመሰል ላይ',
      'Sagalee dubbifame fakkeessaa jira',
    ),
    'Large Quick-Action Buttons': (
      'ትላልቅ ፈጣን እርምጃ አዝራሮች',
      'Qabduu Tarkaanfii Saffisaa Guguddoo',
    ),
    'Voice & High-Contrast Center': (
      'የድምፅ እና ከፍተኛ ንፅፅር ማዕከል',
      'Giddugala Sagalee fi Faallaa Ol’aanaa',
    ),
    'Interactive Phone Keypad': (
      'ተግባቢ የስልክ ቁልፍ ሰሌዳ',
      'Furtuu Bilbilaa Wal-qunnamtii',
    ),
    'Use the "New Question" tab to submit your crop inquiry.': (
      'የሰብል ጥያቄዎን ለማስገባት "አዲስ ጥያቄ" ትርን ይጠቀሙ።',
      'Gaaffii midhaanii galchuuf caancala "Gaaffii Haaraa" fayyadamaa.',
    ),
    'Your inquiry is currently being evaluated by the assigned extension agent. You will receive an update here and via SMS.': (
      'ጥያቄዎ በተመደበው የግብርና ባለሙያ እየተገመገመ ነው። ዝማኔውን እዚህና በSMS ያገኛሉ።',
      'Gaaffiin keessan ogeessa eksteenshinii ramadameen gamaaggamaa jira. Haaromsa asii fi SMS’n argattu.',
    ),
    'Note: Newly registered Extension Workers and Experts must wait for Admin approval before logging in.': (
      'ማስታወሻ፦ አዲስ የተመዘገቡ የግብርና ሠራተኞችና ባለሙያዎች ከመግባታቸው በፊት የአስተዳዳሪ ማጽደቅን መጠበቅ አለባቸው።',
      'Hubachiisa: Hojjettoonni eksteenshinii fi ogeeyyiin haaraa galmaa’an seenuun dura mirkaneessa bulchaa eeguu qabu.',
    ),
    'Precision agriculture, grounded in data.': (
      'በመረጃ ላይ የተመሰረተ ትክክለኛ ግብርና።',
      'Qonna sirrii kan odeeffannoo irratti hundaa’e.',
    ),
    'Record technical field observations, crop health findings, and pest/disease issues.': (
      'የማሳ ምልከታዎችን፣ የሰብል ጤና ግኝቶችን እና የተባይ/በሽታ ጉዳዮችን ይመዝግቡ።',
      'Daawwannaa dirree, argannoo fayyaa midhaanii fi dhimma ilbiisotaa/dhukkubaa galmeessi.',
    ),
    'Log details for the current growing season to track field performance.': (
      'የማሳ አፈጻጸምን ለመከታተል ዝርዝር የአሁኑን የእድገት ወቅት ይመዝግቡ።',
      'Raawwii dirree hordofuuf bal’ina yeroo guddinaa ammaa galmeessi.',
    ),
    'Issue Description': ('የችግሩ መግለጫ', 'Ibsa Rakkoo'),
    'Expert Response Panel': ('የባለሙያ ምላሽ ፓነል', 'Paanaalii Deebii Ogeessaa'),
    'Last synced': ('ለመጨረሻ ጊዜ የተመሳሰለ', 'Yeroo dhumaaf walsimsiifame'),
    'Monthly Approvals Trend': (
      'ወርሃዊ የማጽደቅ አዝማሚያ',
      'Adeemsa Mirkaneessa Ji’aa',
    ),
    'Volume by Crop Category': ('መጠን በምርት ምድብ', 'Hamma Ramaddii Midhaaniin'),
    'Recent Metrics': ('የቅርብ ጊዜ መለኪያዎች', 'Safartuuwwan Dhiheenyaa'),
    'Reviewed and approved by an agricultural expert.': (
      'በግብርና ባለሙያ ተገምግሞ ጸድቋል።',
      'Ogeessa qonnaatiin gamaaggamamee mirkanaa’eera.',
    ),
    'Submitted for expert review.': (
      'ለባለሙያ ግምገማ ቀርቧል።',
      'Gamaaggama ogeessaaf dhihaateera.',
    ),
    'Security settings are not available in this mock build yet.': (
      'የደህንነት ቅንብሮች በዚህ ሙከራዊ ስሪት ገና አይገኙም።',
      'Qindaa’inni nageenyaa ijaarsa yaalii kana keessatti hanga ammaatti hin jiru.',
    ),
    'This will remove all locally saved advisories. You will need an internet connection to download them again.': (
      'ይህ በአካባቢው የተቀመጡ ምክሮችን በሙሉ ያስወግዳል። እንደገና ለማውረድ የኢንተርኔት ግንኙነት ያስፈልጋል።',
      'Kun gorsawwan naannoo kuufaman hunda haqa. Irra deebi’anii buusuuf interneetii barbaachisa.',
    ),
    'Could not launch phone dialer': (
      'የስልክ መደወያውን መክፈት አልተቻለም',
      'Bilbila bilbiluu banuun hin danda’amne',
    ),
    'This crop is already registered.': (
      'ይህ ሰብል አስቀድሞ ተመዝግቧል።',
      'Midhaan kun duraan galmaa’eera.',
    ),
    'Try Again': ('እንደገና ሞክር', 'Irra Deebi’ii Yaali'),
    'Region: Amhara': ('ክልል፦ አማራ', 'Naannoo: Amaaraa'),
    'Submitted by: Extension Worker Abebe': (
      'ያስገባው፦ የግብርና ሠራተኛ አበበ',
      'Kan dhiheesse: Hojjetaa Eksteenshinii Abebe',
    ),
    'Reviewed Case: Suspected Blight': (
      'የተገመገመ ጉዳይ፦ የቅጠል በሽታ ጥርጣሬ',
      'Dhimma Gamaaggamame: Dhukkuba baala shakkame',
    ),
    'Approved field report: Soil Moisture': (
      'የጸደቀ የማሳ ሪፖርት፦ የአፈር እርጥበት',
      'Gabaasa dirree mirkanaa’e: Jiidhina biyyee',
    ),
    'Maize Stalk Borer Outbreak': (
      'የበቆሎ ግንድ አሰልቺ ተባይ ወረርሽኝ',
      'Dhohinsa raammoo marga boqqolloo',
    ),
    'Farmer registered and assigned, but ': (
      'አርሶ አደሩ ተመዝግቦ ተመድቧል፣ ግን ',
      'Qonnaan bulaan galmaa’ee ramadameera, garuu ',
    ),
    ' crop assignment(s) failed.': (
      ' የሰብል ምደባ(ዎች) አልተሳኩም።',
      ' ramaddii midhaanii hin milkoofne.',
    ),
    'Note: The farmer’s default password will be their ': (
      'ማስታወሻ፦ የአርሶ አደሩ ነባሪ የይለፍ ቃል ',
      'Hubachiisa: Jechi darbii durtii qonnaan bulaa ',
    ),
    'Active · Approved': ('ንቁ · ጸድቋል', 'Hojii irra · Mirkanaa’eera'),
    'Here is your operational overview for today.': (
      'የዛሬ የሥራ አጠቃላይ እይታዎ ይህ ነው።',
      'Cuunfaan hojii keessan har’aa kunooti.',
    ),
    'e.g., East Shewa, South Gondar': (
      'ምሳሌ፦ ምስራቅ ሸዋ፣ ደቡብ ጎንደር',
      'Fakkeenya: Shawaa Bahaa, Gondar Kibbaa',
    ),
    'e.g., Oromia, Amhara, Sidama': (
      'ምሳሌ፦ ኦሮሚያ፣ አማራ፣ ሲዳማ',
      'Fakkeenya: Oromiyaa, Amaaraa, Sidaamaa',
    ),
    'e.g., Ada’a, Fogera, Hawassa Zuria': (
      'ምሳሌ፦ አዳአ፣ ፎገራ፣ ሐዋሳ ዙሪያ',
      'Fakkeenya: Ada’aa, Fogeraa, Hawaasa Zuriyaa',
    ),
    'e.g., 01, Ude, Tis Abay': (
      'ምሳሌ፦ 01፣ ኡዴ፣ ጢስ አባይ',
      'Fakkeenya: 01, Ude, Tis Abay',
    ),
    'e.g., Coffee, Teff, Potato': (
      'ምሳሌ፦ ቡና፣ ጤፍ፣ ድንች',
      'Fakkeenya: Buna, Xaafii, Dinnicha',
    ),
    'e.g., Yellow spots spreading on maize leaves': (
      'ምሳሌ፦ በቆሎ ቅጠሎች ላይ የሚስፋፉ ቢጫ ነጠብጣቦች',
      'Fakkeenya: Tuqaa keelloo baala boqqolloo irratti babal’achaa jiran',
    ),
    'Please enter phone or email': (
      'እባክዎ ስልክ ወይም ኢሜይል ያስገቡ',
      'Maaloo bilbila yookaan imeelii galchaa',
    ),
    'Use a valid email or 10/13 digit Ethiopian phone number': (
      'ትክክለኛ ኢሜይል ወይም 10/13 አሃዝ ያለው የኢትዮጵያ ስልክ ቁጥር ይጠቀሙ',
      'Imeelii sirrii yookaan lakkoofsa bilbila Itoophiyaa dijiitii 10/13 qabu fayyadamaa',
    ),
    'Password must be at least 8 characters': (
      'የይለፍ ቃሉ ቢያንስ 8 ፊደላት መሆን አለበት',
      'Jechi darbii yoo xiqqaate arfii 8 qabaachuu qaba',
    ),
    "Don't have an account? Register": (
      'መለያ የለዎትም? ይመዝገቡ',
      'Herrega hin qabduu? Galmaa’aa',
    ),
    'Select Language / ቋንቋ ይምረጡ': ('ቋንቋ ይምረጡ', 'Afaan filadhaa'),
    'Choose your preferred language for advisories and dashboards.': (
      'ለምክሮችና ዳሽቦርዶች የሚመርጡትን ቋንቋ ይምረጡ።',
      'Gorsaafi daashboordii keessaniif afaan filattan filadhaa.',
    ),
    'Confirm & Continue': ('አረጋግጥና ቀጥል', 'Mirkaneessi itti fufi'),
    'Expert Registration': ('የባለሙያ ምዝገባ', 'Galmee Ogeessaa'),
    'Join as Expert': ('እንደ ባለሙያ ይመዝገቡ', 'Ogeessa ta’uun galmaa’aa'),
    'Provide credentials to validate agricultural content.': (
      'የግብርና ይዘትን ለማረጋገጥ ማስረጃዎችን ያቅርቡ።',
      'Qabiyyee qonnaa mirkaneessuuf ragaa dhiheessaa.',
    ),
    'Full Name': ('ሙሉ ስም', 'Maqaa Guutuu'),
    'Phone Number': ('ስልክ ቁጥር', 'Lakkoofsa Bilbilaa'),
    'Email Address': ('የኢሜይል አድራሻ', 'Teessoo Imeelii'),
    'Area of Expertise': ('የሙያ መስክ', 'Dirree Ogeessummaa'),
    'Operating Region': ('የሥራ ክልል', 'Naannoo Hojii'),
    'Password': ('የይለፍ ቃል', 'Jecha Darbii'),
    'Confirm Password': ('የይለፍ ቃሉን ያረጋግጡ', 'Jecha Darbii Mirkaneessi'),
    'Phone or Email': ('ስልክ ወይም ኢሜይል', 'Bilbila yookaan Imeelii'),
    'Login': ('ግባ', 'Seeni'),
    'Remember me': ('አስታውሰኝ', 'Na yaadadhu'),
    'Register': ('ይመዝገቡ', 'Galmaa’i'),
    'Register as Expert': ('እንደ ባለሙያ ይመዝገቡ', 'Ogeessa ta’uun galmaa’aa'),
    'Already have an account? Login': (
      'መለያ አለዎት? ይግቡ',
      'Herrega qabduu? Seenaa',
    ),
    'Return to Login': ('ወደ መግቢያ ተመለስ', 'Gara seensaatti deebi’i'),
    'Back to Login': ('ወደ መግቢያ ተመለስ', 'Gara seensaatti deebi’i'),
    'Contact Support': ('ድጋፍን ያግኙ', 'Deeggarsa quunnamaa'),
    'Invalid credentials or unregistered account': (
      'የመግቢያ መረጃው ልክ አይደለም ወይም መለያው አልተመዘገበም',
      'Ragaan seensaa sirrii miti yookaan herregni hin galmoofne',
    ),
    'Account Under Review': (
      'መለያው በግምገማ ላይ ነው',
      'Herregni gamaaggama irra jira',
    ),
    'Your expert credentials are currently being verified by the administrator.':
        (
          'የባለሙያ ማስረጃዎችዎ በአስተዳዳሪው እየተረጋገጡ ነው።',
          'Ragaan ogeessummaa keessanii bulchaan amma mirkaneeffamaa jira.',
        ),
    'You will receive an email notification once your profile is approved. Thank you for your patience.': (
      'መገለጫዎ ሲጸድቅ በኢሜይል ያሳውቁዎታል። ስለትዕግስትዎ እናመሰግናለን።',
      'Yeroo eenyummeessi keessan mirkanaa’u imeeliidhaan isin beeksifna. Obsaa keessaniif galatoomaa.',
    ),
    'Registration Submitted!': ('ምዝገባው ተልኳል!', 'Galmeen ergameera!'),
    'Your account registration as an "': ('እንደ ', 'Akka '),
    '" has been received successfully.': (
      '" የመለያ ምዝገባዎ በተሳካ ሁኔታ ተቀብሏል።',
      '" galmeen herregaa keessanii milkaa’inaan fudhatameera.',
    ),
    'Extension Worker': ('የግብርና ሠራተኛ', 'Hojjetaa Eksteenshinii'),
    'Agricultural Expert': ('የግብርና ባለሙያ', 'Ogeessa Qonnaa'),
    'Take photo': ('ፎቶ አንሳ', 'Suuraa ka’i'),
    'Choose from gallery': ('ከፎቶ ማዕከል ምረጥ', 'Kuusaa suuraa keessaa filadhu'),
    'Browse files': ('ፋይሎችን አስስ', 'Faayilota sakatta’i'),
    'Cancel': ('ሰርዝ', 'Dhiisi'),
    'Close': ('ዝጋ', 'Cufi'),
    'Save': ('አስቀምጥ', 'Olkaa’i'),
    'Add': ('ጨምር', 'Dabaluu'),
    'OK': ('እሺ', 'Tole'),
    'Retry': ('እንደገና ሞክር', 'Irra deebi’ii yaali'),
    'Try again': ('እንደገና ሞክር', 'Irra deebi’ii yaali'),
    'Refresh': ('አድስ', 'Haaromsi'),
    'Search alerts...': ('ማስጠንቀቂያዎችን ፈልግ...', 'Akeekkachiisota barbaadi...'),
    'Search farmers...': ('አርሶ አደሮችን ፈልግ...', 'Qonnaan bultoota barbaadi...'),
    'Search title, author, or crop...': (
      'ርዕስ፣ ደራሲ ወይም ሰብል ፈልግ...',
      'Mata-duree, barreessaa yookaan midhaan barbaadi...',
    ),
    'Search users by name or phone...': (
      'ተጠቃሚዎችን በስም ወይም ስልክ ፈልግ...',
      'Fayyadamtoota maqaa yookaan bilbilaan barbaadi...',
    ),
    'Search': ('ፈልግ', 'Barbaadi'),
    'Role': ('ሚና', 'Gahee'),
    'Status': ('ሁኔታ', 'Haala'),
    'Date Range': ('የቀን ክልል', 'Daangaa Guyyaa'),
    'Alert Type': ('የማስጠንቀቂያ አይነት', 'Gosa Akeekkachiisaa'),
    'Region': ('ክልል', 'Naannoo'),
    'Crop': ('ሰብል', 'Midhaan'),
    'Crop Type *': ('የሰብል አይነት *', 'Gosa Midhaanii *'),
    'Planting Date * (MM/DD/YYYY)': (
      'የመዝራት ቀን * (ወር/ቀን/ዓመት)',
      'Guyyaa facaasa * (MM/DD/YYYY)',
    ),
    'Planted Area (Hectares) *': (
      'የተዘራበት ስፋት (ሄክታር) *',
      'Bal’ina facaafame (heektaara) *',
    ),
    'Current Growth Stage *': ('አሁናዊ የእድገት ደረጃ *', 'Sadarkaa guddinaa ammaa *'),
    'Description': ('መግለጫ', 'Ibsa'),
    'Assigned Region': ('የተመደበበት ክልል', 'Naannoo Ramadame'),
    'Employee ID': ('የሰራተኛ መለያ', 'Eenyummeessa Hojjetaa'),
    'Edit Profile Information': (
      'የመገለጫ መረጃን አርትዕ',
      'Odeeffannoo Eenyummeessaa Gulaali',
    ),
    'Security & Password': ('ደህንነት እና የይለፍ ቃል', 'Nageenyaa fi Jecha Darbii'),
    'App Language': ('የመተግበሪያ ቋንቋ', 'Afaan Appii'),
    'Logout': ('ውጣ', 'Ba’i'),
    'Profile information updated.': (
      'የመገለጫ መረጃ ታድሷል።',
      'Odeeffannoon eenyummeessaa haaromfameera.',
    ),
    'Register New Farmer': (
      'አዲስ አርሶ አደር መዝግብ',
      'Qonnaan bulaa haaraa galmeessi',
    ),
    'Farmer Directory': ('የአርሶ አደር ዝርዝር', 'Tarree Qonnaan Bultootaa'),
    'Crop Records': ('የሰብል መዝገቦች', 'Galmee Midhaanii'),
    'Register New Crop': ('አዲስ ሰብል መዝግብ', 'Midhaan haaraa galmeessi'),
    'Field Observations': ('የማሳ ምልከታዎች', 'Daawwannaa Dirree'),
    'Submit New Content': ('አዲስ ይዘት አስገባ', 'Qabiyyee haaraa dhiheessi'),
    'Recent Activity': ('የቅርብ ጊዜ እንቅስቃሴ', 'Sochii Dhiheenyaa'),
    'No recent activity yet.': (
      'እስካሁን የቅርብ ጊዜ እንቅስቃሴ የለም።',
      'Hanga ammaatti sochiin dhiheenyaa hin jiru.',
    ),
    'Alerts & Notifications': (
      'ማስጠንቀቂያዎች እና ማሳወቂያዎች',
      'Akeekkachiisa fi Beeksisa',
    ),
    'No alerts match your search or filters.': (
      'ከፍለጋዎ ወይም ማጣሪያዎችዎ ጋር የሚዛመድ ማስጠንቀቂያ የለም።',
      'Akeekkachiisni barbaacha yookaan filannoo keessan waliin walsimu hin jiru.',
    ),
    'No alerts found for this category.': (
      'በዚህ ምድብ ምንም ማስጠንቀቂያ አልተገኘም።',
      'Ramaddii kana keessatti akeekkachiisni hin argamne.',
    ),
    'Show All Alerts': (
      'ሁሉንም ማስጠንቀቂያዎች አሳይ',
      'Akeekkachiisota hunda agarsiisi',
    ),
    'All alerts marked as read.': (
      'ሁሉም ማስጠንቀቂያዎች እንደተነበቡ ተመልክተዋል።',
      'Akeekkachiisotni hundi akka dubbifamaniitti mallatteeffamaniiru.',
    ),
    'Mark all as read': (
      'ሁሉንም እንደተነበቡ ምልክት አድርግ',
      'Hunda akka dubbifamaniitti mallatteessi',
    ),
    'No market price records found for this filter.': (
      'በዚህ ማጣሪያ የገበያ ዋጋ መዝገብ አልተገኘም።',
      'Filannoo kanaan galmeen gatii gabaa hin argamne.',
    ),
    'No market price data available.': (
      'የገበያ ዋጋ መረጃ የለም።',
      'Odeeffannoon gatii gabaa hin jiru.',
    ),
    'No upcoming crop tasks scheduled.': (
      'በቅርቡ የታቀደ የሰብል ሥራ የለም።',
      'Hojii midhaanii dhiheenyatti karoorfame hin jiru.',
    ),
    'Have a crop problem? Ask your extension agent.': (
      'የሰብል ችግር አለ? የግብርና ባለሙያን ይጠይቁ።',
      'Rakkoo midhaanii qabduu? Ogeessa eksteenshinii gaafadhaa.',
    ),
    'Ask Now': ('አሁን ጠይቅ', 'Amma gaafadhu'),
    'No published advisories currently available.': (
      'አሁን የታተመ የግብርና ምክር የለም።',
      'Amma gorsi qonnaa maxxanfame hin jiru.',
    ),
    'Manage in Profile': ('በመገለጫ ውስጥ አስተዳድር', 'Eenyummeessa keessatti bulchi'),
    'Dark Mode / High Contrast': (
      'ጨለማ ሁነታ / ከፍተኛ ንፅፅር',
      'Haala Dukkanaa’aa / Faallaa Ol’aanaa',
    ),
    'Improves visibility in bright sunlight': (
      'በደማቅ ፀሐይ ውስጥ ታይነትን ያሻሽላል',
      'Ifa aduu cimaa keessatti mul’achuu fooyyessa',
    ),
    'Accessibility & Voice': ('ተደራሽነት እና ድምፅ', 'Dhaqqabummaa fi Sagalee'),
    'Change Language': ('ቋንቋ ቀይር', 'Afaan Jijjiiri'),
    'IVR Voice Simulator': ('የIVR ድምፅ አስመሳይ', 'Simulaata Sagalee IVR'),
    'SMS Simulator': ('የSMS አስመሳይ', 'Simulaata SMS'),
    'Interactive automated phone keypad menu': (
      'በስልክ ቁልፍ ሰሌዳ የሚሰራ ራስ-ሰር ምናሌ',
      'Baafata bilbilaa ofumaan hojjetu kan furtuu tuqaatiin fayyadamu',
    ),
    'Reset IVR Session': (
      'የIVR ክፍለ ጊዜን ዳግም አስጀምር',
      'Yeroo IVR irra deebi’ii jalqabi',
    ),
    'Recipient Phone Number': ('የተቀባይ ስልክ ቁጥር', 'Lakkoofsa Bilbila Fudhataa'),
    'SMS Message Content': ('የSMS መልዕክት ይዘት', 'Qabiyyee Ergaa SMS'),
    'Send SMS': ('SMS ላክ', 'SMS Ergi'),
    'SMS dispatched via backend simulator.': (
      'SMS በኋላ ስርዓት አስመሳይ ተልኳል።',
      'SMS simulaata duubbee tiin ergameera.',
    ),
    'SMS failed: ': ('SMS አልተሳካም: ', 'SMS hin milkoofne: '),
    'Simulate SMS Dispatch': ('የSMS መላክን አስመስል', 'Ergaa SMS fakkeessi'),
    'Sends a real request to POST /api/messaging/sms': (
      'እውነተኛ ጥያቄን ወደ POST /api/messaging/sms ይልካል',
      'Gaaffii dhugaa gara POST /api/messaging/sms erga',
    ),
    'Dispatch History': ('የመላኪያ ታሪክ', 'Seenaa Ergaa'),
    'Just now': ('አሁን', 'Amma'),
    'Earlier': ('ቀደም ሲል', 'Dura'),
    'Advisory saved for offline access!': (
      'ምክሩ ከመስመር ውጭ ለመጠቀም ተቀምጧል!',
      'Gorsi interneetii malee fayyadamuuf olkaa’ameera!',
    ),
    'Removed advisory from offline storage.': (
      'ምክሩ ከመስመር ውጭ ማከማቻ ተወግዷል።',
      'Gorsi kuusaa toora alaa keessaa haqameera.',
    ),
    'Only expert-approved PUBLISHED advisories can be cached offline.': (
      'በባለሙያ የጸደቁ የታተሙ ምክሮች ብቻ ከመስመር ውጭ ሊቀመጡ ይችላሉ።',
      'Gorsawwan ogeessaan mirkanaa’anii maxxanfaman qofa toora alatti kuufamuu danda’u.',
    ),
    'Advisory not found.': ('ምክሩ አልተገኘም።', 'Gorsi hin argamne.'),
    'No published advisories yet.': (
      'እስካሁን የታተመ ምክር የለም።',
      'Hanga ammaatti gorsi maxxanfame hin jiru.',
    ),
    'Agricultural Bulletins': ('የግብርና ማስታወቂያዎች', 'Beeksisa Qonnaa'),
    'Clear Offline Storage?': (
      'ከመስመር ውጭ ማከማቻ ይጥረግ?',
      'Kuusaa toora alaa haquu?',
    ),
    'Clear All': ('ሁሉንም አጽዳ', 'Hunda qulqulleessi'),
    'Clear offline storage': (
      'ከመስመር ውጭ ማከማቻ አጽዳ',
      'Kuusaa toora alaa qulqulleessi',
    ),
    'Browse Published Advisories': (
      'የታተሙ ምክሮችን አስስ',
      'Gorsawwan maxxanfaman sakatta’i',
    ),
    'Read Full Body': ('ሙሉ ይዘቱን አንብብ', 'Qabiyyee guutuu dubbisi'),
    'My Profile': ('የግል መገለጫዬ', 'Eenyummeessa Koo'),
    'Registered Farmer': ('የተመዘገበ አርሶ አደር', 'Qonnaan Bulaa Galmaa’e'),
    'Add Crop': ('ሰብል ጨምር', 'Midhaan dabaluu'),
    'Add Registered Crop': ('የተመዘገበ ሰብል ጨምር', 'Midhaan galmaa’e dabaluu'),
    'Crop Name': ('የሰብል ስም', 'Maqaa Midhaanii'),
    'Enable Alerts': ('ማስጠንቀቂያዎችን አንቃ', 'Akeekkachiisota hojii irra oolchi'),
    'Receive SMS warnings and urgent bulletins': (
      'የSMS ማስጠንቀቂያዎችንና አስቸኳይ ማስታወቂያዎችን ተቀበል',
      'Akeekkachiisa SMS fi beeksisa ariifachiisaa fudhadhu',
    ),
    'High contrast, large buttons & audio readouts': (
      'ከፍተኛ ንፅፅር፣ ትላልቅ አዝራሮች እና በድምፅ ማንበብ',
      'Faallaa ol’aanaa, qabduu guguddoo fi dubbisa sagalee',
    ),
    'Offline Saved Advisories': (
      'ከመስመር ውጭ የተቀመጡ ምክሮች',
      'Gorsawwan toora alatti kuufaman',
    ),
    'View and manage cached advisory bulletins': (
      'የተቀመጡ የምክር ማስታወቂያዎችን ይመልከቱና ያስተዳድሩ',
      'Beeksisa gorsaa kuufame ilaalaa fi bulchaa',
    ),
    'My Questions & Inquiries': (
      'ጥያቄዎቼ እና ምርመራዎቼ',
      'Gaaffilee fi Dhimmoota Koo',
    ),
    'Track extension worker case responses': (
      'የግብርና ሠራተኛ ምላሾችን ይከታተሉ',
      'Deebiiwwan hojjetaa eksteenshinii hordofi',
    ),
    'No submitted cases yet.': (
      'እስካሁን ጉዳይ አልቀረበም።',
      'Hanga ammaatti dhimma hin dhihaanne.',
    ),
    'Take photo of field/crop issue': (
      'የማሳ/ሰብል ችግር ፎቶ አንሳ',
      'Rakkoo dirree/midhaanii suuraa ka’i',
    ),
    'Choose photo from gallery': (
      'ፎቶን ከማዕከሉ ምረጥ',
      'Suuraa kuusaa keessaa filadhu',
    ),
    'Attach PDF or Document': (
      'PDF ወይም ሰነድ አያይዝ',
      'PDF yookaan sanada maxxansi',
    ),
    'Subject / Observed Problem *': (
      'ርዕስ / የታየው ችግር *',
      'Mata-duree / Rakkoo Mul’ate *',
    ),
    'Detailed Description *': ('ዝርዝር መግለጫ *', 'Ibsa Bal’aa *'),
    'Farm Location / Plot Name': (
      'የእርሻ ቦታ / የማሳ ስም',
      'Bakka Qonnaa / Maqaa Dirree',
    ),
    'Add File': ('ፋይል ጨምር', 'Faayila dabaluu'),
    'Submit Case to Extension Worker': (
      'ጉዳዩን ለግብርና ሠራተኛ ላክ',
      'Dhimma hojjetaa eksteenshiniif ergi',
    ),
    'Reset Filters': (
      'ማጣሪያዎችን ዳግም አስጀምር',
      'Filannoowwan irra deebi’ii jalqabi',
    ),
    'No crop calendar schedule found for this filter.': (
      'በዚህ ማጣሪያ የሰብል የቀን መቁጠሪያ አልተገኘም።',
      'Filannoo kanaan kalaandariin midhaanii hin argamne.',
    ),
    'Assigned Workflows': ('የተመደቡ የሥራ ሂደቶች', 'Adeemsa Hojii Ramadaman'),
    'Crop Recording': ('የሰብል መዝገብ', 'Galmee Midhaanii'),
    'Crop performance record logged!': (
      'የሰብል አፈጻጸም መዝገብ ተመዝግቧል!',
      'Galmeen raawwii midhaanii galmaa’eera!',
    ),
    'Crop registered successfully!': (
      'ሰብሉ በተሳካ ሁኔታ ተመዝግቧል!',
      'Midhaan milkaa’inaan galmaa’eera!',
    ),
    'Registration Failed': ('ምዝገባው አልተሳካም', 'Galmeen hin milkoofne'),
    'Manually register a new crop to the central database.': (
      'አዲስ ሰብልን በእጅ ወደ ማዕከላዊ ዳታቤዝ ይመዝግቡ።',
      'Midhaan haaraa galmee odeeffannoo giddugaleessaatti harkaan galmeessi.',
    ),
    'Record Field Observation': (
      'የማሳ ምልከታ መዝግብ',
      'Daawwannaa Dirree Galmeessi',
    ),
    'Farmer *': ('አርሶ አደር *', 'Qonnaan Bulaa *'),
    'Affected Crop': ('የተጎዳው ሰብል', 'Midhaan Miidhame'),
    'Observation Type *': ('የምልከታ አይነት *', 'Gosa Daawwannaa *'),
    'Severity Level *': ('የክብደት ደረጃ *', 'Sadarkaa Cimina Rakkoo *'),
    'Observation Title *': ('የምልከታ ርዕስ *', 'Mata-duree Daawwannaa *'),
    'Immediate Action Taken / Advice Given': (
      'የተወሰደ አፋጣኝ እርምጃ / የተሰጠ ምክር',
      'Tarkaanfii Battalaa Fudhatame / Gorsa Kenname',
    ),
    'Save Record': ('መዝገቡን አስቀምጥ', 'Galmee olkaa’i'),
    'Save & Escalate': ('አስቀምጥና አሳድግ', 'Olkaa’ii ol dabarsi'),
    'Farmer Information': ('የአርሶ አደር መረጃ', 'Odeeffannoo Qonnaan Bulaa'),
    'Farmer Management': ('የአርሶ አደር አስተዳደር', 'Bulchiinsa Qonnaan Bultootaa'),
    'Register Farmer': ('አርሶ አደር መዝግብ', 'Qonnaan bulaa galmeessi'),
    'Woreda *': ('ወረዳ *', 'Aanaa *'),
    'Kebele *': ('ቀበሌ *', 'Ganda *'),
    'Gender *': ('ጾታ *', 'Saala *'),
    'Farm Location details': ('የእርሻ ቦታ ዝርዝር', 'Bal’ina Bakka Qonnaa'),
    'No crops available. Please check your connection.': (
      'የሚገኝ ሰብል የለም። የኢንተርኔት ግንኙነትዎን ያረጋግጡ።',
      'Midhaan hin jiru. Walqunnamtii interneetii keessan mirkaneessaa.',
    ),
    'Review Advisory': ('ምክሩን ገምግም', 'Gorsa Gamaaggami'),
    'Reject Advisory': ('ምክሩን ውድቅ አድርግ', 'Gorsa Kufi'),
    'Reason for rejection *': ('ውድቅ የሚደረግበት ምክንያት *', 'Sababa kufaatii *'),
    'Provide a clear explanation...': (
      'ግልጽ ማብራሪያ ያቅርቡ...',
      'Ibsa ifa ta’e dhiheessaa...',
    ),
    'Content': ('ይዘት', 'Qabiyyee'),
    'Content Review': ('የይዘት ግምገማ', 'Gamaaggama Qabiyyee'),
    'Review Details': ('ዝርዝር ግምገማ', 'Bal’ina Gamaaggamaa'),
    'Review Comment (optional)': (
      'የግምገማ አስተያየት (አማራጭ)',
      'Yaada Gamaaggamaa (filannoo)',
    ),
    'Confirmed Diagnosis *': ('የተረጋገጠ ምርመራ *', 'Qorannoo Mirkanaa’e *'),
    'Primary Recommendation (Visible to Worker) *': (
      'ዋና ምክር (ለሠራተኛው የሚታይ) *',
      'Gorsa Ijoo (Hojjetaaf Mul’atu) *',
    ),
    'Internal Notes (Experts Only)': (
      'የውስጥ ማስታወሻዎች (ለባለሙያዎች ብቻ)',
      'Yaadannoo Keessaa (Ogeessota Qofaaf)',
    ),
    'Request More Info': ('ተጨማሪ መረጃ ጠይቅ', 'Odeeffannoo Dabalataa Gaafadhu'),
    'No advisories awaiting review.': (
      'ግምገማ የሚጠብቅ ምክር የለም።',
      'Gorsi gamaaggama eegaa jiru hin jiru.',
    ),
    'No drafts available.': ('ረቂቅ የለም።', 'Waraqaaleen yaadaa hin jiran.'),
    'View Details': ('ዝርዝሩን ይመልከቱ', 'Bal’ina Ilaali'),
    'Submitted by:': ('ያስገባው:', 'Kan dhiheesse:'),
    'New Advisory Draft': ('አዲስ የምክር ረቂቅ', 'Waraqaa yaadaa gorsaa haaraa'),
    'Advisory Title *': ('የምክር ርዕስ *', 'Mata-duree Gorsaa *'),
    'Content Body *': ('የይዘት አካል *', 'Qabiyyee Ijoo *'),
    'Language *': ('ቋንቋ *', 'Afaan *'),
    'Target Crop (optional)': ('የታለመ ሰብል (አማራጭ)', 'Midhaan Kaayyoo (filannoo)'),
    'All Crops / General': ('ሁሉም ሰብሎች / አጠቃላይ', 'Midhaan Hunda / Waliigalaa'),
    'Save as Draft': ('እንደ ረቂቅ አስቀምጥ', 'Akka waraqaa yaadaatti olkaa’i'),
    'Advisory saved as Draft': (
      'ምክሩ እንደ ረቂቅ ተቀምጧል',
      'Gorsi akka waraqaa yaadaatti olkaa’ameera',
    ),
    'Case': ('ጉዳይ', 'Dhimma'),
    'Dashboard': ('ዳሽቦርድ', 'Daashboordii'),
    'Review': ('ግምገማ', 'Gamaaggama'),
    'Cases': ('ጉዳዮች', 'Dhimmoota'),
    'Analytics': ('ትንታኔዎች', 'Xiinxala'),
    'Review Content': ('ይዘትን ገምግም', 'Qabiyyee Gamaaggami'),
    'Review Cases': ('ጉዳዮችን ገምግም', 'Dhimmoota Gamaaggami'),
    'Expert Analytics': ('የባለሙያ ትንታኔዎች', 'Xiinxala Ogeessaa'),
    'Unable to launch phone dialer': (
      'የስልክ መደወያውን መክፈት አልተቻለም',
      'Bilbila bilbiluu banuun hin danda’amne',
    ),
    'Expertise Areas': ('የሙያ መስኮች', 'Dirree Ogeessummaa'),
    'Phone': ('ስልክ', 'Bilbila'),
    'Extension Worker Profile': (
      'የግብርና ሠራተኛ መገለጫ',
      'Eenyummeessa Hojjetaa Eksteenshinii',
    ),
    'Case #': ('ጉዳይ #', 'Dhimma #'),
    'Today, 09:14 AM': ('ዛሬ፣ 09:14 ጥዋት', 'Har’a, 09:14 AM'),
    'Advisory Approved!': ('ምክሩ ጸድቋል!', 'Gorsi mirkanaa’eera!'),
    'Advisory Rejected.': ('ምክሩ ውድቅ ተደርጓል።', 'Gorsi kufameera.'),
    'Diagnosis Response Submitted successfully!': (
      'የምርመራ ምላሹ በተሳካ ሁኔታ ተልኳል!',
      'Deebiin qorannoo milkaa’inaan ergameera!',
    ),
    'Request sent to the extension worker for more field detail.': (
      'ተጨማሪ የማሳ ዝርዝር መረጃ ለግብርና ሠራተኛ ተልኳል።',
      'Bal’ina dirree dabalataa hojjetaa eksteenshiniif ergameera.',
    ),
    'Please complete the diagnosis and recommendation fields.': (
      'የምርመራና ምክር መስኮችን ይሙሉ።',
      'Dirree qorannoo fi gorsaa guutaa.',
    ),
    'No users match your search or filters.': (
      'ከፍለጋዎ ወይም ማጣሪያዎችዎ ጋር የሚዛመድ ተጠቃሚ የለም።',
      'Fayyadamaan barbaacha yookaan filannoo keessan waliin walsimu hin jiru.',
    ),
    'User Management': ('የተጠቃሚ አስተዳደር', 'Bulchiinsa Fayyadamtootaa'),
    'User Approvals': ('የተጠቃሚ ማጽደቂያዎች', 'Mirkaneessa Fayyadamtootaa'),
    'Pending Approvals Queue': (
      'የማጽደቅ በመጠባበቅ ላይ ያሉ ጥያቄዎች',
      'Tarree Mirkaneessa Eegaa Jiru',
    ),
    'All clean! No pending approvals.': (
      'ሁሉም ተጠናቋል! የሚጠብቅ ማጽደቂያ የለም።',
      'Hunduu qulqulluu! Mirkaneessi eegaa jiru hin jiru.',
    ),
    'Administrator accounts cannot be disabled here.': (
      'የአስተዳዳሪ መለያዎች እዚህ ሊታገዱ አይችሉም።',
      'Herregawwan bulchaa asitti hojii irraa dhaabamuu hin danda’an.',
    ),
    'AgriAdmin Portal': ('የአግሪ አስተዳዳሪ መድረክ', 'Waltajjii Bulchaa Agri'),
    'Agri-Insight Beacon': ('Agri-Insight Beacon', 'Agri-Insight Beacon'),
    'Alerts': ('ማስጠንቀቂያዎች', 'Akeekkachiisa'),
    'Directory': ('ማውጫ', 'Galmee'),
    'Information': ('መረጃ', 'Odeeffannoo'),
    'Market': ('ገበያ', 'Gabaa'),
    'Profile': ('መገለጫ', 'Eenyummeessa'),
    'Home': ('መነሻ', 'Fuula Duraa'),
    'Loading...': ('በመጫን ላይ...', 'Fe’amaa jira...'),
    'Something went wrong.': ('ችግር ተፈጥሯል።', 'Rakkoon uumameera.'),
    'No data available.': ('መረጃ የለም።', 'Odeeffannoon hin jiru.'),
    '+ Add Crop': ('+ ሰብል ጨምር', '+ Midhaan Dabaluu'),
    'Approved': ('ጸድቋል', 'Mirkanaa’eera'),
    'Before you can log in, an Administrator must review and approve your registration request. Please check back later or contact your system admin.': (
      'ከመግባትዎ በፊት አስተዳዳሪ የምዝገባ ጥያቄዎን ገምግሞ ማጽደቅ አለበት። እባክዎ ቆይተው ይመልከቱ ወይም የስርዓት አስተዳዳሪዎን ያነጋግሩ።',
      'Seenuu keessan dura bulchaan gaaffii galmee keessanii gamaaggamee mirkaneessuu qaba. Maaloo booda deebi’anii ilaalaa yookaan bulchaa sirnaa quunnamaa.',
    ),
    'Contact Expert': ('ባለሙያን ያነጋግሩ', 'Ogeessa Quunnamaa'),
    'Full Name *': ('ሙሉ ስም *', 'Maqaa Guutuu *'),
    'Registered Crops': ('የተመዘገቡ ሰብሎች', 'Midhaan Galmaa’an'),
    'Describe how long this has occurred, field conditions, and current soil moisture.':
        (
          'ይህ ችግር ለምን ያህል ጊዜ እንደቆየ፣ የማሳውን ሁኔታ እና የአሁኑን የአፈር እርጥበት ይግለጹ።',
          'Yeroo rakkoon kun ture, haala dirree fi jiidhina biyyee ammaa ibsaa.',
        ),
    'Invalid format: ': ('ትክክል ያልሆነ ቅርጸት: ', 'Bifa sirrii hin taane: '),
    'Allowed: JPG, PNG, PDF': (
      'የሚፈቀዱ፦ JPG፣ PNG፣ PDF',
      'Kan hayyamaman: JPG, PNG, PDF',
    ),
    'Question #': ('ጥያቄ #', 'Gaaffii #'),
    ' submitted to Extension Worker!': (
      ' ለግብርና ሠራተኛ ተልኳል!',
      ' hojjetaa eksteenshiniif ergameera!',
    ),
    'Submission error: ': ('የማስገባት ስህተት: ', 'Dogoggora dhiyeessuu: '),
    'Field Photos & Docs (': (
      'የማሳ ፎቶዎች እና ሰነዶች (',
      'Suuraalee fi Sanadoota Dirree (',
    ),
    'Simulation': ('አስመሳይ', 'Simulaata'),
    'e.g., Ada\'a, Fogera, Hawassa Zuria': (
      'ምሳሌ፦ አዳአ፣ ፎገራ፣ ሐዋሳ ዙሪያ',
      'Fakkeenya: Ada’aa, Fogeraa, Hawaasa Zuriyaa',
    ),
    'None selected': ('ምንም አልተመረጠም', 'Homtuu hin filatamne'),
    "Note: The farmer's default password will be their ": (
      'ማስታወሻ፦ የአርሶ አደሩ ነባሪ የይለፍ ቃል ',
      'Hubachiisa: Jechi darbii durtii qonnaan bulaa ',
    ),
    'phone number. They should change it after first login.': (
      'የስልክ ቁጥራቸው ይሆናል። ከመጀመሪያ መግቢያ በኋላ መቀየር አለባቸው።',
      'lakkoofsa bilbila isaanii ta’a. Seensa jalqabaa booda jijjiiruu qabu.',
    ),
    'No Data Found': ('መረጃ አልተገኘም', 'Odeeffannoon Hin Argamne'),
    'An Error Occurred': ('ስህተት ተፈጥሯል', 'Dogoggorri Uumameera'),
    'Show password': ('የይለፍ ቃል አሳይ', 'Jecha darbii agarsiisi'),
    'Hide password': ('የይለፍ ቃል ደብቅ', 'Jecha darbii dhoksi'),
    'Please select a Zone': ('እባክዎ ዞን ይምረጡ', 'Maaloo godina filadhaa'),
    'Please select a Woreda': ('እባክዎ ወረዳ ይምረጡ', 'Maaloo aanaa filadhaa'),
    'Please select a Kebele': ('እባክዎ ቀበሌ ይምረጡ', 'Maaloo ganda filadhaa'),
    'Please select a Region': ('እባክዎ ክልል ይምረጡ', 'Maaloo naannoo filadhaa'),
    'Region is required.': ('ክልል ያስፈልጋል።', 'Naannoon barbaachisaadha.'),
    'Zone is required.': ('ዞን ያስፈልጋል።', 'Godinni barbaachisaadha.'),
    'Woreda is required.': ('ወረዳ ያስፈልጋል።', 'Aanaan barbaachisaadha.'),
    'Kebele is required.': ('ቀበሌ ያስፈልጋል።', 'Gandi barbaachisaadha.'),
    'Use 09 plus 8 digits or +251 plus 9 digits': (
      '09 ከ8 አሃዞች ወይም +251 ከ9 አሃዞች ጋር ይጠቀሙ',
      '09 fi dijiitii 8 yookaan +251 fi dijiitii 9 fayyadamaa',
    ),
    'Title is required': ('ርዕስ ያስፈልጋል', 'Mata-dureen barbaachisaadha'),
    'Content body is required': (
      'የይዘት አካል ያስፈልጋል',
      'Qabiyyeen ijoo barbaachisaadha',
    ),
    'Error: ': ('ስህተት: ', 'Dogoggora: '),
    'Failed to save: ': ('ማስቀመጥ አልተሳካም: ', 'Olkaa’uun hin milkoofne: '),
    'Failed to register crop: ': (
      'ሰብሉን መመዝገብ አልተሳካም: ',
      'Midhaan galmeessuun hin milkoofne: ',
    ),
    'Failed to record observation: ': (
      'ምልከታውን መመዝገብ አልተሳካም: ',
      'Daawwannaa galmeessuun hin milkoofne: ',
    ),
    'Registration failed: ': ('ምዝገባው አልተሳካም: ', 'Galmeen hin milkoofne: '),
    'All': ('ሁሉም', 'Hunda'),
    'All Alerts': ('ሁሉም ማስጠንቀቂያዎች', 'Akeekkachiisa Hunda'),
    'Weather': ('የአየር ሁኔታ', 'Haala Qilleensaa'),
    'Pests & Diseases': ('ተባዮች እና በሽታዎች', 'Ilbiisotaa fi Dhukkuboota'),
    'Market Alerts': ('የገበያ ማስጠንቀቂያዎች', 'Akeekkachiisa Gabaa'),
    'Advisories': ('የግብርና ምክሮች', 'Gorsa Qonnaa'),
    'Rooted in Nature': ('በተፈጥሮ የተመሰረተ', 'Uumamaan Hundaa’e'),
    'Connect with certified agronomists and receive expert guidance matching your exact farm conditions.': (
      'ከተረጋገጡ የግብርና ባለሙያዎች ጋር ይገናኙና ከእርሻዎ ሁኔታ ጋር የሚስማማ የባለሙያ ምክር ያግኙ።',
      'Ogeessota qonnaa mirkanaa’an waliin wal qunnamaa; haala qonnaa keessanii waliin walsimu gorsa argadhaa.',
    ),
    'Instant Advisory Bulletins': (
      'ፈጣን የምክር ማስታወቂያዎች',
      'Beeksisa Gorsaa Battalaa',
    ),
    'Learn optimal crop sowing schedules, fertilization volumes, and sustainable watering methods.': (
      'ተስማሚ የሰብል መዝራት ጊዜያትን፣ የማዳበሪያ መጠኖችን እና ዘላቂ የውሃ አጠቃቀም ዘዴዎችን ይወቁ።',
      'Sagantaa facaasa midhaanii, hamma xaa’oo fi mala bishaan ittiin kennan baradhaa.',
    ),
    'Real-time Bulletins': ('በቅጽበት የሚተላለፉ ማስታወቂያዎች', 'Beeksisa Yeroo Dhugaa'),
    'Get immediate storm warnings, frost alerts, and pest outbreak reports directly to your phone.': (
      'የአውሎ ነፋስ ማስጠንቀቂያዎችን፣ የበረዶ ማሳሰቢያዎችን እና የተባይ ወረርሽኝ ሪፖርቶችን በቀጥታ በስልክዎ ያግኙ።',
      'Akeekkachiisa obomboleettii, qorraa fi gabaasa dhohinsa ilbiisotaa kallattiin bilbila keessan irratti argadhaa.',
    ),
    'Enter My Farm': ('ወደ እርሻዬ ግባ', 'Gara Qonna Koo Seeni'),
    'Review Bulletins Submissions': (
      'የማስታወቂያ ማስገቢያዎችን ገምግም',
      'Dhiyeessa Beeksisaa Gamaaggami',
    ),
    'Evaluate draft articles written in the field and technical advisories before they are dispatched.': (
      'በማሳ የተጻፉ ረቂቅ ጽሑፎችንና ቴክኒካዊ ምክሮችን ከመላካቸው በፊት ይገምግሙ።',
      'Barruulee dirree irratti barreeffaman fi gorsa teeknikaa erguun dura madaalaa.',
    ),
    'Diagnose Plant Pathology': (
      'የተክል በሽታዎችን መርምር',
      'Dhukkuba Biqiltuu Qoradhu',
    ),
    'Inspect high-resolution pest images submitted by field workers, diagnose leaves, and submit solutions.': (
      'በማሳ ሠራተኞች የተላኩ ጥራት ያላቸውን የተባይ ምስሎች ይመርምሩ፣ ቅጠሎችን ይመርምሩና መፍትሔ ያቅርቡ።',
      'Suuraa ilbiisotaa hojjettoota dirree irraa argame sakatta’aa, baala qoradhaa fi furmaata dhiheessaa.',
    ),
    'Track Regional Dynamics': (
      'የክልል ለውጦችን ተከታተል',
      'Jijjiirama Naannoo Hordofi',
    ),
    'Audit publication logs and advisory performance maps to optimize crop coverage strategies.': (
      'የሕትመት መዝገቦችንና የምክር አፈጻጸም ካርታዎችን በመመርመር የሰብል ሽፋን ስትራቴጂዎችን ያሻሽሉ።',
      'Galmee maxxansaa fi kaartaa raawwii gorsaa sakatta’uun tarsiimoo haguuggii midhaanii fooyyessaa.',
    ),
    'Open Expert Portal': ('የባለሙያ መድረክን ክፈት', 'Waltajjii Ogeessaa Bani'),
    'Field Registrations Stepper': (
      'የማሳ ምዝገባ ደረጃዎች',
      'Sadarkaalee Galmee Dirree',
    ),
    'Easily register local farmers directly in the field with a fully validated 4-step wizard.': (
      'በሙሉ የተረጋገጠ ባለ4 ደረጃ መመሪያ በማሳ ላይ የአካባቢ አርሶ አደሮችን በቀላሉ ይመዝግቡ።',
      'Qajeelfama sadarkaa 4 guutummaatti mirkanaa’e fayyadamuun qonnaan bultoota naannoo dirree irratti salphaatti galmeessaa.',
    ),
    'Record Crops Progress': (
      'የሰብሎችን እድገት መዝግብ',
      'Guddina Midhaanii Galmeessi',
    ),
    'Log sown crops, soil conditions, area measurements, and plant growth phases in your workspace.': (
      'የተዘሩ ሰብሎችን፣ የአፈር ሁኔታን፣ የመሬት ስፋትን እና የተክል የእድገት ደረጃዎችን በሥራ ቦታዎ ይመዝግቡ።',
      'Midhaan facaafame, haala biyyee, bal’ina lafaa fi sadarkaalee guddina biqiltuu galmee hojii keessan keessatti galmeessaa.',
    ),
    'Report Pest & Crop Diseases': (
      'የተባይና የሰብል በሽታዎችን ሪፖርት አድርግ',
      'Ilbiisotaa fi Dhukkuba Midhaanii Gabaasi',
    ),
    'Capture pictures of suspected crop diseases and escalate reports instantly to Experts for diagnosis.': (
      'የተጠረጠሩ የሰብል በሽታዎችን ፎቶ አንስተው ለምርመራ ሪፖርቶችን ወዲያውኑ ለባለሙያዎች ያስተላልፉ።',
      'Suuraa dhukkuba midhaanii shakkame ka’aa; gabaasa qorannoo ogeessaaf battalumatti dabarsaa.',
    ),
    'Launch Workspace': ('የሥራ ቦታን ክፈት', 'Bakka Hojii Bani'),
    'Skip': ('ዝለል', 'Darbii'),
    'Enter': ('ግባ', 'Seeni'),
    'Sign in to send an SMS.': (
      'SMS ለመላክ ወደ መለያዎ ይግቡ።',
      'SMS erguuf herrega keessan seenaa.',
    ),
    'Checking signed-in account...': (
      'የገቡበትን መለያ በማረጋገጥ ላይ...',
      'Herrega seentan mirkaneessaa jira...',
    ),
    'SMS queued by backend simulator.': (
      'SMS በኋላ ስርዓት አስመሳይ ውስጥ ተሰልፏል።',
      'SMS simulaata duubbee keessatti tarreeffameera.',
    ),
    'SMS simulation completed.': (
      'የSMS ማስመሰል ተጠናቋል።',
      'Simulaanni SMS xumurameera.',
    ),
    'SMS simulator reported a failure.': (
      'የSMS አስመሳይ ስህተት አሳውቋል።',
      'Simulaanni SMS dogoggora gabaaseera.',
    ),
    'Could not end the previous IVR session. Starting a new session.': (
      'ያለፈውን የIVR ክፍለ ጊዜ መጨረስ አልተቻለም። አዲስ ክፍለ ጊዜ በመጀመር ላይ።',
      'Yeroo IVR darbe xumuruu hin dandeenye. Yeroo haaraa jalqabaa jira.',
    ),
    'Last key pressed: ': (
      'የመጨረሻ ጊዜ የተጫነው ቁልፍ: ',
      'Furtuun dhuma irratti tuqame: ',
    ),
    'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.': (
      'ወደ Agri-Insight Beacon እንኳን በደህና መጡ። ቋንቋዎን ይምረጡ። ለእንግሊዝኛ 1፣ ለአማርኛ 2፣ ለአፋን ኦሮሞ 3 ይጫኑ።',
      'Baga gara Agri-Insight Beacon dhuftan. Afaan keessan filadhaa. Ingiliffaaf 1, Amaariffaaf 2, Afaan Oromoof 3 tuqaa.',
    ),
    'English selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.': (
      'እንግሊዝኛ ተመርጧል። ዋና ምናሌ፦ ለሰብል ምክሮች 1፣ ለአየር ሁኔታ ሪፖርቶች 2፣ ለማስጠንቀቂያ ቅንብሮች 3 ይጫኑ።',
      'Ingiliffi filatameera. Baafata Ijoo: Gorsa midhaaniif 1, gabaasa qilleensaaf 2, qindaa’ina akeekkachiisaaf 3 tuqaa.',
    ),
    'Amharic selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.': (
      'አማርኛ ተመርጧል። ዋና ምናሌ፦ ለሰብል ምክሮች 1፣ ለአየር ሁኔታ ሪፖርቶች 2፣ ለማስጠንቀቂያ ቅንብሮች 3 ይጫኑ።',
      'Afaan Amaaraa filatameera. Baafata Ijoo: Gorsa midhaaniif 1, gabaasa qilleensaaf 2, qindaa’ina akeekkachiisaaf 3 tuqaa.',
    ),
    'Oromo selected. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.': (
      'አፋን ኦሮሞ ተመርጧል። ዋና ምናሌ፦ ለሰብል ምክሮች 1፣ ለአየር ሁኔታ ሪፖርቶች 2፣ ለማስጠንቀቂያ ቅንብሮች 3 ይጫኑ።',
      'Afaan Oromoo filatameera. Baafata Ijoo: Gorsa midhaaniif 1, gabaasa qilleensaaf 2, qindaa’ina akeekkachiisaaf 3 tuqaa.',
    ),
    'Invalid option. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.': (
      'ልክ ያልሆነ ምርጫ። ለእንግሊዝኛ 1፣ ለአማርኛ 2፣ ለአፋን ኦሮሞ 3 ይጫኑ።',
      'Filannoo sirrii hin taane. Ingiliffaaf 1, Amaariffaaf 2, Afaan Oromoof 3 tuqaa.',
    ),
    'Crop Advisories: Press 1 for Wheat Rust warning, Press 2 for Maize irrigation tips. Press * to return to Main Menu.': (
      'የሰብል ምክሮች፦ ለስንዴ ዝገት ማስጠንቀቂያ 1፣ ለበቆሎ መስኖ ምክሮች 2 ይጫኑ። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Gorsa Midhaanii: Akeekkachiisa dafqa qamadii 1, gorsa jallisii boqqolloo 2 tuqaa. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
    'Weather Report: Fair agricultural weather conditions expected this week. Optimal temperature 24°C. Press * to return to Main Menu.': (
      'የአየር ሁኔታ ሪፖርት፦ በዚህ ሳምንት ለግብርና ምቹ የአየር ሁኔታ ይጠበቃል። ተስማሚ ሙቀት 24°C ነው። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Gabaasa Qilleensaa: Haalli qilleensaa qonnaaf mijatu torban kana eegama. Ho’i mijataa 24°C. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
    'Alert Settings: Press 1 to Enable SMS Alerts, Press 2 to Disable SMS Alerts. Press * to return to Main Menu.': (
      'የማስጠንቀቂያ ቅንብሮች፦ የSMS ማስጠንቀቂያዎችን ለማንቃት 1፣ ለማሰናከል 2 ይጫኑ። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Qindaa’ina Akeekkachiisaa: Akeekkachiisa SMS banuuf 1, cufuuf 2 tuqaa. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
    'Invalid option. Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.': (
      'ልክ ያልሆነ ምርጫ። ዋና ምናሌ፦ ለሰብል ምክሮች 1፣ ለአየር ሁኔታ ሪፖርቶች 2፣ ለማስጠንቀቂያ ቅንብሮች 3 ይጫኑ።',
      'Filannoo sirrii hin taane. Baafata Ijoo: Gorsa midhaaniif 1, gabaasa qilleensaaf 2, qindaa’ina akeekkachiisaaf 3 tuqaa.',
    ),
    'Main Menu: Press 1 for Crop Advisories, Press 2 for Weather Reports, Press 3 for Alert Settings.': (
      'ዋና ምናሌ፦ ለሰብል ምክሮች 1፣ ለአየር ሁኔታ ሪፖርቶች 2፣ ለማስጠንቀቂያ ቅንብሮች 3 ይጫኑ።',
      'Baafata Ijoo: Gorsa midhaaniif 1, gabaasa qilleensaaf 2, qindaa’ina akeekkachiisaaf 3 tuqaa.',
    ),
    'Wheat Rust Warning: High probability of fungal growth. Ensure chemical treatment is applied before morning dew. Press * to return to Main Menu.': (
      'የስንዴ ዝገት ማስጠንቀቂያ፦ የፈንገስ እድገት እድሉ ከፍተኛ ነው። ከጠዋት ጠል በፊት ኬሚካላዊ ሕክምና ያድርጉ። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Akeekkachiisa Dafqa Qamadii: Carraan guddina fangasii olaanaadha. Jiidha ganamaa dura qoricha keemikaalaa fayyadamaa. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
    'Maize irrigation tips: Drip irrigate crops during evenings. Avoid midday watering. Press * to return to Main Menu.': (
      'የበቆሎ መስኖ ምክር፦ ምሽት ላይ በጠብታ መስኖ ያጠጡ። በቀትር ከማጠጣት ይቆጠቡ። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Gorsa Jallisii Boqqolloo: Galgala bishaan suuta kennaa. Walakkaa guyyaa bishaan kennuu irraa fagaadhaa. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
    'SMS alerts successfully enabled. You will receive agricultural updates on your phone. Press * to return to Main Menu.': (
      'የSMS ማስጠንቀቂያዎች በተሳካ ሁኔታ ነቅተዋል። የግብርና ዝማኔዎችን በስልክዎ ያገኛሉ። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Akeekkachiisni SMS milkaa’inaan banameera. Haaromsa qonnaa bilbila keessan irratti argattu. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
    'SMS alerts disabled. Press * to return to Main Menu.': (
      'የSMS ማስጠንቀቂያዎች ተሰናክለዋል። ወደ ዋና ምናሌ ለመመለስ * ይጫኑ።',
      'Akeekkachiisni SMS cufameera. Gara baafata ijoo deebi’uuf * tuqaa.',
    ),
  };

  static List<String> get translatableScreenText =>
      List.unmodifiable(_screenTranslations.keys);

  String translate(String source) {
    final translations = _screenTranslations[source];
    if (translations == null) return source;
    return switch (language) {
      AppLanguage.amharic => translations.$1,
      AppLanguage.oromo => translations.$2,
      AppLanguage.english => source,
    };
  }

  String smsStatusLabel(String status) => switch (status) {
    'DELIVERED' => switch (language) {
      AppLanguage.amharic => 'ደርሷል',
      AppLanguage.oromo => 'Geessameera',
      AppLanguage.english => 'Delivered',
    },
    'FAILED' => switch (language) {
      AppLanguage.amharic => 'አልተሳካም',
      AppLanguage.oromo => 'Hin milkoofne',
      AppLanguage.english => 'Failed',
    },
    'QUEUED' => switch (language) {
      AppLanguage.amharic => 'ተሰልፏል',
      AppLanguage.oromo => 'Tarreeffameera',
      AppLanguage.english => 'Queued',
    },
    _ => status,
  };
}

String appText(String source) => AppLocalizations.current.translate(source);
