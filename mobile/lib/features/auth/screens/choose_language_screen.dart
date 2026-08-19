import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'am', 'name': 'Amharic (አማርኛ)'},
    {'code': 'or', 'name': 'Afaan Oromoo'},
    {'code': 'ti', 'name': 'Tigrinya (ትግርኛ)'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                'Select Language',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              const Text(
                'Choose your preferred language to continue.',
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
                label: 'Continue',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
