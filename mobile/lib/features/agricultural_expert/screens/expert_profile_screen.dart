import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

class ExpertProfileScreen extends StatelessWidget {
  const ExpertProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Expert Profile')),
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
                  subtitle: const Text('Dr. Daniel Kassa'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: const Text('+251911223344'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: const Text('Expertise Areas'),
                  subtitle: const Text('Crop Disease, Soil Science, Pest Management'),
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
    );
  }
}
