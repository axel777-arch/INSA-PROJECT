import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent Alerts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text('Emergency Alert #${index + 1}'),
              subtitle: const Text('Target Crop: Wheat | Channel: SMS'),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
