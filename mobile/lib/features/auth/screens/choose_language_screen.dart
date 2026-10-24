import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/locale_provider.dart';
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

  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'am', 'name': 'Amharic', 'native': 'አማርኛ'},
    {'code': 'om', 'name': 'Afaan Oromoo', 'native': 'Afaan Oromoo'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LocaleProvider.instance.currentLanguage.code;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Language Settings'),
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
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
                const SizedBox(height: AppSizes.p20),
                Text(
                  'Select Language / ቋንቋ ይምረጡ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  'Choose your preferred language for advisories and dashboards.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.p24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _languages.length,
                    itemBuilder: (_, index) {
                      final lang = _languages[index];
                      final isSelected = _selectedLanguage == lang['code'];
                      return Card(
                        color: isSelected
                            ? theme.primaryColor.withValues(alpha: 0.08)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          side: BorderSide(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            '${lang['name']} (${lang['native']})',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? theme.primaryColor : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: theme.primaryColor)
                              : null,
                          onTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final appLang =
                                AppLanguage.fromCode(lang['code']);
                            await LocaleProvider.instance.setLanguage(appLang);
                            if (!mounted) return;
                            setState(() {
                              _selectedLanguage = appLang.code;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Language changed to ${lang['name']} (${lang['native']})',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                AppButton(
                  label: 'Confirm & Continue',
                  onPressed: () {
                    final authService = AuthService(apiClient: ApiClient());
                    if (authService.isAuthenticated) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
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

