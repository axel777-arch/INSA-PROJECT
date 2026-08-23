import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../models/content_model.dart';
import '../../../../services/auth_service.dart';

class ContentListScreen extends StatefulWidget {
  const ContentListScreen({super.key});

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  late Future<List<ContentModel>> _advisories;

  @override
  void initState() {
    super.initState();
    _advisories = _loadAdvisories();
  }

  Future<List<ContentModel>> _loadAdvisories() async {
    String? location;
    try {
      final user = await AuthService(apiClient: ApiClient()).getMe();
      if (user != null) {
        final farmer = await ApiClient().get('/farmers/user/${user.id}');
        location = (farmer as Map<String, dynamic>)['region'] as String?;
      }
    } catch (_) {}
    return _contentService.getAdvisories(status: 'PUBLISHED', location: location);
  }

  Future<void> _refresh() async {
    setState(() => _advisories = _loadAdvisories());
    await _advisories;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Agricultural Bulletins'), actions: [
        IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
      ]),
      body: FutureBuilder<List<ContentModel>>(
        future: _advisories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load agricultural information.'));
          }
          final advisories = snapshot.data ?? [];
          if (advisories.isEmpty) {
            return const Center(child: Text('No published advisories yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: advisories.length,
              itemBuilder: (context, index) {
                final advisory = advisories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.p12),
                  child: ListTile(
                    title: Text(advisory.title),
                    subtitle: Text('Crop: ${advisory.cropId} | Language: ${advisory.language}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pushNamed(
                      context, '/content/detail', arguments: advisory.id,
                    ),
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
