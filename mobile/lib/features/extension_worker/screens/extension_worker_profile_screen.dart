import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';

import 'package:mobile/core/localization/app_localizations.dart';

class ExtensionWorkerProfileScreen extends StatelessWidget {
  const ExtensionWorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(appText('Extension Worker Profile'))),
        body: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(appText('Full Name')),
                    subtitle: Text(appText('Helen Worku')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(appText('Phone')),
                    subtitle: Text(appText('+251912445566')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: Text(appText('Assigned Region')),
                    subtitle: Text(appText('Oromia — East Shewa Zone')),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: Text(appText('Status')),
                    subtitle: Text(
                      appText('Active — Approved'),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
