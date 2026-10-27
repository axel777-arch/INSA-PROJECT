import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/auth_service.dart';

class PendingApprovalArguments {
  final String role;
  final String identifier;
  final String password;

  const PendingApprovalArguments({
    required this.role,
    required this.identifier,
    required this.password,
  });
}

class PendingApprovalScreen extends StatefulWidget {
  final String role;
  final String? identifier;
  final String? password;

  const PendingApprovalScreen({
    super.key,
    required this.role,
    this.identifier,
    this.password,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  static const _checkInterval = Duration(seconds: 30);

  final AuthService _authService = AuthService(apiClient: ApiClient());
  Timer? _approvalTimer;
  bool _checking = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (widget.identifier != null && widget.password != null) {
      _approvalTimer = Timer.periodic(_checkInterval, (_) => _checkApproval());
    }
  }

  @override
  void dispose() {
    _approvalTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkApproval() async {
    final identifier = widget.identifier;
    final password = widget.password;
    if (_checking || identifier == null || password == null) return;

    setState(() {
      _checking = true;
      _statusMessage = null;
    });
    try {
      final signedIn = await _authService.login(identifier, password);
      if (!mounted) return;
      if (!signedIn || _authService.currentUser == null) {
        _approvalTimer?.cancel();
        setState(() {
          _statusMessage = appText(
            'Unable to verify approval. Please sign in again.',
          );
        });
        return;
      }

      _approvalTimer?.cancel();
      final route = switch (_authService.currentUser!.role) {
        'ADMIN' => '/admin/home',
        'EXPERT' => '/expert/home',
        'EXTENSION_WORKER' => '/extension/home',
        _ => '/farmer/home',
      };
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'ACCOUNT_PENDING') {
        setState(() {
          _statusMessage = appText('Your account is still awaiting approval.');
        });
      } else {
        _approvalTimer?.cancel();
        setState(() {
          _statusMessage = error.message;
        });
      }
    } catch (error) {
      if (!mounted) return;
      _approvalTimer?.cancel();
      setState(() {
        _statusMessage = appText(
          'Could not check approval status: {error}',
        ).replaceAll('{error}', error.toString());
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCheck = widget.identifier != null && widget.password != null;

    return Scaffold(
      appBar: AppBar(title: Text(appText('Approval status'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                appText(
                  'Your {role} account is awaiting administrator approval.',
                ).replaceAll('{role}', widget.role),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                canCheck
                    ? appText(
                        'We will check again automatically every 30 seconds.',
                      )
                    : appText(
                        'Please sign in again after your account is approved.',
                      ),
                textAlign: TextAlign.center,
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              if (canCheck) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _checking ? null : _checkApproval,
                  child: _checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(appText('Check now')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
