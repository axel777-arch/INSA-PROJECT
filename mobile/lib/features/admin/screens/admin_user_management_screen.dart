import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> users = [
      {
        'name': 'Elias Thorne',
        'role': 'Farmer',
        'phone': '+254712345678',
        'location': 'Midwest Valley',
        'active': true,
      },
      {
        'name': 'Sarah Jenkins',
        'role': 'Extension Worker',
        'phone': '+254712345679',
        'location': 'Northern Plains',
        'active': true,
      },
      {
        'name': 'Marcus Reyes',
        'role': 'Agronomy Expert',
        'phone': '+254712345680',
        'location': 'Southern Delta',
        'active': false,
      }
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            const AppTextField(
              label: 'Search users by name, phone, or email...',
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSizes.p12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['All', 'Farmer', 'Extension', 'Expert'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['All', 'Active', 'Disabled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isActive = user['active'] as bool;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.p12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          user['role'] == 'Farmer' 
                              ? Icons.people_outline_rounded 
                              : user['role'] == 'Extension Worker' 
                                  ? Icons.engineering_outlined 
                                  : Icons.psychology_outlined,
                        ),
                      ),
                      title: Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${user['role']} • ${user['location']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? AppColors.success.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Disabled',
                          style: TextStyle(
                            color: isActive ? AppColors.success : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
