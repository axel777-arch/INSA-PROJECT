import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('Recent Alerts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text('Emergency Alert ${index + 1}'),
              subtitle: const Text('Target Crop: Wheat | Channel: SMS'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Emergency Alert ${index + 1}'),
                    content: const Text(
                      'Target Crop: Wheat\n'
                      'Channel: SMS\n\n'
                      'Detailed Description:\n'
                      'This is a detailed description of the alert, warning farmers about potential crop diseases or weather changes in the area. Please take necessary precautions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    ));
  }
}