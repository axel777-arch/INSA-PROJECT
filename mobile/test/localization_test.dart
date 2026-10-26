import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/config/user_session.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/core/localization/locale_provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/simulator/screens/sms_simulator_screen.dart';

void main() {
  group('Localization Tests (English, Amharic, Afaan Oromoo)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AppLocalizations loads correct translations for English', () {
      final loc = AppLocalizations(AppLanguage.english);

      expect(loc.farmerDashboard, 'Farmer Dashboard');
      expect(loc.marketPricesTitle, 'Local Market Prices');
      expect(loc.cropCalendar, 'Crop Calendar');
      expect(loc.askExtensionWorker, 'Ask an Extension Worker');
      expect(loc.offlineLibrary, 'Offline Library');
      expect(loc.welcomeBack('Dawit'), 'Welcome back, Dawit');
      expect(loc.adminSettings, 'Admin Settings');
      expect(loc.systemActivityLog, 'System Activity Log');
      expect(loc.defaultLanguage, 'Default Language');
    });

    test(
      'AppLocalizations loads authentic agricultural translations for Amharic',
      () {
        final loc = AppLocalizations(AppLanguage.amharic);

        expect(loc.farmerDashboard, 'የአርሶ አደር ዳሽቦርድ');
        expect(loc.marketPricesTitle, 'የአካባቢ ገበያ ዋጋዎች');
        expect(loc.cropCalendar, 'የሰብል የቀን መቁጠሪያ');
        expect(loc.askExtensionWorker, 'የግብርና ባለሙያ ይጠይቁ');
        expect(loc.offlineLibrary, 'ያለ ኢንተርኔት የተሸመቱ ምክሮች');
        expect(loc.welcomeBack('ዳዊት'), 'እንኳን ደህና መጡ፣ ዳዊት');
        expect(loc.adminSettings, 'የአስተዳዳሪ ቅንብሮች');
        expect(loc.systemActivityLog, 'የስርዓት እንቅስቃሴ መዝገብ');
        expect(loc.defaultLanguage, 'ነባሪ ቋንቋ');
      },
    );

    test(
      'AppLocalizations loads authentic agricultural translations for Afaan Oromoo',
      () {
        final loc = AppLocalizations(AppLanguage.oromo);

        expect(loc.farmerDashboard, 'Daashboordii Qonnaan Bulaa');
        expect(loc.marketPricesTitle, 'Gatiiwwan Gabaa Naannoo');
        expect(loc.cropCalendar, 'Kalaandarii Midhaanii');
        expect(loc.askExtensionWorker, 'Ogeessa Qonnaa Gaafadhaa');
        expect(loc.offlineLibrary, 'Gorsawwan Toora Alaa');
        expect(loc.welcomeBack('Obsaa'), 'Baga nagaan dhufte, Obsaa');
        expect(loc.adminSettings, 'Qindaa’inoota Bulchaa');
        expect(loc.systemActivityLog, 'Galmee sochii sirnaa');
        expect(loc.defaultLanguage, 'Afaan durtii');
      },
    );

    test('LocaleProvider updates and persists language selection', () async {
      final provider = LocaleProvider.instance;
      await provider.initialize();

      expect(provider.currentLanguage, AppLanguage.english);

      await provider.setLanguage(AppLanguage.amharic);
      expect(provider.currentLanguage, AppLanguage.amharic);
      expect(provider.currentLocale.languageCode, 'am');

      await provider.setLanguage(AppLanguage.oromo);
      expect(provider.currentLanguage, AppLanguage.oromo);
      expect(provider.currentLocale.languageCode, 'om');
    });

    test('AppLanguage enum correctly maps language codes', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('am'), AppLanguage.amharic);
      expect(AppLanguage.fromCode('om'), AppLanguage.oromo);
      expect(AppLanguage.fromCode('or'), AppLanguage.oromo);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.english);
      expect(AppLanguage.fromCode(null), AppLanguage.english);
    });

    test(
      'every screen translation is available in all supported languages',
      () {
        final english = AppLocalizations(AppLanguage.english);
        final amharic = AppLocalizations(AppLanguage.amharic);
        final oromo = AppLocalizations(AppLanguage.oromo);

        for (final source in AppLocalizations.translatableScreenText) {
          expect(english.translate(source), source, reason: source);
          expect(amharic.translate(source).trim(), isNotEmpty, reason: source);
          expect(oromo.translate(source).trim(), isNotEmpty, reason: source);
        }
      },
    );

    testWidgets('login and SMS simulator display selected language', (
      tester,
    ) async {
      await LocaleProvider.instance.setLanguage(AppLanguage.amharic);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('ግባ'), findsOneWidget);
      expect(find.text('አስታውሰኝ'), findsOneWidget);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isTrue,
      );

      await UserSession.clear();
      await tester.pumpWidget(const MaterialApp(home: SmsSimulatorScreen()));
      await tester.pump();

      expect(find.text('የSMS አስመሳይ'), findsOneWidget);
      expect(find.text('SMS ላክ'), findsOneWidget);
      expect(find.text('SMS ለመላክ ወደ መለያዎ ይግቡ።'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'SMS ላክ'),
            )
            .onPressed,
        isNull,
      );

      await LocaleProvider.instance.setLanguage(AppLanguage.english);
    });
  });
}
