import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';
import '../../../../services/messaging_service.dart';

class SmsSimulatorScreen extends StatefulWidget {
  const SmsSimulatorScreen({super.key});

  @override
  State<SmsSimulatorScreen> createState() => _SmsSimulatorScreenState();
}

class _SmsSimulatorScreenState extends State<SmsSimulatorScreen> {
  final _phoneController = TextEditingController(text: '+251911001122');
  final _messageController = TextEditingController(
    text: '[Agri-Insight] What crop are you growing, and what advisory do you need?',
  );

  final MessagingService _messagingService = MessagingService(apiClient: ApiClient());

  bool _isSending = false;

  final List<Map<String, String>> _smsHistory = [
    {
      'phone': '+251922334455',
      'message': '[Agri-Insight] Sowing season begins tomorrow. Ensure soil moisture is adequate.',
      'status': 'DELIVERED',
      'time': 'Earlier',
    },
  ];

  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      _userId = user['id'] as String?;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();
    if (phone.isEmpty || message.isEmpty) return;

    setState(() => _isSending = true);

    // Optimistically add to history as QUEUED
    final entry = <String, String>{
      'phone': phone,
      'message': message,
      'status': 'QUEUED',
      'time': 'Just now',
    };
    setState(() => _smsHistory.insert(0, entry));

    try {
      await _messagingService.sendSmsSimulation(
        recipient: phone,
        message: message,
        contentId: 'simulator-${DateTime.now().millisecondsSinceEpoch}',
        createdBy: _userId ?? 'system',
      );
      if (!mounted) return;
      // Update status to DELIVERED on success
      setState(() => entry['status'] = 'DELIVERED');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SMS dispatched via backend simulator.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => entry['status'] = 'FAILED');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS failed: ${e.message}'), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      // Offline or network error — still show as SENT (simulator behaviour)
      setState(() => entry['status'] = 'SENT (offline sim)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offline mode — SMS queued locally. Error: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('SMS Simulator')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Simulate SMS Dispatch',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        'Sends a real request to POST /api/messaging/sms',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      AppTextField(
                        label: 'Recipient Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android_rounded,
                      ),
                      const SizedBox(height: AppSizes.p12),
                      AppTextField(
                        label: 'SMS Message Content',
                        controller: _messageController,
                        prefixIcon: Icons.chat_bubble_outline_rounded,
                      ),
                      const SizedBox(height: AppSizes.p16),
                      AppButton(
                        label: 'Send SMS',
                        icon: Icons.send_rounded,
                        onPressed: _isSending ? null : _sendSms,
                        isLoading: _isSending,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p20),
              Text(
                'Dispatch History',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.p8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _smsHistory.length,
                itemBuilder: (context, index) {
                  final sms = _smsHistory[index];
                  final status = sms['status']!;
                  Color statusColor = AppColors.warning;
                  if (status == 'DELIVERED') statusColor = AppColors.success;
                  if (status == 'FAILED') statusColor = AppColors.error;

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        status == 'DELIVERED' ? Icons.done_all_rounded : Icons.schedule_rounded,
                        color: statusColor,
                      ),
                      title: Text(sms['phone']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(sms['message']!),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Status: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(sms['time']!, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
