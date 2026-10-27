import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/screen_backdrop.dart';
import '../../../../models/farmer_model.dart';
import '../../../../models/follow_up_model.dart';
import '../../../../services/api_client.dart';
import '../../../../services/farmer_service.dart';
import '../../../../services/observation_service.dart';

class ExtensionFollowUpsScreen extends StatefulWidget {
  const ExtensionFollowUpsScreen({super.key});

  @override
  State<ExtensionFollowUpsScreen> createState() =>
      _ExtensionFollowUpsScreenState();
}

class _ExtensionFollowUpsScreenState extends State<ExtensionFollowUpsScreen> {
  final ObservationService _service = ObservationService(
    apiClient: ApiClient(),
  );
  final FarmerService _farmerService = FarmerService(apiClient: ApiClient());
  List<FollowUpModel> _followUps = [];
  List<FarmerModel> _farmers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getFollowUps(),
        _farmerService.getFarmers(),
      ]);
      if (!mounted) return;
      setState(() {
        _followUps = results[0] as List<FollowUpModel>;
        _farmers = results[1] as List<FarmerModel>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scheduleFollowUp() async {
    if (_farmers.isEmpty) {
      _showMessage('No farmers are available for follow-up scheduling.');
      return;
    }
    final result =
        await showDialog<({String farmerId, DateTime date, String notes})>(
          context: context,
          builder: (context) => _ScheduleFollowUpDialog(farmers: _farmers),
        );
    if (result == null) return;

    try {
      await _service.scheduleFollowUp(
        farmerId: result.farmerId,
        scheduledDate: result.date,
        notes: result.notes.isEmpty ? null : result.notes,
      );
      await _load();
    } catch (error) {
      _showMessage('Follow-up could not be scheduled: $error', isError: true);
    }
  }

  Future<void> _updateStatus(FollowUpModel followUp, String status) async {
    String? outcome;
    if (status == 'COMPLETED') {
      outcome = await _requestOutcome();
      if (outcome == null || outcome.trim().isEmpty) return;
    }
    try {
      await _service.updateFollowUp(
        id: followUp.id,
        status: status,
        completedDate: status == 'COMPLETED' ? DateTime.now() : null,
        outcome: outcome,
      );
      await _load();
    } catch (error) {
      _showMessage('Follow-up could not be updated: $error', isError: true);
    }
  }

  Future<String?> _requestOutcome() async {
    final controller = TextEditingController();
    final outcome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete follow-up'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Visit outcome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return outcome;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Farmer follow-ups'),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh follow-ups',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _scheduleFollowUp,
          icon: const Icon(Icons.event_available),
          label: const Text('Schedule visit'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _FollowUpError(message: _error!, onRetry: _load)
            : _followUps.isEmpty
            ? const Center(child: Text('No follow-up visits scheduled yet.'))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: _followUps.length,
                  itemBuilder: (context, index) {
                    final item = _followUps[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.event_note_outlined),
                        ),
                        title: Text(
                          item.farmerName.isEmpty
                              ? 'Farmer follow-up'
                              : item.farmerName,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: AppSizes.p4),
                          child: Text(
                            '${item.scheduledDate.toLocal().toString().substring(0, 16)}\n'
                            '${item.status.replaceAll('_', ' ')}'
                            '${item.notes == null ? '' : '\n${item.notes}'}'
                            '${item.outcome == null ? '' : '\nOutcome: ${item.outcome}'}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: _buildActions(item),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget? _buildActions(FollowUpModel item) {
    if (item.status == 'COMPLETED' || item.status == 'CANCELLED') return null;
    return PopupMenuButton<String>(
      tooltip: 'Update follow-up',
      onSelected: (status) => _updateStatus(item, status),
      itemBuilder: (context) => [
        if (item.status == 'PENDING')
          const PopupMenuItem(
            value: 'IN_PROGRESS',
            child: Text('Mark in progress'),
          ),
        const PopupMenuItem(value: 'COMPLETED', child: Text('Complete visit')),
        const PopupMenuItem(value: 'CANCELLED', child: Text('Cancel visit')),
      ],
    );
  }
}

class _ScheduleFollowUpDialog extends StatefulWidget {
  final List<FarmerModel> farmers;

  const _ScheduleFollowUpDialog({required this.farmers});

  @override
  State<_ScheduleFollowUpDialog> createState() =>
      _ScheduleFollowUpDialogState();
}

class _ScheduleFollowUpDialogState extends State<_ScheduleFollowUpDialog> {
  final TextEditingController _notesController = TextEditingController();
  String? _farmerId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _farmerId = widget.farmers.first.id;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule a farmer visit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _farmerId,
              decoration: const InputDecoration(labelText: 'Farmer'),
              items: widget.farmers
                  .map(
                    (farmer) => DropdownMenuItem(
                      value: farmer.id,
                      child: Text(farmer.fullName),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _farmerId = value),
            ),
            const SizedBox(height: AppSizes.p12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(_date.toLocal().toString().substring(0, 10)),
            ),
            const SizedBox(height: AppSizes.p12),
            TextField(
              controller: _notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Visit notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _farmerId == null
              ? null
              : () => Navigator.pop(context, (
                  farmerId: _farmerId!,
                  date: _date,
                  notes: _notesController.text.trim(),
                )),
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

class _FollowUpError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FollowUpError({required this.message, required this.onRetry});

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
