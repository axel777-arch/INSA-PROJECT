import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class SmsSimulatorScreen extends StatefulWidget {
  const SmsSimulatorScreen({super.key});

  @override
  State<SmsSimulatorScreen> createState() => _SmsSimulatorScreenState();
}

class _SmsSimulatorScreenState extends State<SmsSimulatorScreen> {
  final _phoneController = TextEditingController(text: '+251911001122');
  final _messageController = TextEditingController(
    text: '[Agri-Insight] Teff Rust detected in Oromia region. Apply sulfur-based treatment.',
  );
  
  bool _isSending = false;
  final List<Map<String, String>> _smsHistory = [
    {
      'phone': '+251922334455',
      'message': '[Agri-Insight] Sowing season begins tomorrow. Ensure soil moisture is adequate.',
      'status': 'DELIVERED',
      'time': '10 mins ago',
    }
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendSimulatedSms() {
    if (_phoneController.text.isEmpty || _messageController.text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Simulate SMS dispatch transition states: QUEUED -> SENT -> DELIVERED
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _smsHistory.insert(0, {
          'phone': _phoneController.text,
          'message': _messageController.text,
          'status': 'SENT',
          'time': 'Just now',
        });
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _smsHistory[0]['status'] = 'DELIVERED';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS Delivered Successfully! (Simulated)'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _isSending = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Simulator'),
      ),
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
                      'Simulate SMS Outbox',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                      label: 'Send Simulated SMS',
                      icon: Icons.send_rounded,
                      onPressed: _sendSimulatedSms,
                      isLoading: _isSending,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p20),
            
            Text(
              'Simulated Dispatch History',
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
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              sms['time']!,
                              style: theme.textTheme.bodySmall,
                            ),
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
    );
  }
}
