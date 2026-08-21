import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExpertProfileScreen extends StatelessWidget {
  const ExpertProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Dr. Daniel Kassa'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder background - replace with expert.jpg if desired
                  Container(color: theme.primaryColor.withValues(alpha: 0.1)),
                  Center(
                    child: Icon(
                      Icons.person_rounded, 
                      size: 80, 
                      color: theme.primaryColor.withValues(alpha: 0.5)
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, 
                          Colors.black.withValues(alpha: 0.6)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                children: [
                  _buildDetailsCard(theme),
                  const SizedBox(height: AppSizes.p24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('tel:+251911223344');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not launch phone dialer')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact Expert'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(AppSizes.p16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDetailsCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shadowColor: theme.primaryColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.science_outlined, color: theme.primaryColor),
            title: const Text('Expertise Areas'),
            subtitle: const Text('Crop Disease, Soil Science, Pest Management'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.phone_outlined, color: theme.primaryColor),
            title: const Text('Phone'),
            subtitle: const Text('+251911223344'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.verified_outlined, color: theme.primaryColor),
            title: const Text('Status'),
            subtitle: Text(
              'Active — Approved',
              style: TextStyle(
                color: theme.primaryColor, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}