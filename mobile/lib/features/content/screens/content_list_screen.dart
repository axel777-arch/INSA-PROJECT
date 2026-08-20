import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ContentListScreen extends StatelessWidget {
  const ContentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('Agricultural Bulletins')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              title: Text('Advisory Title ${index + 1}'),
              subtitle: const Text('Crop: Wheat | Language: English'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pushNamed(context, '/content/detail', arguments: '${index + 1}');
              },
            ),
          );
        },
      ),
    ));
  }
}
