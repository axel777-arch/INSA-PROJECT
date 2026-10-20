import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';

/// Reusable modal dialog confirming intentional logout across all 4 dashboards.
/// "Cancel" retains the active session without side effects.
/// "Log Out" revokes token via POST /api/auth/logout, clears session storage,
/// and redirects to /login.
class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({super.key});

  /// Static helper to show the dialog
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService(apiClient: ApiClient());
      await authService.logout();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to login and clear navigation stack
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Text(
        'Are you sure you want to end your current session? You will need to enter your credentials again to log in.',
        style: TextStyle(fontSize: 14, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _handleLogout,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.logout_rounded, size: 18),
          label: Text(_isLoading ? 'Logging out...' : 'Log Out'),
        ),
      ],
    );
  }
}
