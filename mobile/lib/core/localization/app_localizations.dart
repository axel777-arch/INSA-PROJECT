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
}
