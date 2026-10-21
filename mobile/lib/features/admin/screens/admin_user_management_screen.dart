import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  // Mock in-memory user directory. Static so status toggles persist across
  // navigation until this is wired to a real users endpoint.
  static final List<Map<String, dynamic>> _users = [
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
    },
    {
      'name': 'Amara Bekele',
      'role': 'Extension Worker',
      'phone': '+254712345681',
      'location': 'Eastern Highlands',
      'active': true,
    },
    {
      'name': 'Dr. Fikru Alemu',
      'role': 'Agronomy Expert',
      'phone': '+254712345682',
      'location': 'Central Region',
      'active': true,
    },
  ];

  final _searchController = TextEditingController();
  String _roleFilter = 'All';
  String _statusFilter = 'All';

  static const List<String> _roleOptions = ['All', 'Farmer', 'Extension Worker', 'Agronomy Expert'];
  static const List<String> _statusOptions = ['All', 'Active', 'Disabled'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var results = List<Map<String, dynamic>>.from(_users);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((u) {
        return (u['name'] as String).toLowerCase().contains(query) ||
            (u['phone'] as String).toLowerCase().contains(query);
      }).toList();
    }

    if (_roleFilter != 'All') {
      results = results.where((u) => u['role'] == _roleFilter).toList();
    }

    if (_statusFilter != 'All') {
      final wantsActive = _statusFilter == 'Active';
      results = results.where((u) => u['active'] == wantsActive).toList();
    }

    return results;
  }

  void _toggleStatus(Map<String, dynamic> user) {
    setState(() => user['active'] = !(user['active'] as bool));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user['name']} is now ${user['active'] ? 'active' : 'disabled'}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return ScreenBackdrop(child: Scaffold(backgroundColor: Colors.transparent,
      
      appBar: AppBar(title: const Text('User Management')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            AppTextField(
              label: 'Search users by name or phone...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: AppSizes.p12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _roleFilter,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _roleFilter = val);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFilter,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('No users match your search or filters.'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isActive = user['active'] as bool;
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSizes.p12),
                          child: ListTile(
                            onTap: () => _toggleStatus(user),
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
    ));
  }
}
