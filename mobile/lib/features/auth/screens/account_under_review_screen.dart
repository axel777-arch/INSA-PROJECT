import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AccountUnderReviewScreen extends StatelessWidget {
  const AccountUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.p24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: theme.colorScheme.secondary,
                  size: 80,
                ),
              ),
              const SizedBox(height: AppSizes.p32),
              Text(
                'Account Under Review',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              const Text(
                'Your expert credentials are currently being verified by the administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.p12),
              const Text(
                'You will receive an email notification once your profile is approved. Thank you for your patience.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.p40),
              AppButton(
                label: 'Return to Login',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(height: AppSizes.p12),
              AppButton.text(
                label: 'Contact Support',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
