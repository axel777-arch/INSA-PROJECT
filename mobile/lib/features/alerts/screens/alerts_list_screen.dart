import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/message_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/messaging_service.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  final MessagingService _messaging = MessagingService(apiClient: ApiClient());
  List<MessageModel> _alerts = [];
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _loadAlerts(silent: true),
    );
  }

  Future<void> _loadAlerts({bool silent = false}) async {
    try {
      final messages = await _messaging.getMessages();
      if (!mounted) return;
      setState(() {
        _alerts = messages.where((message) => !message.isOutgoing).toList();
        _loading = false;
      });
    } catch (_) {
      if (!silent && mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not load alerts.')));
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Recent Alerts'),
          actions: [
            IconButton(
              onPressed: _loadAlerts,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _alerts.isEmpty
            ? const Center(child: Text('No alerts received yet.'))
            : RefreshIndicator(
                onRefresh: _loadAlerts,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return Card(
                      color: alert.read
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.08),
                      margin: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: ListTile(
                        leading: Icon(
                          Icons.notifications_active_outlined,
                          color: alert.read ? Colors.grey : Colors.orange,
                        ),
                        title: Text(
                          'Message from ${alert.senderName ?? 'User'}',
                        ),
                        subtitle: Text(alert.body),
                        onTap: () async {
                          if (!alert.read) await _messaging.markRead(alert.id);
                          _loadAlerts(silent: true);
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
