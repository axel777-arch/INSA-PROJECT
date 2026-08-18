import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

class AssignedWorkflowScreen extends StatelessWidget {
  const AssignedWorkflowScreen({super.key});

  static const List<Map<String, String>> _workflows = [
    {'title': 'Rust alert draft', 'status': 'IN_REVIEW', 'crop': 'Teff'},
    {'title': 'Wheat fertilizer tips', 'status': 'APPROVED', 'crop': 'Wheat'},
    {'title': 'Maize irrigation guide', 'status': 'DRAFT', 'crop': 'Maize'},
    {'title': 'Barley pest control', 'status': 'PUBLISHED', 'crop': 'Barley'},
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
      case 'PUBLISHED':
        return AppColors.success;
      case 'IN_REVIEW':
        return AppColors.warning;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Workflows')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: _workflows.length,
        itemBuilder: (context, index) {
          final wf = _workflows[index];
          final color = _statusColor(wf['status']!);
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              leading: Icon(Icons.assignment_outlined, color: color),
              title: Text(wf['title']!),
              subtitle: Text('Crop: ${wf['crop']}'),
              trailing: Chip(
                label: Text(
                  wf['status']!,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: color.withValues(alpha: 0.1),
                side: BorderSide(color: color.withValues(alpha: 0.3)),
              ),
            ),
          );
        },
      ),
    );
  }
}
