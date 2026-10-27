import 'package:flutter/material.dart';

import '../../../../core/config/user_session.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/case_attachment_viewer.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/case_message_model.dart';
import '../../../../models/farmer_case_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_case_service.dart';

class CaseCollaborationScreen extends StatefulWidget {
  final String caseId;

  const CaseCollaborationScreen({super.key, required this.caseId});

  @override
  State<CaseCollaborationScreen> createState() =>
      _CaseCollaborationScreenState();
}

class _CaseCollaborationScreenState extends State<CaseCollaborationScreen> {
  final FarmerCaseService _caseService = FarmerCaseService(
    apiClient: ApiClient(),
  );
  final TextEditingController _messageController = TextEditingController();
  FarmerCaseModel? _caseRecord;
  List<CaseMessageModel> _messages = [];
  String? _currentUserId;
  String? _error;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final thread = await _caseService.getCaseThread(widget.caseId);
      final user = await UserSession.get();
      if (!mounted) return;
      setState(() {
        _caseRecord = thread?.caseRecord;
        _messages = thread?.messages ?? [];
        _currentUserId = user?.id;
        if (thread == null) {
          _error = 'This case is no longer available.';
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await _caseService.sendCaseMessage(
        caseId: widget.caseId,
        body: body,
        visibility: 'INTERNAL',
      );
      _messageController.clear();
      await _load();
    } catch (error) {
      _showError('Message could not be sent: $error');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _changeStatus(String status) async {
    if (_isUpdating) return;
    String? details;
    if (status == 'RESOLVED') {
      details = await _requestResolutionSummary();
      if (details == null || details.trim().isEmpty) return;
    } else if (status == 'ESCALATED') {
      details = await _requestEscalationReason();
      if (details == null || details.trim().isEmpty) return;
    } else if (status == 'WAITING_FOR_INFORMATION') {
      details = await _requestText(
        'Request farmer information',
        'What information should the farmer provide?',
      );
      if (details == null || details.trim().isEmpty) return;
    }

    setState(() => _isUpdating = true);
    try {
      if (status == 'ESCALATED') {
        await _caseService.escalateCase(caseId: widget.caseId, reason: details);
      } else if (status == 'WAITING_FOR_INFORMATION') {
        await _caseService.requestCaseInformation(
          caseId: widget.caseId,
          message: details!,
        );
      } else {
        await _caseService.updateCaseStatus(
          caseId: widget.caseId,
          status: status,
          details: details,
        );
      }
      await _load();
    } catch (error) {
      _showError('Case status could not be updated: $error');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<String?> _requestResolutionSummary() =>
      _requestText('Resolve case', 'Enter the diagnosis or resolution.');

  Future<String?> _requestEscalationReason() =>
      _requestText('Escalate case', 'Why does this case need expert review?');

  Future<String?> _requestText(String title, String hint) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  String _attachmentLabel(String attachment) {
    final match = RegExp(r';name=([^;]+);base64,').firstMatch(attachment);
    if (match != null) return Uri.decodeComponent(match.group(1)!);
    if (attachment.startsWith('data:application/pdf')) {
      return 'case-attachment.pdf';
    }
    if (attachment.startsWith('data:image/')) return 'case image';
    return Uri.tryParse(attachment)?.pathSegments.last ?? attachment;
  }

  @override
  Widget build(BuildContext context) {
    final item = _caseRecord;
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(item == null ? 'Case collaboration' : item.subject),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh case',
            ),
          ],
        ),
        body: _isLoading && item == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null && item == null
            ? _ErrorState(message: _error!, onRetry: _load)
            : item == null
            ? const Center(child: Text('Case is unavailable.'))
            : _buildCase(item),
      ),
    );
  }

  Widget _buildCase(FarmerCaseModel item) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.p16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSizes.p8,
                          runSpacing: AppSizes.p8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(label: Text(item.status.replaceAll('_', ' '))),
                            Text(item.farmerName),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p8),
                        Text(item.description),
                        const SizedBox(height: AppSizes.p8),
                        Text(
                          '${item.cropName} • ${item.location}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (item.attachmentPaths.isNotEmpty) ...[
                          const Divider(height: AppSizes.p24),
                          Text(
                            'Attachments',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          for (final attachment in item.attachmentPaths)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                attachment.startsWith('data:application/pdf')
                                    ? Icons.picture_as_pdf_outlined
                                    : Icons.image_outlined,
                              ),
                              title: Text(_attachmentLabel(attachment)),
                              trailing: const Icon(Icons.open_in_new),
                              onTap: () async {
                                try {
                                  await openCaseAttachment(context, attachment);
                                } catch (error) {
                                  _showError(
                                    'Attachment could not be opened: $error',
                                  );
                                }
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildActions(item),
                const SizedBox(height: AppSizes.p12),
                Text(
                  'Team messages',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.p8),
                if (_messages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                    child: Text('No team messages yet.'),
                  )
                else
                  ..._messages.reversed.map(_buildMessage),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p12,
              AppSizes.p8,
              AppSizes.p12,
              AppSizes.p12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Message the case team',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p8),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: _isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  tooltip: 'Send internal message',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(FarmerCaseModel item) {
    if (item.status == 'RESOLVED' || item.status == 'CLOSED') {
      return const SizedBox.shrink();
    }
    final actions = <Widget>[];
    if (item.status != 'IN_PROGRESS') {
      actions.add(
        OutlinedButton.icon(
          onPressed: _isUpdating ? null : () => _changeStatus('IN_PROGRESS'),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start work'),
        ),
      );
    }
    if (item.status != 'WAITING_FOR_INFORMATION') {
      actions.add(
        OutlinedButton.icon(
          onPressed: _isUpdating
              ? null
              : () => _changeStatus('WAITING_FOR_INFORMATION'),
          icon: const Icon(Icons.help_outline),
          label: const Text('Request information'),
        ),
      );
    }
    if (item.status != 'ESCALATED') {
      actions.add(
        OutlinedButton.icon(
          onPressed: _isUpdating ? null : () => _changeStatus('ESCALATED'),
          icon: const Icon(Icons.trending_up),
          label: const Text('Escalate'),
        ),
      );
    }
    actions.add(
      FilledButton.icon(
        onPressed: _isUpdating ? null : () => _changeStatus('RESOLVED'),
        icon: _isUpdating
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: const Text('Resolve'),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
      child: Wrap(
        spacing: AppSizes.p8,
        runSpacing: AppSizes.p8,
        children: actions,
      ),
    );
  }

  Widget _buildMessage(CaseMessageModel message) {
    final isMine = message.senderId == _currentUserId;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          color: isMine ? AppColors.primary.withValues(alpha: 0.08) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isMine ? 'You' : 'Case team'),
                const SizedBox(height: AppSizes.p4),
                Text(message.body),
                const SizedBox(height: AppSizes.p4),
                Text(
                  message.createdAt.toLocal().toString().substring(0, 16),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.p12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
