import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../localization/app_localizations.dart';
import '../localization/locale_provider.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

/// Shows a standardized language selection modal bottom sheet across any role screen.
Future<void> showAppLanguagePicker(BuildContext context) async {
  final current = LocaleProvider.instance.currentLanguage;

  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p20,
            vertical: AppSizes.p16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              Text(
                appText('Select Language'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.p12),
              ...AppLanguage.values.map((lang) {
                final isSelected = lang == current;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  tileColor: isSelected
                      ? theme.primaryColor.withValues(alpha: 0.1)
                      : null,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected ? theme.primaryColor : Colors.grey,
                  ),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(lang.englishName),
                  trailing: Text(
                    lang.code.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.primaryColor : Colors.grey,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await LocaleProvider.instance.setLanguage(lang);
                  },
                );
              }),
              const SizedBox(height: AppSizes.p8),
            ],
          ),
        ),
      );
    },
  );
}

/// Standardized confirmation dialog and logout action across all role screens.
Future<void> showAppLogoutDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(appText('Log Out')),
      content: Text(
        appText('Are you sure you want to log out of Agri-Insight Beacon?'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(appText('Cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(appText('Log Out')),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    final authService = AuthService(apiClient: ApiClient());
    await authService.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (route) => false,
      );
    }
  }
}

/// Consistent top-right AppBar action items for every role screen:
/// 1. Language pill button (shows current language, opens picker)
/// 2. Logout icon button (shows confirmation dialog, logs out to login)
List<Widget> buildRoleAppBarActions(BuildContext context) {
  final currentLang = LocaleProvider.instance.currentLanguage;
  final theme = Theme.of(context);

  final langCodeLabel = switch (currentLang) {
    AppLanguage.english => 'EN',
    AppLanguage.amharic => 'አማ',
    AppLanguage.oromo => 'OM',
  };

  return [
    // Language quick switch button
    Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showAppLanguagePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language_rounded, size: 16, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  langCodeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    // Logout button
    IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: appText('Log Out'),
      onPressed: () => showAppLogoutDialog(context),
    ),
  ];
}
