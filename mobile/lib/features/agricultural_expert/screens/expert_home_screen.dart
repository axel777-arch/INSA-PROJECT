import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../services/api_client.dart';
import '../../../services/content_service.dart';

class ExpertHomeScreen extends StatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  final ContentService _contentService = ContentService(apiClient: ApiClient());
  int _pendingReviewCount = 0;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    final pending = await _contentService.getAdvisories(status: 'IN_REVIEW');
    if (!mounted) return;
    setState(() {
      _pendingReviewCount = pending.length;
      _isLoading = false;
    });
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    await _loadCounts();
    if (!mounted) return;
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data synced successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri-Insight Beacon'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              MyApp.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: AppSizes.p8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Text(
                'Welcome back, Dr. Aris',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is your operational overview for today.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.p12),
              OutlinedButton.icon(
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(_isSyncing ? 'Syncing...' : 'Sync Data'),
                onPressed: _isSyncing ? null : _syncData,
              ),
              const SizedBox(height: AppSizes.p20),

              // Review Content Card
              Card(
                child: ListTile(
                  leading: Icon(Icons.rate_review_outlined, color: theme.primaryColor, size: 32),
                  title: const Text('Review Content', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_isLoading
                      ? 'Loading...'
                      : 'Pending articles and field reports requiring validation.\n$_pendingReviewCount Pending'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await Navigator.pushNamed(context, '/expert/review/list');
                    _loadCounts();
                  },
                ),
              ),
              const SizedBox(height: AppSizes.p12),

              // Review Cases Card
              Card(
                child: ListTile(
                  leading: Icon(Icons.biotech_outlined, color: theme.colorScheme.secondary, size: 32),
                  title: const Text('Review Cases', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Active pest and disease identification requests.\n8 Pending'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pushNamed(context, '/expert/case/detail');
                  },
                ),
              ),
              const SizedBox(height: AppSizes.p12),

              // Expert Analytics Card
              Card(
                child: ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: Colors.blue, size: 32),
                  title: const Text('Expert Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Your review accuracy and throughput.\n148 Total Approvals | 23 Rejections'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pushNamed(context, '/expert/analytics');
                  },
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p8),
              Card(
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    ListTile(
                      leading: CircleAvatar(child: Icon(Icons.check_circle_outline, color: Colors.green)),
                      title: Text('Approved field report: Soil Moisture'),
                      subtitle: Text('2 hours ago • Submitted by Field Tech'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(child: Icon(Icons.error_outline, color: Colors.orange)),
                      title: Text('Reviewed Case: Suspected Blight'),
                      subtitle: Text('3 hours ago • Flagged for further observation'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
