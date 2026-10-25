import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/live/live_sync_controller.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/api_client.dart';

class AdminUserApprovalsScreen extends StatefulWidget {
  const AdminUserApprovalsScreen({super.key});

  @override
  State<AdminUserApprovalsScreen> createState() => _AdminUserApprovalsScreenState();
}

class _AdminUserApprovalsScreenState extends State<AdminUserApprovalsScreen> {
  final AdminService _adminService = AdminService(apiClient: ApiClient());

  List<AdminUser> _pending = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _busyIds = {};
  late final LiveSyncController _live;

  @override
  void initState() {
    super.initState();
    _live = LiveSyncController(
      storageKey: 'admin_approvals',
      refresh: _load,
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    _live.start();
  }

  @override
  void dispose() {
    _live.dispose();
    super.dispose();
  }

  /// Silent reload (no full-screen spinner after the first load), so new
  /// registrations appear on their own within seconds.
  Future<bool> _load() async {
    try {
      final users = await _adminService.getUsers();
      if (!mounted) return false;
      setState(() {
        _pending = users.where((u) => u.isPending).toList();
        _isLoading = false;
        _error = null;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        // Keep showing the last good list if a background refresh fails.
        if (_pending.isEmpty) {
          _error = e is ApiException ? e.message : e.toString();
        }
        _isLoading = false;
      });
      return false;
    }
  }

  Future<void> _process(AdminUser user, bool approved) async {
    setState(() => _busyIds.add(user.id));
    try {
      await _adminService.setApproval(user.id, approved: approved);
      if (!mounted) return;
      setState(() {
        _pending.removeWhere((u) => u.id == user.id);
        _busyIds.remove(user.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? '${user.fullName} approved successfully!'
                : '${user.fullName} registration rejected.',
          ),
          backgroundColor: approved ? AppColors.success : AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyIds.remove(user.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildBody(ThemeData theme) {
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
            AppButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              isFullWidth: false,
              onPressed: () => _live.syncNow(),
            ),
          ],
        ),
      );
    }
    if (_pending.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _live.syncNow(silent: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(Icons.check_circle_outline, size: 64, color: theme.primaryColor),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'All clean! No pending approvals.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _live.syncNow(silent: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _pending.length,
        itemBuilder: (context, index) {
          final user = _pending[index];
          final busy = _busyIds.contains(user.id);
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.p12),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(user.roleLabel),
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Phone: ${user.phone.isEmpty ? '-' : user.phone}'),
                  if (user.email.isNotEmpty) Text('Email: ${user.email}'),
                  const Divider(height: AppSizes.p24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.destructive(
                          label: 'Reject',
                          icon: Icons.close_rounded,
                          onPressed: busy ? null : () => _process(user, false),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: AppButton(
                          label: 'Approve',
                          icon: Icons.check_rounded,
                          isLoading: busy,
                          onPressed: busy ? null : () => _process(user, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('User Approvals'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _live.isSyncing ? null : () => _live.syncNow(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pending Approvals Queue',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p12),
              Expanded(child: _buildBody(theme)),
            ],
          ),
        ),
      ),
    );
  }
}
