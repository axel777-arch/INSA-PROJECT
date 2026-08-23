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
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService(apiClient: ApiClient());
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  late final AnimationController _chartController;

  final _searchController = TextEditingController();
  String _roleFilter = 'All';
  String _statusFilter = 'All';

  static const List<String> _roleOptions = [
    'All',
    'Farmer',
    'Extension Worker',
    'Agronomy Expert',
  ];
  static const List<String> _statusOptions = ['All', 'Active', 'Disabled'];

  @override
  void initState() {
    super.initState();
    _chartController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 900),
          )
          ..addListener(() {
            if (mounted) setState(() {});
          })
          ..forward();
    _searchController.addListener(() => setState(() {}));
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _adminService.getUsers();
      if (mounted)
        setState(() {
          _users = users;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _chartController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var results = List<Map<String, dynamic>>.from(_users);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((u) {
        return (u['fullName'] as String? ?? '').toLowerCase().contains(query) ||
            (u['phone'] as String? ?? '').toLowerCase().contains(query);
      }).toList();
    }

    if (_roleFilter != 'All') {
      final role = _roleFilter.toUpperCase().replaceAll(' ', '_');
      results = results.where((u) => u['role'] == role).toList();
    }

    if (_statusFilter != 'All') {
      final wantsActive = _statusFilter == 'Active';
      results = results
          .where((u) => (u['active'] == true) == wantsActive)
          .toList();
    }

    return results;
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'EXTENSION_WORKER':
        return 'Extension Workers';
      case 'EXPERT':
        return 'Agronomy Experts';
      case 'FARMER':
        return 'Farmers';
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'EXTENSION_WORKER':
        return Colors.orange;
      case 'EXPERT':
        return Colors.blue;
      case 'FARMER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _metric(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: AppSizes.p8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(label, style: const TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleBars(List<Map<String, dynamic>> users) {
    const roles = ['FARMER', 'EXTENSION_WORKER', 'EXPERT'];
    final counts = {
      for (final role in roles)
        role: users.where((user) => user['role'] == role).length,
    };
    final maximum = counts.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Users by Role',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p20),
            ...roles.map((role) {
              final count = counts[role]!;
              final ratio = maximum == 0 ? 0.0 : count / maximum;
              final animatedRatio =
                  ratio *
                  CurvedAnimation(
                    parent: _chartController,
                    curve: Curves.easeOutCubic,
                  ).value;
              final color = _roleColor(role);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_roleLabel(role)),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: animatedRatio,
                        minHeight: 12,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statusAnalysis(List<Map<String, dynamic>> users) {
    final pending = users
        .where((user) => user['status'] == 'PENDING_APPROVAL')
        .length;
    final approved = users.where((user) => user['status'] == 'APPROVED').length;
    final rejected = users.where((user) => user['status'] == 'REJECTED').length;
    final disabled = users.where((user) => user['active'] != true).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Account Status',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p16),
            Wrap(
              spacing: AppSizes.p8,
              runSpacing: AppSizes.p8,
              children: [
                Chip(
                  label: Text('Approved  $approved'),
                  backgroundColor: Colors.green.withValues(alpha: 0.12),
                ),
                Chip(
                  label: Text('Pending  $pending'),
                  backgroundColor: Colors.orange.withValues(alpha: 0.12),
                ),
                Chip(
                  label: Text('Rejected  $rejected'),
                  backgroundColor: Colors.red.withValues(alpha: 0.12),
                ),
                Chip(
                  label: Text('Disabled  $disabled'),
                  backgroundColor: Colors.grey.withValues(alpha: 0.12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    final active = users.where((user) => user['active'] == true).length;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text('User Analytics'),
          actions: [
            IconButton(
              tooltip: 'Refresh analysis',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadUsers,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadUsers,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.p16),
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
                      items: _roleOptions
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
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
                      items: _statusOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _statusFilter = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              if (_loading)
                const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (users.isEmpty)
                const SizedBox(
                  height: 280,
                  child: Center(child: Text('No users match your filters.')),
                )
              else ...[
                Row(
                  children: [
                    _metric(
                      'Total Users',
                      users.length,
                      Icons.people_alt_outlined,
                      Colors.blue,
                    ),
                    const SizedBox(width: AppSizes.p8),
                    _metric(
                      'Active Users',
                      active,
                      Icons.verified_user_outlined,
                      AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                _roleBars(users),
                const SizedBox(height: AppSizes.p12),
                _statusAnalysis(users),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
