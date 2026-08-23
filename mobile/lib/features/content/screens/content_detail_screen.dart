import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/content_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/content_service.dart';

class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  late Future<ContentModel?> _advisory;

  @override
  void initState() {
    super.initState();
    _advisory = _contentService.getAdvisoryById(widget.contentId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('Article Detail')),
        body: FutureBuilder<ContentModel?>(
          future: _advisory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final advisory = snapshot.data;
            if (snapshot.hasError || advisory == null) {
              return const Center(child: Text('This advisory is no longer available.'));
            }
            return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image Placeholder
              Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 180,
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        advisory.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              Text(
                advisory.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: AppSizes.p12),

              // Author Badge
              Row(
                children: [
                  const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                  const SizedBox(width: AppSizes.p12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisory.createdBy,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Published ${advisory.updatedAt.toLocal().toString().split(' ').first}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              const Divider(height: AppSizes.p32),

              // Article body
              Text(advisory.body),
              const SizedBox(height: AppSizes.p20),

              // Key Observations
              Text(
                'Key Observations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              _buildObservationRow('Crop', advisory.cropId),
              _buildObservationRow('Language', advisory.language),
              const SizedBox(height: AppSizes.p20),

              // Expert Recommendation Card
              Card(
                color: theme.primaryColor.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: AppSizes.p8),
                          Text(
                            'Expert Recommendation',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: AppSizes.p16),
                      Text(advisory.body, style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              // Related Resources
              Text(
                'Related Resources',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.error,
                  ),
                  title: const Text('Soil Sampling Best Practices'),
                  subtitle: const Text('PDF Guide • 2.4 MB'),
                  trailing: const Icon(Icons.download_rounded),
                  onTap: () {},
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.map_outlined, color: Colors.blue),
                  title: const Text('Regional Weather Forecast'),
                  subtitle: const Text('Interactive Map'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () {},
                ),
              ),
            ],
          ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildObservationRow(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
