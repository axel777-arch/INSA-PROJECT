import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/message_model.dart';
import '../../../services/api_client.dart';
import '../../../services/messaging_service.dart';

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({super.key});

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  final MessagingService _service = MessagingService(apiClient: ApiClient());
  final _messageController = TextEditingController();
  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _contacts = [];
  String? _selectedContact;
  bool _loading = true;
  bool _sending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _load(silent: true),
    );
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final results = await Future.wait([
        _service.getMessages(),
        _service.getContacts(),
      ]);
      if (!mounted) return;
      setState(() {
        _messages = results[0] as List<MessageModel>;
        _contacts = results[1] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (_) {
      if (!silent && mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load messages.')),
        );
      }
    }
  }

  Future<void> _send() async {
    final body = _messageController.text.trim();
    if (_selectedContact == null || body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _service.sendMessage(_selectedContact!, body);
      _messageController.clear();
      await _load(silent: true);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message could not be sent.')),
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(child: Text('No messages yet.'))
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(AppSizes.p16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Card(
                              color: message.read
                                  ? null
                                  : Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.08),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person_outline_rounded),
                                ),
                                title: Text(
                                  message.isOutgoing
                                      ? 'To ${message.recipientName ?? message.recipientId ?? 'User'}'
                                      : '${message.senderName ?? 'User'} (${message.senderRole ?? 'Member'})',
                                ),
                                subtitle: Text(message.body),
                                trailing: Text(
                                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                                ),
                                onTap: () async {
                                  if (!message.read)
                                    await _service.markRead(message.id);
                                  _load(silent: true);
                                },
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: const [
                      BoxShadow(blurRadius: 8, color: Colors.black12),
                    ],
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedContact,
                        decoration: const InputDecoration(
                          labelText: 'Send to',
                          prefixIcon: Icon(Icons.person_search_outlined),
                        ),
                        items: _contacts
                            .map(
                              (contact) => DropdownMenuItem(
                                value: contact['id'] as String,
                                child: Text(
                                  '${contact['fullName']} (${contact['role']})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedContact = value),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Write a message',
                              controller: _messageController,
                              prefixIcon: Icons.message_outlined,
                            ),
                          ),
                          const SizedBox(width: AppSizes.p8),
                          AppButton(
                            icon: Icons.send_rounded,
                            label: 'Send',
                            isFullWidth: false,
                            isLoading: _sending,
                            onPressed: _send,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
