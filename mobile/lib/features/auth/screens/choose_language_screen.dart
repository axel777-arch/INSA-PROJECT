import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../core/config/user_session.dart'; // 🌟 Added to look up active logged-in user context profiles

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = AppLocale.instance.currentLanguage;
  }

  // Your internal platform dictionary key mappings list array context
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'am', 'name': 'Amharic (አማርኛ)'},
    {'code': 'or', 'name': 'Afaan Oromoo'},
    {'code': 'ti', 'name': 'Tigrinya (ትግርኛ)'},
  ];

  // 🌟 Handles smart context navigation routing targets safely upon user interaction selection
  void _navigateToCorrectDashboard() async {
    final user = await UserSession.get();
    
    if (!mounted) return;

    // If an active persistent session configuration profile exists, re-stack layouts to preserve session state
    if (user != null) {
      String destinationRoute = '/farmer/home'; // Fallback portal block path
      
      switch (user.role) {
        case 'ADMIN':
          destinationRoute = '/admin/home';
          break;
        case 'EXPERT':
          destinationRoute = '/expert/home';
          break;
        case 'EXTENSION_WORKER':
          destinationRoute = '/extension/home';
          break;
      }
      
      // Wipe structural cache traces below it and route user smoothly back home
      Navigator.pushNamedAndRemoveUntil(context, destinationRoute, (route) => false);
    } else {
      // If the user hasn't logged in at all, take them back to the login/onboarding portal cleanly
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.p32),
                Icon(
                  Icons.translate_rounded,
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: AppSizes.p24),
                Text(
                  'select_language'.tr, // 🌟 Dynamic Translation Hook
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  'choose_language_desc'.tr, // 🌟 Dynamic Translation Hook
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.p32),
                Expanded(
                  child: ListView.builder(
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = _selectedLanguage == lang['code'];
                      return Card(
                        color: isSelected 
                            ? theme.primaryColor.withValues(alpha: 0.05)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          side: BorderSide(
                            color: isSelected ? theme.primaryColor : theme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            lang['name']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle, color: theme.primaryColor)
                              : null,
                          onTap: () async {
                            final code = lang['code']!;
                            setState(() {
                              _selectedLanguage = code;
                            });
                            // Commits locale updates safely across active reactive app listeners
                            await AppLocale.instance.setLanguage(code);
                            if (!context.mounted) return;
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Language updated to ${lang['name']}.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                AppButton(
                  label: 'continue'.tr, // 🌟 Dynamic Translation Hook
                  onPressed: _navigateToCorrectDashboard, // 🌟 Redirects back to active dashboards smoothly
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
