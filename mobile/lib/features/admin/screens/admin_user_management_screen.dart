import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/api_client.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final AdminService _adminService = AdminService(apiClient: ApiClient());
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _roleFilter = 'All';
  String _statusFilter = 'All';

  static const List<String> _roleOptions = ['All', 'Farmer', 'Extension Worker', 'Expert', 'Admin'];
  static const List<String> _statusOptions = ['All', 'Active', 'Disabled'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _adminService.getAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _toggleUser(String id, bool currentActive) async {
    final newActive = !currentActive;
    final success = await _adminService.toggleUserStatus(id, newActive);
    if (!mounted) return;

    if (success) {
      setState(() {
        for (final u in _users) {
          if (u['id'] == id) {
            u['active'] = newActive;
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newActive ? 'User account activated.' : 'User account disabled.'),
          backgroundColor: newActive ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user status.'), backgroundColor: AppColors.error),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var results = List<Map<String, dynamic>>.from(_users);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((u) {
        final name = (u['full_name'] ?? u['fullName'] ?? '').toString().toLowerCase();
        final phone = (u['phone'] ?? '').toString().toLowerCase();
        final role = (u['role'] ?? '').toString().toLowerCase();
        return name.contains(query) || phone.contains(query) || role.contains(query);
      }).toList();
    }

    if (_roleFilter != 'All') {
      results = results.where((u) {
        final r = (u['role'] ?? '').toString().toUpperCase();
        if (_roleFilter == 'Farmer') return r == 'FARMER';
        if (_roleFilter == 'Extension Worker') return r == 'EXTENSION_WORKER';
        if (_roleFilter == 'Expert') return r == 'EXPERT';
        if (_roleFilter == 'Admin') return r == 'ADMIN' || r == 'SUPER_ADMIN';
        return true;
      }).toList();
    }

    if (_statusFilter != 'All') {
      final activeTarget = _statusFilter == 'Active';
      results = results.where((u) => (u['active'] as bool? ?? true) == activeTarget).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayed = _filteredUsers;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('User Management')),
        body: RefreshIndicator(
          onRefresh: _loadUsers,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Search by name, phone or role',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _roleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _statusFilter = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Users (${displayed.length})',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_isLoading)
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
                const SizedBox(height: AppSizes.p8),
                Expanded(
                  child: _isLoading && _users.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : displayed.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 64, color: theme.disabledColor),
                                  const SizedBox(height: 12),
                                  const Text('No users match the criteria.'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayed.length,
                              itemBuilder: (context, index) {
                                final user = displayed[index];
                                final id = user['id'] as String;
                                final name = (user['full_name'] ?? user['fullName'] ?? 'User') as String;
                                final role = (user['role'] ?? 'FARMER') as String;
                                final phone = (user['phone'] ?? 'N/A') as String;
                                final email = (user['email'] ?? '') as String;
                                final active = user['active'] as bool? ?? true;
                                final status = (user['status'] ?? 'APPROVED') as String;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: AppSizes.p8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: active
                                          ? theme.primaryColor.withValues(alpha: 0.1)
                                          : Colors.grey.withValues(alpha: 0.2),
                                      child: Icon(
                                        active ? Icons.person : Icons.person_off,
                                        color: active ? theme.primaryColor : Colors.grey,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: active ? null : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (status == 'APPROVED' ? AppColors.success : AppColors.warning)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: status == 'APPROVED' ? AppColors.success : AppColors.warning,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      '$role • $phone${email.isNotEmpty ? " • $email" : ""}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Switch(
                                      value: active,
                                      onChanged: (_) => _toggleUser(id, active),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
