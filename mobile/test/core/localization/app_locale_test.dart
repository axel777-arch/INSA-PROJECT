import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/user_session.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/core/routing/app_router.dart';
import 'package:mobile/features/auth/screens/choose_language_screen.dart';
import 'package:mobile/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocale.instance.initialize();
  });

  test('supports all languages offered by the language picker', () async {
    for (final code in AppLocale.supportedLanguageCodes) {
      await AppLocale.instance.setLanguage(code);
      expect(AppLocale.instance.currentLanguage, code);
      expect(AppLocale.instance.currentLocale.languageCode, code);
    }
  });

  test(
    'stores language selection separately for each signed-in user',
    () async {
      await AppLocale.instance.setLanguage('am', userId: 'farmer-1');
      await AppLocale.instance.initializeForUser(
        userId: 'expert-1',
        preferredLanguage: 'ti',
      );
      expect(AppLocale.instance.currentLanguage, 'ti');

      await AppLocale.instance.initializeForUser(
        userId: 'farmer-1',
        preferredLanguage: 'en',
      );
      expect(AppLocale.instance.currentLanguage, 'am');
    },
  );

  test('uses the account preference when no local selection exists', () async {
    await AppLocale.instance.initializeForUser(
      userId: 'worker-1',
      preferredLanguage: 'or',
    );

    expect(AppLocale.instance.currentLanguage, 'or');
  });

  test('falls back to English for an unsupported language code', () async {
    await AppLocale.instance.setLanguage('fr');

    expect(AppLocale.instance.currentLanguage, 'en');
  });

  testWidgets('language selection opens the logged-in role home', (
    tester,
  ) async {
    UserSession.set(
      UserModel(
        id: 'expert-1',
        fullName: 'Expert',
        phone: '',
        email: '',
        role: 'EXPERT',
        preferredLanguage: 'en',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const ChooseLanguageScreen(),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) => Text(
            settings.name == AppRouter.expertHome
                ? 'Expert dashboard'
                : 'Unexpected destination',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Afaan Oromoo'));
    await tester.pumpAndSettle();

    expect(find.text('Expert dashboard'), findsOneWidget);
    expect(AppLocale.instance.currentLanguage, 'or');
  });

  test('resolves the correct home route for every role', () {
    expect(AppRouter.homeRouteForRole('ADMIN'), AppRouter.adminHome);
    expect(AppRouter.homeRouteForRole('EXPERT'), AppRouter.expertHome);
    expect(
      AppRouter.homeRouteForRole('EXTENSION_WORKER'),
      AppRouter.extensionHome,
    );
    expect(AppRouter.homeRouteForRole('FARMER'), AppRouter.farmerHome);
  });
}
