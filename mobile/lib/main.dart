import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/localization/app_locale.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[ENV] .env load warning: $e');
  }

  // Pre-hydrate authentication session and localized strings before rendering routes
  await AppLocale.instance.initialize();
  await AuthService(apiClient: ApiClient()).initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Global theme switcher notifier
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeNotifier, AppLocale.instance]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Agri-Insight Beacon',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.value,
          locale: AppLocale.instance.currentLocale,
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
