import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              color: theme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, Farmer!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Region: Oromia | Language: Afaan Oromoo',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            
            // Crops Section
            Text(
              'My Registered Crops',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            Row(
              children: ['Wheat', 'Teff', 'Maize'].map((crop) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.p8),
                  child: Chip(
                    label: Text(crop),
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: theme.primaryColor),
                    side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.p24),

            // Advisories Section
            Text(
              'Latest Advisories',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bug_report_outlined, color: AppColors.warning),
                title: const Text('Teff Rust Control Warning'),
                subtitle: const Text('For Oromia Region. Recommended pesticide treatment guidelines...'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.wb_sunny_outlined, color: AppColors.secondary),
                title: const Text('Wheat Sowing Season Tips'),
                subtitle: const Text('Optimizing soil moisture parameters before seed distribution...'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: AppSizes.p32),

            // Simulators access
            Text(
              'Demo Simulation Tools',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p12),
            AppButton.outlined(
              label: 'Open SMS Simulator',
              icon: Icons.sms_rounded,
              onPressed: () {
                Navigator.pushNamed(context, '/simulator/sms');
              },
            ),
            const SizedBox(height: AppSizes.p12),
            AppButton.outlined(
              label: 'Open IVR Voice Simulator',
              icon: Icons.phone_callback_rounded,
              onPressed: () {
                Navigator.pushNamed(context, '/simulator/ivr');
              },
            ),
          ],
        ),
      ),
    );
  }
}
