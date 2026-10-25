import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/live/live_sync_controller.dart';
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

  List<AdminUser> _users = [];
  bool _isLoading = true;
  String? _error;

  final _searchController = TextEditingController();
  String _roleFilter = 'All';
  String _statusFilter = 'All';

  static const List<String> _roleOptions = [
    'All',
    'Farmer',
    'Extension Worker',
    'Agricultural Expert',
  ];
  static const List<String> _statusOptions = ['All', 'Active', 'Disabled', 'Pending'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _live = LiveSyncController(
      storageKey: 'admin_users',
      refresh: _loadUsers,
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    _live.start();
  }

  late final LiveSyncController _live;

  @override
  void dispose() {
    _live.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Reloads the user list. Used by the live refresh and after an action.
  Future<void> _load() => _live.syncNow(silent: true);

  Future<bool> _loadUsers() async {
    try {
      final users = await _adminService.getUsers();
      if (!mounted) return false;
      setState(() {
        _users = users;
        _isLoading = false;
        _error = null;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        if (_users.isEmpty) {
          _error = e is ApiException ? e.message : e.toString();
        }
        _isLoading = false;
      });
      return false;
    }
  }

  /// Display state of a user: Pending / Rejected / Active / Disabled.
  String _stateOf(AdminUser u) {
    if (u.status == 'PENDING') return 'Pending';
    if (u.status == 'REJECTED') return 'Rejected';
    return u.active ? 'Active' : 'Disabled';
  }

  List<AdminUser> get _filteredUsers {
    var results = List<AdminUser>.from(_users);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((u) {
        return u.fullName.toLowerCase().contains(query) ||
            u.phone.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    if (_roleFilter != 'All') {
      results = results.where((u) => u.roleLabel == _roleFilter).toList();
    }

    if (_statusFilter != 'All') {
      results = results.where((u) => _stateOf(u) == _statusFilter).toList();
    }

    return results;
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final messenger = ScaffoldMessenger.of(context);

    if (user.role == 'ADMIN') {
      messenger.showSnackBar(
        const SnackBar(content: Text('Administrator accounts cannot be disabled here.')),
      );
      return;
    }
    if (user.status != 'APPROVED') {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            user.isPending
                ? 'Use User Approvals to approve or reject ${user.fullName}.'
                : '${user.fullName} was rejected and cannot be enabled here.',
          ),
        ),
      );
      return;
    }

    final makeActive = !user.active;
    try {
      await _adminService.setActive(user.id, active: makeActive);
      if (!mounted) return;
      await _load();
      messenger.showSnackBar(
        SnackBar(content: Text('${user.fullName} is now ${makeActive ? 'active' : 'disabled'}.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _stateColor(String state) {
    switch (state) {
      case 'Active':
        return AppColors.success;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'FARMER':
        return Icons.people_outline_rounded;
      case 'EXTENSION_WORKER':
        return Icons.engineering_outlined;
      case 'ADMIN':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.psychology_outlined;
    }
  }

  Widget _buildList(List<AdminUser> users) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (users.isEmpty) {
      return const Center(child: Text('No users match your search or filters.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final state = _stateOf(user);
          final color = _stateColor(state);
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: ListTile(
              onTap: () => _toggleStatus(user),
              leading: CircleAvatar(child: Icon(_roleIcon(user.role))),
              title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${user.roleLabel} • ${user.phone.isEmpty ? user.email : user.phone}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                      items: _roleOptions
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
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
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _statusFilter = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              Expanded(child: _buildList(users)),
            ],
          ),
        ),
      ),
    );
  }
}
