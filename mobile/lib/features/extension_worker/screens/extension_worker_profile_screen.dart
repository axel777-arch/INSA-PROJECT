import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExtensionWorkerProfileScreen extends StatelessWidget {
  const ExtensionWorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('Extension Worker Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            child: Icon(Icons.person_rounded, size: 48, color: theme.primaryColor),
          ),
          const SizedBox(height: AppSizes.p16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Full Name'),
                  subtitle: const Text('Helen Worku'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: const Text('+251912445566'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: const Text('Assigned Region'),
                  subtitle: const Text('Oromia — East Shewa Zone'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: const Text('Status'),
                  subtitle: Text(
                    'Active — Approved',
                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
