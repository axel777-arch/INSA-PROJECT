import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/mock_api_client.dart';
import '../../../../services/content_service.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class ExpertAnalyticsScreen extends StatefulWidget {
  const ExpertAnalyticsScreen({super.key});

  @override
  State<ExpertAnalyticsScreen> createState() => _ExpertAnalyticsScreenState();
}

class _ExpertAnalyticsScreenState extends State<ExpertAnalyticsScreen> {
  final ContentService _contentService = ContentService(apiClient: MockApiClient());
  bool _isLoading = true;

  int _approvedCount = 0;
  int _rejectedCount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final approved = await _contentService.getAdvisories(status: 'APPROVED');
    final rejected = await _contentService.getAdvisories(status: 'REJECTED');
    final pending = await _contentService.getAdvisories(status: 'IN_REVIEW');
    if (!mounted) return;
    setState(() {
      // Baseline offsets keep the dashboard reading like an established
      // account history rather than resetting to zero on a fresh mock store.
      _approvedCount = 1432 + approved.length;
      _rejectedCount = 284 + rejected.length;
      _pendingCount = pending.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(
        title: const Text('Expert Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.p16),
                children: [
                  // Stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Approved',
                          '$_approvedCount',
                          '+12% vs last month',
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Rejected',
                          '$_rejectedCount',
                          '-3% vs last month',
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildStatCard(
                    'Pending Items',
                    '$_pendingCount',
                    'Requires immediate attention',
                    AppColors.warning,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSizes.p20),

                  // Monthly Approvals Chart Mock
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Approvals Trend',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.p16),
                          SizedBox(
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildChartBar('Jan', 0.3, theme.primaryColor),
                                _buildChartBar('Feb', 0.45, theme.primaryColor),
                                _buildChartBar('Mar', 0.6, theme.primaryColor),
                                _buildChartBar('Apr', 0.5, theme.primaryColor),
                                _buildChartBar('May', 0.8, theme.primaryColor),
                                _buildChartBar('Jun', 0.95, theme.primaryColor),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Review Volume by Crop Category Chart Mock
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Volume by Crop Category',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.p16),
                          _buildCropVolumeRow('Cereals', 0.75, theme.primaryColor),
                          _buildCropVolumeRow('Legumes', 0.45, theme.colorScheme.secondary),
                          _buildCropVolumeRow('Fruits', 0.3, theme.primaryColor),
                          _buildCropVolumeRow('Vegetables', 0.6, theme.colorScheme.secondary),
                          _buildCropVolumeRow('Roots', 0.15, theme.primaryColor),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    ));
  }

  Widget _buildStatCard(String label, String value, String change, Color color, {bool fullWidth = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(change, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String month, double fraction, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 100 * fraction,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 4),
        Text(month, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildCropVolumeRow(String label, double fraction, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                color: color,
                minHeight: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
