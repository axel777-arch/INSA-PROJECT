import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';

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
    _selectedLanguage = LanguageService.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languages = LanguageService.supportedLanguages;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 64,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: AppSizes.p24),
                Text(
                  LanguageService.tr('select_language'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  LanguageService.tr('choose_language_desc'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.p32),
                Expanded(
                  child: ListView.builder(
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = _selectedLanguage == lang['code'];
                      return Card(
                        color: isSelected
                            ? theme.primaryColor.withValues(alpha: 0.08)
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
                            lang['nativeName'] ?? lang['name']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.primaryColor : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: theme.primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedLanguage = lang['code']!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                AppButton(
                  label: LanguageService.tr('continue'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final primaryColor = theme.primaryColor;

                    await LanguageService.setLanguage(_selectedLanguage);
                    if (!mounted) return;

                    final selectedLangObj = languages.firstWhere(
                      (l) => l['code'] == _selectedLanguage,
                      orElse: () => {'name': _selectedLanguage},
                    );

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '${LanguageService.tr('language_updated')}: ${selectedLangObj['nativeName'] ?? selectedLangObj['name']}',
                        ),
                        backgroundColor: primaryColor,
                      ),
                    );

                    final authService = AuthService(apiClient: ApiClient());
                    if (authService.isAuthenticated) {
                      navigator.pop(_selectedLanguage);
                    } else {
                      navigator.pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
