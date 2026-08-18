import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriAdmin Portal'),
        actions: const [
          Icon(Icons.admin_panel_settings_rounded),
          SizedBox(width: AppSizes.p16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          Text(
            'System Overview',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.p16),

          // Core metrics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.p12,
            mainAxisSpacing: AppSizes.p12,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard('Total Farmers', '1,248', Icons.people_outline_rounded, Colors.green),
              _buildMetricCard('Extension Workers', '48', Icons.engineering_outlined, Colors.orange),
              _buildMetricCard('Agronomy Experts', '24', Icons.psychology_outlined, Colors.purple),
              _buildMetricCard('Published Bulletins', '186', Icons.article_outlined, Colors.blue),
              _buildMetricCard('Messages Sent', '8,420', Icons.sms_outlined, Colors.teal),
              _buildMetricCard('Delivery Rate', '94.8%', Icons.check_circle_outline_rounded, Colors.cyan),
            ],
          ),
          const SizedBox(height: AppSizes.p20),

          // Region Stats chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farmers by Region',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  _buildRegionRow('Oromia', 520, 0.75, Colors.green),
                  _buildRegionRow('Amhara', 340, 0.55, Colors.orange),
                  _buildRegionRow('SNNPR', 220, 0.35, Colors.purple),
                  _buildRegionRow('Tigray', 168, 0.25, Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Message trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content Review Status',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPieMock('Published', '124', Colors.green),
                      _buildPieMock('In Review', '42', Colors.orange),
                      _buildPieMock('Drafts', '20', Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Recent Activities list
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Activity Log',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: AppSizes.p20),
                  _buildActivityItem('Jane Doe (Extension) registered farmer John Smith', '2 mins ago'),
                  _buildActivityItem('Dr. Aris (Expert) approved Wheat Rust Alert bulletin', '15 mins ago'),
                  _buildActivityItem('System automatically dispatched 452 SMS alerts', '1 hour ago'),
                  _buildActivityItem('Database backup completed successfully', '4 hours ago'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionRow(String name, int count, double fraction, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(name, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                color: color,
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPieMock(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 6),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          )
        ],
      ),
    );
  }
}
