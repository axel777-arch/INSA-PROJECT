import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../services/api_client.dart';

class SmsSimulatorScreen extends StatefulWidget {
  const SmsSimulatorScreen({super.key});

  @override
  State<SmsSimulatorScreen> createState() => _SmsSimulatorScreenState();
}

class _SmsSimulatorScreenState extends State<SmsSimulatorScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _phoneController = TextEditingController(text: '+251911001122');
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;

  List<Map<String, dynamic>> _messages = [];

  static const List<String> _quickQueries = [
    'CROP MAIZE LEAF_YELLOW',
    'CROP TEFF RUST',
    'WEATHER OROMIA',
    'PRICE TEFF',
    'HELP',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final phone = _phoneController.text.trim();
    try {
      final response = await _apiClient.get('/simulation/sms/history?phone=${Uri.encodeComponent(phone)}');
      if (response is Map<String, dynamic> && response['messages'] is List) {
        final list = (response['messages'] as List).cast<Map<String, dynamic>>();
        setState(() {
          _messages = list;
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }
    } catch (e) {
      debugPrint('[SmsSimulatorScreen] _fetchHistory error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendQuery([String? customText]) async {
    final phone = _phoneController.text.trim();
    final text = (customText ?? _messageController.text).trim();
    if (phone.isEmpty || text.isEmpty) return;

    if (customText == null) {
      _messageController.clear();
    }

    // Optimistically add user message
    final tempInbound = {
      'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'direction': 'INBOUND',
      'body': text,
      'createdAt': DateTime.now().toIso8601String(),
    };
    setState(() {
      _messages.add(tempInbound);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final res = await _apiClient.post('/simulation/sms/query', {
        'senderPhone': phone,
        'text': text,
      });

      if (!mounted) return;

      if (res is Map<String, dynamic> && res['outbound'] != null) {
        final outbound = res['outbound'] as Map<String, dynamic>;
        setState(() {
          _messages.add({
            'id': outbound['id'] ?? 'out-${DateTime.now().millisecondsSinceEpoch}',
            'direction': 'OUTBOUND',
            'body': outbound['body'],
            'createdAt': outbound['createdAt'] ?? DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process SMS query: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Two-Way SMS Simulator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Thread',
              onPressed: _fetchHistory,
            ),
          ],
        ),
        body: Column(
          children: [
            // Phone Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sim_card_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            labelText: 'Simulated Farmer Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _fetchHistory(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _fetchHistory,
                        child: const Text('Load'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick syntax pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Quick Commands:',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        ..._quickQueries.map((cmd) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(cmd, style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                                onPressed: _isSending ? null : () => _sendQuery(cmd),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages Feed
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text(
                                'No SMS messages yet.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Send a query like "CROP MAIZE LEAF_YELLOW" or "HELP".',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSizes.p16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isFarmer = msg['direction'] == 'INBOUND';
                            final time = msg['createdAt'] != null
                                ? msg['createdAt'].toString().substring(11, 16)
                                : '';

                            return Align(
                              alignment: isFarmer ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isFarmer
                                      ? AppColors.primary
                                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: Radius.circular(isFarmer ? 14 : 2),
                                    bottomRight: Radius.circular(isFarmer ? 2 : 14),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isFarmer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isFarmer ? 'Farmer (SMS Outbound)' : 'Agri-Insight Gateway',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isFarmer
                                                ? Colors.white70
                                                : (isDark ? Colors.white60 : Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      msg['body'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isFarmer
                                            ? Colors.white
                                            : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isFarmer
                                                ? Colors.white60
                                                : (isDark ? Colors.white54 : Colors.black45),
                                          ),
                                        ),
                                        if (isFarmer) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.done_all_rounded, size: 12, color: Colors.white70),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type query (e.g. CROP TEFF RUST)...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onSubmitted: (_) => _sendQuery(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                      onPressed: _isSending ? null : () => _sendQuery(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
