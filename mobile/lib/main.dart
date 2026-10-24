import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/localization/locale_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await LocaleProvider.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Global theme switcher notifier
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              title: 'Agri-Insight Beacon',
              debugShowCheckedModeBanner: false,
              locale: LocaleProvider.instance.currentLocale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              initialRoute: AppRouter.splash,
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        );
      },
    );
  }
}

