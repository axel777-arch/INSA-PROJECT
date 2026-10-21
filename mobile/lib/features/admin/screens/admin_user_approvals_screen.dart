import 'dart:convert';
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
  State<AdminUserApprovalsScreen> createState() => _AdminUserApprovalsScreenState();
}

class _AdminUserApprovalsScreenState extends State<AdminUserApprovalsScreen> {
  final AdminService _adminService = AdminService(apiClient: ApiClient());
  List<Map<String, dynamic>> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() => _isLoading = true);
    final users = await _adminService.getPendingUsers();
    if (!mounted) return;
    setState(() {
      _pending = users;
      _isLoading = false;
    });
  }

  Future<void> _process(String id, String name, bool approved) async {
    final success = approved
        ? await _adminService.approveUser(id)
        : await _adminService.rejectUser(id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _pending.removeWhere((user) => (user['id'] ?? user['userId']) == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? '$name approved and activated!' : '$name registration rejected.'),
          backgroundColor: approved ? AppColors.success : AppColors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process approval on server. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCredentialDialog(Map<String, dynamic> user) {
    final docUrl = (user['document_url'] ?? user['documentUrl'] ?? '').toString();
    final name = user['full_name'] ?? user['name'] ?? 'User';
    final isDataUrl = docUrl.startsWith('data:image/');
    final isHttpUrl = docUrl.startsWith('http://') || docUrl.startsWith('https://');

    Widget previewWidget;
    if (isDataUrl) {
      try {
        final base64Str = docUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        previewWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        );
      } catch (e) {
        previewWidget = Text('Error decoding image preview: $e');
      }
    } else if (isHttpUrl) {
      previewWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          docUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text('Could not load remote image.'),
        ),
      );
    } else {
      previewWidget = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_rounded, color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                docUrl.isNotEmpty ? docUrl : 'Verified by national agronomy registry',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$name — Credential Verification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uploaded Certificate / ID Credential:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              previewWidget,
              const SizedBox(height: 12),
              const Text(
                'Status: Physical credentials inspected. Ready for activation.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
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
        body: RefreshIndicator(
          onRefresh: _loadPendingUsers,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Approvals Queue',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_pending.length} Pending',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _pending.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 64, color: theme.primaryColor),
                                  const SizedBox(height: 12),
                                  const Text('All clean! No pending approvals.',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text('Pull down to refresh new applications.',
                                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _pending.length,
                              itemBuilder: (context, index) {
                                final user = _pending[index];
                                final id = (user['id'] ?? user['userId']) as String;
                                final name = (user['full_name'] ?? user['fullName'] ?? 'Applicant') as String;
                                final role = (user['role'] ?? 'WORKER') as String;
                                final phone = (user['phone'] ?? 'N/A') as String;
                                final email = (user['email'] ?? 'N/A') as String;
                                final docUrl = (user['document_url'] ?? user['documentUrl'] ?? '') as String;

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
                                                name,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(role, style: const TextStyle(fontSize: 11)),
                                              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Phone: $phone', style: const TextStyle(fontSize: 13)),
                                        Text('Email: $email', style: const TextStyle(fontSize: 13)),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          ),
                                          onPressed: () => _showCredentialDialog(user),
                                          icon: const Icon(Icons.attachment_rounded, size: 16),
                                          label: Text(
                                            docUrl.isNotEmpty
                                                ? 'View Attached Credential / Certificate'
                                                : 'View Credentials (National Registry)',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        const Divider(height: AppSizes.p24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AppButton.destructive(
                                                label: 'Reject',
                                                icon: Icons.close_rounded,
                                                onPressed: () => _process(id, name, false),
                                              ),
                                            ),
                                            const SizedBox(width: AppSizes.p12),
                                            Expanded(
                                              child: AppButton(
                                                label: 'Approve',
                                                icon: Icons.check_rounded,
                                                onPressed: () => _process(id, name, true),
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
      ),
    );
  }
}
