import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class PendingApprovalScreen extends StatelessWidget {
  final String role;

  const PendingApprovalScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpert = role.toLowerCase().contains('expert');
    final roleName = isExpert ? 'Agricultural Expert' : 'Extension Worker';

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
                  Icons.pending_actions_rounded,
                  color: theme.colorScheme.secondary,
                  size: 80,
                ),
              ),
              const SizedBox(height: AppSizes.p32),
              Text(
                'Registration Submitted!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              Text(
                'Your account registration as an "$roleName" has been received successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                'Before you can log in, an Administrator must review and approve your registration request. Please check back later or contact your system admin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.p40),
              AppButton(
                label: 'Back to Login',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
