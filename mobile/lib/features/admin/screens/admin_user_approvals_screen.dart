import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/api_client.dart';

class AdminUserApprovalsScreen extends StatefulWidget {
  const AdminUserApprovalsScreen({super.key});

  @override
  State<AdminUserApprovalsScreen> createState() =>
      _AdminUserApprovalsScreenState();
}

class _AdminUserApprovalsScreenState extends State<AdminUserApprovalsScreen> {
  final AdminService _adminService = AdminService(apiClient: ApiClient());
  List<Map<String, dynamic>> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    try {
      final users = await _adminService.getUsers(status: 'PENDING_APPROVAL');
      if (mounted)
        setState(() {
          _pending = users;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _process(String id, String name, bool approved) async {
    try {
      await _adminService.decideUser(id, approved);
      if (mounted)
        setState(() => _pending.removeWhere((user) => user['id'] == id));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update this user.')),
        );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approved
              ? '$name approved successfully!'
              : '$name registration rejected.',
        ),
        backgroundColor: approved ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text('User Approvals')),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pending Approvals Queue',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),
                    Expanded(
                      child: _pending.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'All clean! No pending approvals.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _pending.length,
                              itemBuilder: (context, index) {
                                final user = _pending[index];
                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSizes.p12,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSizes.p16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              user['fullName'] as String? ??
                                                  'Unnamed user',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Chip(
                                              label: Text(
                                                user['role'] as String? ??
                                                    'Unknown',
                                              ),
                                              backgroundColor: theme
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Phone: ${user['phone'] ?? '-'}'),
                                        Text('Email: ${user['email'] ?? '-'}'),
                                        const Divider(height: AppSizes.p24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AppButton.destructive(
                                                label: 'Reject',
                                                icon: Icons.close_rounded,
                                                onPressed: () => _process(
                                                  user['id'] as String,
                                                  user['fullName'] as String? ??
                                                      'User',
                                                  false,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSizes.p12),
                                            Expanded(
                                              child: AppButton(
                                                label: 'Approve',
                                                icon: Icons.check_rounded,
                                                onPressed: () => _process(
                                                  user['id'] as String,
                                                  user['fullName'] as String? ??
                                                      'User',
                                                  true,
                                                ),
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
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
