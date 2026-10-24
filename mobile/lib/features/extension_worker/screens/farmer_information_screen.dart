import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class FarmerInformationScreen extends StatelessWidget {
  const FarmerInformationScreen({super.key});

  static const List<Map<String, String>> _farmers = [
    {'name': 'Asefa Tolosa', 'phone': '+251911001122', 'region': 'Oromia', 'crops': 'Wheat, Teff'},
    {'name': 'Chala Kebe', 'phone': '+251912334455', 'region': 'Oromia', 'crops': 'Maize'},
    {'name': 'Tigist Alemu', 'phone': '+251913556677', 'region': 'Amhara', 'crops': 'Barley, Wheat'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('Farmer Information')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _farmers.length,
        itemBuilder: (context, index) {
          final farmer = _farmers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person_outline_rounded, color: theme.primaryColor),
              ),
              title: Text(farmer['name']!),
              subtitle: Text('${farmer['region']} | Crops: ${farmer['crops']}'),
              trailing: Text(farmer['phone']!, style: theme.textTheme.bodySmall),
            ),
          );
        },
      ),
    ));
  }
}
